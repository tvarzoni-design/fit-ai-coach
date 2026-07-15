import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserConsent } from './entities/user-consent.entity';
import { DataProcessingLog } from './entities/data-processing-log.entity';
import { User } from '../users/entities/user.entity';
import { UserProfile } from '../users/entities/user-profile.entity';

@Injectable()
export class LgpdService {
  private readonly logger = new Logger(LgpdService.name);

  constructor(
    @InjectRepository(UserConsent)
    private consentRepository: Repository<UserConsent>,
    @InjectRepository(DataProcessingLog)
    private processingLogRepository: Repository<DataProcessingLog>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(UserProfile)
    private profileRepository: Repository<UserProfile>,
  ) {}

  async recordConsent(
    userId: string,
    consentType: string,
    granted: boolean,
    ip?: string,
    userAgent?: string,
  ): Promise<UserConsent> {
    const consent = this.consentRepository.create({
      userId,
      consentType,
      granted,
      ipAddress: ip,
      userAgent,
    });
    const saved = await this.consentRepository.save(consent);

    await this.logProcessing(userId, 'consent_record', 'consent', 
      `Consentimento ${granted ? 'concedido' : 'revogado'}: ${consentType}`, 
      'consentimento', 'system');

    return saved;
  }

  async getConsentStatus(userId: string): Promise<Record<string, boolean>> {
    const consents = await this.consentRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });

    const latestConsents: Record<string, boolean> = {};
    for (const consent of consents) {
      if (!(consent.consentType in latestConsents)) {
        latestConsents[consent.consentType] = consent.granted;
      }
    }
    return latestConsents;
  }

  async exportUserData(userId: string): Promise<Record<string, any>> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    const profile = await this.profileRepository.findOne({ where: { userId } });
    const consents = await this.consentRepository.find({ where: { userId } });
    const processingLogs = await this.processingLogRepository.find({ 
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 500,
    });

    await this.logProcessing(userId, 'data_export', 'all', 
      'Usuário solicitou exportação de dados pessoais (LGPD Art. 18, III)', 
      'obrigação legal', 'system');

    return {
      exportDate: new Date().toISOString(),
      userData: {
        personalInfo: user ? {
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          phone: user.phone,
          birthDate: user.birthDate,
          gender: user.gender,
          language: user.language,
          country: user.country,
          createdAt: user.createdAt,
        } : null,
        profile: profile ? {
          goal: profile.goal,
          experienceLevel: profile.experienceLevel,
          trainingDays: profile.trainingDays,
          trainingTime: profile.trainingTime,
          weight: profile.weight,
          height: profile.height,
          targetWeight: profile.targetWeight,
          injuries: profile.injuries,
        } : null,
        consents: consents.map(c => ({
          type: c.consentType,
          granted: c.granted,
          date: c.createdAt,
        })),
        processingHistory: processingLogs.map(l => ({
          action: l.action,
          dataType: l.dataType,
          description: l.description,
          legalBasis: l.legalBasis,
          date: l.createdAt,
        })),
      },
      legalInfo: {
        controller: 'Fit AI Coach Ltda',
        dpo: 'dpo@fitaicoach.com.br',
        rights: [
          'Confirmação da existência de tratamento (Art. 18, I)',
          'Acesso aos dados (Art. 18, II)',
          'Correção de dados incompletos (Art. 18, III)',
          'Anonimização, bloqueio ou eliminação (Art. 18, IV)',
          'Portabilidade dos dados (Art. 18, V)',
          'Eliminação dos dados tratados com consentimento (Art. 18, VI)',
          'Informações sobre compartilhamento (Art. 18, VII)',
          'Revogação do consentimento (Art. 18, IX)',
        ],
      },
    };
  }

  async deleteUserData(userId: string): Promise<{ success: boolean; message: string }> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      return { success: false, message: 'Usuário não encontrado' };
    }

    await this.logProcessing(userId, 'data_deletion', 'all',
      'Usuário solicitou exclusão de dados pessoais (LGPD Art. 18, VI)',
      'obrigação legal', 'system');

    user.firstName = 'Ex-Usuário';
    user.lastName = '';
    user.email = `deleted_${user.id}@anonymized.local`;
    user.phone = null as any;
    user.birthDate = null as any;
    user.gender = null as any;
    user.avatar = null as any;
    user.status = 'deleted' as any;
    user.deletedAt = new Date();
    await this.userRepository.save(user);

    const profile = await this.profileRepository.findOne({ where: { userId } });
    if (profile) {
      profile.goal = null as any;
      profile.injuries = null as any;
      await this.profileRepository.save(profile);
    }

    return { 
      success: true, 
      message: 'Dados pessoais anonymizados com sucesso. Conta marcada para exclusão permanente.' 
    };
  }

  async logProcessing(
    userId: string,
    action: string,
    dataType: string,
    description: string,
    legalBasis: string,
    processedBy: string,
  ): Promise<void> {
    const log = this.processingLogRepository.create({
      userId,
      action,
      dataType,
      description,
      legalBasis,
      processedBy,
    });
    await this.processingLogRepository.save(log);
  }

  async getProcessingLogs(userId: string): Promise<DataProcessingLog[]> {
    return this.processingLogRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }
}

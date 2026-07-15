import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { Admin, AdminRole } from './entities/admin.entity';
import { AuditLog } from './entities/audit-log.entity';
import { User } from '../users/entities/user.entity';
import { Subscription } from '../subscriptions/entities/subscription.entity';
import { Exercise } from '../exercises/entities/exercise.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(Admin)
    private adminRepository: Repository<Admin>,
    @InjectRepository(AuditLog)
    private auditLogRepository: Repository<AuditLog>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Subscription)
    private subscriptionRepository: Repository<Subscription>,
    @InjectRepository(Exercise)
    private exerciseRepository: Repository<Exercise>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async login(email: string, password: string) {
    const admin = await this.adminRepository.findOne({ where: { email } });
    if (!admin) {
      throw new UnauthorizedException('Credenciais inválidas');
    }

    if (admin.status !== 'active') {
      throw new UnauthorizedException('Conta administrativa desativada');
    }

    const isValid = await bcrypt.compare(password, admin.passwordHash);
    if (!isValid) {
      throw new UnauthorizedException('Credenciais inválidas');
    }

    admin.lastLogin = new Date();
    await this.adminRepository.save(admin);

    const payload = { sub: admin.id, email: admin.email, role: admin.role };

    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET') + '_admin',
      expiresIn: '8h',
    });

    await this.logAction({
      adminId: admin.id,
      action: 'login',
      module: 'admin',
      description: `Admin ${admin.name} fez login`,
    });

    return {
      accessToken,
      admin: {
        id: admin.id,
        name: admin.name,
        email: admin.email,
        role: admin.role,
      },
    };
  }

  async getDashboard(): Promise<any> {
    const totalUsers = await this.userRepository.count({ where: { status: 'active' as any } });
    const premiumUsers = await this.subscriptionRepository.count({ where: { status: 'active' } });
    const totalExercises = await this.exerciseRepository.count();
    const monthlyRevenue = premiumUsers * 24.90;

    return {
      users: { total: totalUsers, active: totalUsers, premium: premiumUsers },
      revenue: { monthly: monthlyRevenue, yearly: monthlyRevenue * 12 },
      workouts: { today: 0, week: 0 },
      ai: { conversations: 0 },
    };
  }

  async getUsers(page = 1, limit = 20): Promise<any> {
    const [users, total] = await this.userRepository.findAndCount({
      where: { status: MoreThan('deleted') as any },
      select: ['id', 'firstName', 'lastName', 'email', 'status', 'createdAt', 'lastLogin'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    return {
      data: users.map(u => ({
        id: u.id,
        name: `${u.firstName} ${u.lastName || ''}`.trim(),
        email: u.email,
        status: u.status,
        createdAt: u.createdAt,
        lastLogin: u.lastLogin,
      })),
      total,
      page,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getUser(id: string): Promise<any> {
    const user = await this.userRepository.findOne({
      where: { id },
      relations: ['profile'],
    });
    if (!user) return null;

    const subscription = await this.subscriptionRepository.findOne({
      where: { userId: id },
      order: { createdAt: 'DESC' },
    });

    return {
      id: user.id,
      name: `${user.firstName} ${user.lastName || ''}`.trim(),
      email: user.email,
      status: user.status,
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
      profile: user.profile,
      subscription: subscription ? {
        planId: subscription.planId,
        status: subscription.status,
        endDate: subscription.endDate,
      } : null,
    };
  }

  async getSubscriptions(): Promise<any> {
    const subscriptions = await this.subscriptionRepository.find({
      relations: ['user'],
      order: { createdAt: 'DESC' },
    });

    return subscriptions.map(s => ({
      id: s.id,
      user: s.user ? `${s.user.firstName} ${s.user.lastName || ''}`.trim() : 'Usuário',
      planId: s.planId,
      status: s.status,
      startDate: s.startDate,
      endDate: s.endDate,
      autoRenew: s.autoRenew,
    }));
  }

  async getExercises(page = 1, limit = 20): Promise<any> {
    const [exercises, total] = await this.exerciseRepository.findAndCount({
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    return {
      data: exercises,
      total,
      page,
      totalPages: Math.ceil(total / limit),
    };
  }

  async logAction(data: Partial<AuditLog>): Promise<void> {
    const log = this.auditLogRepository.create(data);
    await this.auditLogRepository.save(log);
  }

  async getAuditLogs(limit = 100): Promise<AuditLog[]> {
    return this.auditLogRepository.find({
      order: { createdAt: 'DESC' },
      take: limit,
      relations: ['admin'],
    });
  }
}

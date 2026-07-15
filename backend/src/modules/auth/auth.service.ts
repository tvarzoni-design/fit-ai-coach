import { Injectable, UnauthorizedException, ConflictException, NotFoundException, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User } from '../users/entities/user.entity';
import { UserProfile } from '../users/entities/user-profile.entity';
import { CreateUserDto } from '../users/dto/create-user.dto';
import { LoginDto } from './dto/login.dto';
import { LgpdService } from '../lgpd/lgpd.service';

interface DecodedSocialToken {
  email?: string;
  given_name?: string;
  family_name?: string;
  sub?: string;
}

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(UserProfile)
    private profileRepository: Repository<UserProfile>,
    private jwtService: JwtService,
    private configService: ConfigService,
    private lgpdService: LgpdService,
  ) {}

  async register(createUserDto: CreateUserDto, consents?: Array<{ type: string; granted: boolean }>, ip?: string, userAgent?: string) {
    const existingUser = await this.userRepository.findOne({
      where: { email: createUserDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email já cadastrado');
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(createUserDto.password, salt);

    const user = this.userRepository.create({
      firstName: createUserDto.firstName,
      lastName: createUserDto.lastName,
      email: createUserDto.email,
      passwordHash,
      birthDate: createUserDto.birthDate ? new Date(createUserDto.birthDate) : undefined,
      gender: createUserDto.gender as any,
      phone: createUserDto.phone,
    } as any) as unknown as User;

    const savedUser = await this.userRepository.save(user);

    const profile = this.profileRepository.create({
      userId: savedUser.id,
    });
    await this.profileRepository.save(profile);

    if (consents && consents.length > 0) {
      for (const consent of consents) {
        await this.lgpdService.recordConsent(savedUser.id, consent.type, consent.granted, ip, userAgent);
      }
    }

    const tokens = this.generateTokens(savedUser);

    return {
      user: {
        id: savedUser.id,
        firstName: savedUser.firstName,
        lastName: savedUser.lastName,
        email: savedUser.email,
      },
      ...tokens,
    };
  }

  async login(loginDto: LoginDto) {
    const user = await this.userRepository.findOne({
      where: { email: loginDto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Email ou senha inválidos');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.passwordHash);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Email ou senha inválidos');
    }

    user.lastLogin = new Date();
    await this.userRepository.save(user);

    const tokens = this.generateTokens(user);

    return {
      user: {
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        avatar: user.avatar,
      },
      ...tokens,
    };
  }

  async validateUser(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['profile'],
    });

    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }

    return user;
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_SECRET') + '_refresh',
      });

      const user = await this.userRepository.findOne({
        where: { id: payload.sub },
      });

      if (!user) {
        throw new UnauthorizedException();
      }

      return this.generateTokens(user);
    } catch {
      throw new UnauthorizedException('Refresh token inválido');
    }
  }

  async forgotPassword(email: string): Promise<{ message: string }> {
    const user = await this.userRepository.findOne({ where: { email } });
    if (!user) {
      return { message: 'Se o email estiver cadastrado, você receberá um link de redefinição.' };
    }

    const resetToken = this.jwtService.sign(
      { sub: user.id, purpose: 'password_reset' },
      { expiresIn: '1h', secret: this.configService.get<string>('JWT_SECRET') + '_reset' },
    );

    await this.lgpdService.logProcessing(
      user.id, 'password_reset_request', 'auth',
      'Usuário solicitou redefinição de senha',
      'execução de contrato', 'system',
    );

    return { message: 'Se o email estiver cadastrado, você receberá um link de redefinição.' };
  }

  async resetPassword(token: string, newPassword: string): Promise<{ message: string }> {
    try {
      const payload = this.jwtService.verify(token, {
        secret: this.configService.get<string>('JWT_SECRET') + '_reset',
      });

      if (payload.purpose !== 'password_reset') {
        throw new UnauthorizedException('Token inválido');
      }

      const user = await this.userRepository.findOne({ where: { id: payload.sub } });
      if (!user) {
        throw new NotFoundException('Usuário não encontrado');
      }

      const salt = await bcrypt.genSalt(10);
      user.passwordHash = await bcrypt.hash(newPassword, salt);
      await this.userRepository.save(user);

      await this.lgpdService.logProcessing(
        user.id, 'password_reset', 'auth',
        'Senha redefinida com sucesso',
        'execução de contrato', 'system',
      );

      return { message: 'Senha redefinida com sucesso' };
    } catch (error) {
      if (error instanceof UnauthorizedException || error instanceof NotFoundException) throw error;
      throw new UnauthorizedException('Token inválido ou expirado');
    }
  }

  async googleLogin(idToken: string) {
    const decoded = this.decodeSocialToken(idToken);
    if (!decoded?.email) {
      throw new BadRequestException('Token Google inválido: email não encontrado');
    }
    return this.findOrCreateSocialUser({
      email: decoded.email,
      firstName: decoded.given_name || decoded.email.split('@')[0],
      lastName: decoded.family_name || '',
    }, 'google');
  }

  async appleLogin(identityToken: string, fullName?: string) {
    const decoded = this.decodeSocialToken(identityToken);
    if (!decoded?.email) {
      throw new BadRequestException('Token Apple inválido: email não encontrado');
    }
    let firstName = decoded.given_name || '';
    let lastName = decoded.family_name || '';
    if (!firstName && fullName) {
      const parts = fullName.trim().split(' ');
      firstName = parts[0];
      lastName = parts.slice(1).join(' ');
    }
    if (!firstName) {
      firstName = decoded.email.split('@')[0];
    }
    return this.findOrCreateSocialUser({
      email: decoded.email,
      firstName,
      lastName,
    }, 'apple');
  }

  private decodeSocialToken(token: string): DecodedSocialToken {
    try {
      const parts = token.split('.');
      if (parts.length !== 3) return {};
      const payload = Buffer.from(parts[1], 'base64url').toString('utf-8');
      return JSON.parse(payload) as DecodedSocialToken;
    } catch {
      return {};
    }
  }

  private async findOrCreateSocialUser(
    data: { email: string; firstName: string; lastName: string },
    provider: string,
  ) {
    let user = await this.userRepository.findOne({
      where: { email: data.email },
    });

    if (!user) {
      const randomPassword = await bcrypt.hash(
        require('crypto').randomBytes(32).toString('hex'),
        10,
      );

      user = this.userRepository.create({
        firstName: data.firstName,
        lastName: data.lastName,
        email: data.email,
        passwordHash: randomPassword,
        emailVerified: true,
      }) as unknown as User;

      user = await this.userRepository.save(user) as unknown as User;

      const profile = this.profileRepository.create({
        userId: user.id,
      });
      await this.profileRepository.save(profile);

      await this.lgpdService.logProcessing(
        user.id,
        `social_register_${provider}`,
        'auth',
        `Conta criada via ${provider}`,
        'execução de contrato',
        'system',
      );
    }

    user.lastLogin = new Date();
    await this.userRepository.save(user);

    const tokens = this.generateTokens(user);

    return {
      user: {
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        avatar: user.avatar,
      },
      ...tokens,
    };
  }

  private generateTokens(user: User) {
    const payload = { sub: user.id, email: user.email };

    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: '7d',
      secret: this.configService.get<string>('JWT_SECRET') + '_refresh',
    });

    return { accessToken, refreshToken };
  }
}

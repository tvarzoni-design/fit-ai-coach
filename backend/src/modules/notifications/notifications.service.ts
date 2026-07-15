import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { FirebaseService } from './firebase.service';

interface DeviceTokenRecord {
  fcmToken: string;
  platform: string;
  registeredAt: Date;
  lastSeenAt: Date;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly deviceTokens = new Map<string, DeviceTokenRecord[]>();

  constructor(
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
    private firebaseService: FirebaseService,
  ) {}

  async findAllByUser(userId: string): Promise<Notification[]> {
    return this.notificationRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 50,
    });
  }

  async getUnreadCount(userId: string): Promise<number> {
    return this.notificationRepository.count({
      where: { userId, read: false },
    });
  }

  async markAsRead(id: string): Promise<void> {
    await this.notificationRepository.update(id, { read: true });
  }

  async markAllAsRead(userId: string): Promise<void> {
    await this.notificationRepository.update(
      { userId, read: false },
      { read: true },
    );
  }

  async create(userId: string, data: Partial<Notification>): Promise<Notification> {
    const notification = this.notificationRepository.create({ userId, ...data });
    return this.notificationRepository.save(notification);
  }

  async sendPushNotification(
    userId: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<boolean> {
    try {
      // Get user's FCM token from database
      const userToken = await this.getUserFcmToken(userId);
      if (!userToken) {
        this.logger.warn(`No FCM token found for user ${userId}`);
        return false;
      }

      // Send push notification
      const success = await this.firebaseService.sendPushNotification(
        userToken,
        title,
        body,
        data,
      );

      // Save notification to database
      await this.create(userId, {
        title,
        message: body,
        type: (data?.type as any) || 'general',
        sent: true,
      } as any);

      return success;
    } catch (error) {
      this.logger.error('Failed to send push notification', error);
      return false;
    }
  }

  async sendWorkoutReminder(userId: string): Promise<boolean> {
    return this.sendPushNotification(
      userId,
      'Hora de treinar! 💪',
      'Seu treino de hoje está esperando por você!',
      { type: 'workout_reminder' },
    );
  }

  async sendAchievementUnlocked(userId: string, achievementName: string): Promise<boolean> {
    return this.sendPushNotification(
      userId,
      'Conquista desbloqueada! 🏆',
      `Você desbloqueou: ${achievementName}`,
      { type: 'achievement', achievement: achievementName },
    );
  }

  async sendDailyTip(userId: string, tip: string): Promise<boolean> {
    return this.sendPushNotification(
      userId,
      'Dica do Coach IA 🧠',
      tip,
      { type: 'daily_tip' },
    );
  }

  async registerDeviceToken(userId: string, fcmToken: string, platform: string = 'mobile'): Promise<void> {
    const tokens = this.deviceTokens.get(userId) ?? [];

    const existingIndex = tokens.findIndex((t) => t.fcmToken === fcmToken);
    if (existingIndex >= 0) {
      tokens[existingIndex].lastSeenAt = new Date();
      tokens[existingIndex].platform = platform;
    } else {
      tokens.push({
        fcmToken,
        platform,
        registeredAt: new Date(),
        lastSeenAt: new Date(),
      });
    }

    this.deviceTokens.set(userId, tokens);
    this.logger.log(`Dispositivo registrado para o usuário ${userId} (${platform})`);
  }

  async removeDeviceToken(userId: string, fcmToken: string): Promise<void> {
    const tokens = this.deviceTokens.get(userId) ?? [];
    const filtered = tokens.filter((t) => t.fcmToken !== fcmToken);
    this.deviceTokens.set(userId, filtered);
    this.logger.log(`Dispositivo removido para o usuário ${userId}`);
  }

  async getUserDeviceTokens(userId: string): Promise<DeviceTokenRecord[]> {
    return this.deviceTokens.get(userId) ?? [];
  }

  private async getUserFcmToken(userId: string): Promise<string | null> {
    const tokens = this.deviceTokens.get(userId);
    if (!tokens || tokens.length === 0) {
      return null;
    }
    return tokens[0].fcmToken;
  }

  async remove(id: string): Promise<void> {
    await this.notificationRepository.delete(id);
  }

  async getSmartNotifications(userId: string): Promise<any[]> {
    return [
      {
        id: 'sn-001',
        title: 'Lembrete de treino',
        description: 'Diário às 17:00',
        enabled: true,
        time: '17:00',
        days: 'Seg, Ter, Qua, Qui, Sex',
        type: 'reminder',
      },
      {
        id: 'sn-002',
        title: 'Lembrete de água',
        description: 'A cada 2 horas',
        enabled: true,
        time: 'A cada 2h',
        days: 'Todos',
        type: 'water',
      },
      {
        id: 'sn-003',
        title: 'Dica do Coach IA',
        description: 'Diário às 08:00',
        enabled: true,
        time: '08:00',
        days: 'Todos',
        type: 'ai_tip',
      },
      {
        id: 'sn-004',
        title: 'Lembrete de pesagem',
        description: 'Toda segunda às 07:00',
        enabled: false,
        time: '07:00',
        days: 'Segunda',
        type: 'weigh_in',
      },
      {
        id: 'sn-005',
        title: 'Motivação semanal',
        description: 'Domingo às 20:00',
        enabled: true,
        time: '20:00',
        days: 'Domingo',
        type: 'motivation',
      },
    ];
  }

  async toggleSmartNotification(userId: string, notificationId: string): Promise<any> {
    const notifications = await this.getSmartNotifications(userId);
    const notif = notifications.find(n => n.id === notificationId);
    if (notif) {
      notif.enabled = !notif.enabled;
    }
    return notif;
  }
}

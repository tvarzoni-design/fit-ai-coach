import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotificationsService } from './notifications.service';
import { FirebaseService } from './firebase.service';
import { Notification } from './entities/notification.entity';
import { Repository } from 'typeorm';

describe('NotificationsService', () => {
  let service: NotificationsService;
  let repository: Repository<Notification>;

  const mockRepository = {
    findOne: jest.fn(),
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    count: jest.fn(),
  };

  const mockFirebaseService = {
    sendPushNotification: jest.fn(),
    sendToTopic: jest.fn(),
    sendToMultipleTokens: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsService,
        {
          provide: getRepositoryToken(Notification),
          useValue: mockRepository,
        },
        {
          provide: FirebaseService,
          useValue: mockFirebaseService,
        },
      ],
    }).compile();

    service = module.get<NotificationsService>(NotificationsService);
    repository = module.get<Repository<Notification>>(getRepositoryToken(Notification));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAllByUser', () => {
    it('should return notifications for a user', async () => {
      const notifications = [
        { id: '1', userId: 'user-1', title: 'Test' },
        { id: '2', userId: 'user-1', title: 'Test 2' },
      ];

      mockRepository.find.mockResolvedValue(notifications);

      const result = await service.findAllByUser('user-1');

      expect(result).toEqual(notifications);
    });
  });

  describe('getUnreadCount', () => {
    it('should return unread notification count', async () => {
      mockRepository.count.mockResolvedValue(5);

      const result = await service.getUnreadCount('user-1');

      expect(result).toEqual(5);
    });
  });

  describe('markAsRead', () => {
    it('should mark notification as read', async () => {
      mockRepository.update.mockResolvedValue(undefined);

      await expect(service.markAsRead('1')).resolves.toBeUndefined();
    });
  });

  describe('markAllAsRead', () => {
    it('should mark all notifications as read for a user', async () => {
      mockRepository.update.mockResolvedValue(undefined);

      await expect(service.markAllAsRead('user-1')).resolves.toBeUndefined();
    });
  });

  describe('create', () => {
    it('should create a new notification', async () => {
      const notificationData = {
        title: 'Test',
        body: 'Test body',
        type: 'workout',
      };

      mockRepository.create.mockReturnValue(notificationData);
      mockRepository.save.mockResolvedValue({ id: '1', ...notificationData });

      const result = await service.create('user-1', notificationData);

      expect(result).toBeDefined();
      expect(result.id).toBeDefined();
    });
  });

  describe('sendWorkoutReminder', () => {
    it('should send workout reminder', async () => {
      mockFirebaseService.sendPushNotification.mockResolvedValue(true);
      mockRepository.create.mockReturnValue({});
      mockRepository.save.mockResolvedValue({});

      const result = await service.sendWorkoutReminder('user-1');

      expect(result).toBeDefined();
    });
  });

  describe('sendAchievementUnlocked', () => {
    it('should send achievement notification', async () => {
      mockFirebaseService.sendPushNotification.mockResolvedValue(true);
      mockRepository.create.mockReturnValue({});
      mockRepository.save.mockResolvedValue({});

      const result = await service.sendAchievementUnlocked('user-1', 'First Workout');

      expect(result).toBeDefined();
    });
  });
});

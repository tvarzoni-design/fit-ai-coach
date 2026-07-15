import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { AiCoachService } from './ai-coach.service';
import { AiConversation } from './entities/ai-conversation.entity';
import { AiMessage } from './entities/ai-message.entity';
import { AiMemory } from './entities/ai-memory.entity';
import { AiPrediction } from './entities/ai-prediction.entity';
import { AiAlert } from './entities/ai-alert.entity';
import { UserBehavior } from './entities/user-behavior.entity';
import { UsersService } from '../users/users.service';

describe('AiCoachService', () => {
  let service: AiCoachService;

  const mockRepository = {
    findOne: jest.fn(),
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    count: jest.fn(),
  };

  const mockUsersService = {
    findById: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AiCoachService,
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
        {
          provide: getRepositoryToken(AiConversation),
          useValue: mockRepository,
        },
        {
          provide: getRepositoryToken(AiMessage),
          useValue: mockRepository,
        },
        {
          provide: getRepositoryToken(AiMemory),
          useValue: mockRepository,
        },
        {
          provide: getRepositoryToken(AiPrediction),
          useValue: mockRepository,
        },
        {
          provide: getRepositoryToken(AiAlert),
          useValue: mockRepository,
        },
        {
          provide: getRepositoryToken(UserBehavior),
          useValue: mockRepository,
        },
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
      ],
    }).compile();

    service = module.get<AiCoachService>(AiCoachService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('chat', () => {
    it('should create a new conversation and return response', async () => {
      const userId = 'user-123';
      const message = 'Olá, como estou indo nos treinos?';

      mockRepository.findOne.mockResolvedValue(null);
      mockRepository.create.mockReturnValue({});
      mockRepository.save.mockResolvedValue({ id: 'conv-123' });
      mockUsersService.findById.mockResolvedValue({
        id: userId,
        firstName: 'Test',
        profile: { goal: 'hypertrophy' },
      });
      mockConfigService.get.mockReturnValue('test-api-key');

      // Mock OpenAI response
      jest.spyOn(service as any, 'generateResponse').mockResolvedValue('Olá! Você está indo muito bem!');

      const result = await service.chat(userId, message);

      expect(result).toBeDefined();
      expect(result.response).toBeDefined();
    });
  });

  describe('generateWorkout', () => {
    it('should generate a workout plan', async () => {
      const userId = 'user-123';

      mockUsersService.findById.mockResolvedValue({
        id: userId,
        firstName: 'Test',
        profile: {
          goal: 'hypertrophy',
          experienceLevel: 'intermediate',
          trainingDays: 4,
          trainingTime: 60,
        },
      });
      mockConfigService.get.mockReturnValue('test-api-key');

      // Mock OpenAI response
      jest.spyOn(service as any, 'generateResponse').mockResolvedValue(JSON.stringify({
        name: 'Treino de Hipertrofia',
        exercises: [
          { name: 'Supino Reto', sets: 4, reps: '10-12', rest: '90' },
        ],
      }));

      const result = await service.generateWorkout(userId);

      expect(result).toBeDefined();
    });
  });

  describe('getDailyCoach', () => {
    it('should return daily coach message', async () => {
      const userId = 'user-123';

      mockUsersService.findById.mockResolvedValue({
        id: userId,
        firstName: 'Test',
      });
      mockRepository.find.mockResolvedValue([]);
      mockConfigService.get.mockReturnValue('test-api-key');

      // Mock OpenAI response
      jest.spyOn(service as any, 'generateResponse').mockResolvedValue('Bom dia! Vamos treinar hoje?');

      const result = await service.getDailyCoach(userId);

      expect(result).toBeDefined();
      expect(result.message).toBeDefined();
    });
  });
});

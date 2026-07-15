import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiConversation } from './entities/ai-conversation.entity';
import { AiMessage } from './entities/ai-message.entity';
import { AiMemory } from './entities/ai-memory.entity';
import { AiPrediction } from './entities/ai-prediction.entity';
import { AiAlert } from './entities/ai-alert.entity';
import { UserBehavior } from './entities/user-behavior.entity';
import { AiCoachService } from './ai-coach.service';
import { AiCoachController } from './ai-coach.controller';
import { UsersModule } from '../users/users.module';
import { WorkoutsModule } from '../workouts/workouts.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AiConversation,
      AiMessage,
      AiMemory,
      AiPrediction,
      AiAlert,
      UserBehavior,
    ]),
    UsersModule,
    WorkoutsModule,
  ],
  controllers: [AiCoachController],
  providers: [AiCoachService],
  exports: [AiCoachService],
})
export class AiCoachModule {}

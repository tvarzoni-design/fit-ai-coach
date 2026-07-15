import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LgpdController } from './lgpd.controller';
import { LgpdService } from './lgpd.service';
import { UserConsent } from './entities/user-consent.entity';
import { DataProcessingLog } from './entities/data-processing-log.entity';
import { User } from '../users/entities/user.entity';
import { UserProfile } from '../users/entities/user-profile.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserConsent, DataProcessingLog, User, UserProfile])],
  controllers: [LgpdController],
  providers: [LgpdService],
  exports: [LgpdService],
})
export class LgpdModule {}

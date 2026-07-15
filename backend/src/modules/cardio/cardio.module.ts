import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CardioSession } from './entities/cardio-session.entity';
import { CardioService } from './cardio.service';
import { CardioController } from './cardio.controller';

@Module({
  imports: [TypeOrmModule.forFeature([CardioSession])],
  controllers: [CardioController],
  providers: [CardioService],
  exports: [CardioService],
})
export class CardioModule {}

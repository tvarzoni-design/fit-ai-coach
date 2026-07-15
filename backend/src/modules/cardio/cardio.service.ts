import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CardioSession } from './entities/cardio-session.entity';

@Injectable()
export class CardioService {
  constructor(
    @InjectRepository(CardioSession)
    private cardioRepository: Repository<CardioSession>,
  ) {}

  async findAllByUser(userId: string): Promise<CardioSession[]> {
    return this.cardioRepository.find({
      where: { userId },
      order: { date: 'DESC' },
    });
  }

  async findById(id: string): Promise<CardioSession | null> {
    return this.cardioRepository.findOne({ where: { id } });
  }

  async create(userId: string, data: Partial<CardioSession>): Promise<CardioSession> {
    const session = this.cardioRepository.create({
      userId,
      ...data,
    });
    return this.cardioRepository.save(session);
  }

  async getWeeklySummary(userId: string): Promise<any> {
    const sessions = await this.cardioRepository.find({
      where: { userId },
      order: { date: 'DESC' },
      take: 7,
    });

    const totalMinutes = sessions.reduce((sum, s) => sum + (s.duration || 0), 0);
    const totalCalories = sessions.reduce((sum, s) => sum + (s.calories || 0), 0);
    const totalDistance = sessions.reduce((sum, s) => sum + (s.distance || 0), 0);

    return {
      sessions: sessions.length,
      totalMinutes,
      totalCalories,
      totalDistance,
    };
  }

  async remove(id: string): Promise<void> {
    await this.cardioRepository.delete(id);
  }
}

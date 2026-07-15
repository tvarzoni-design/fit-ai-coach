import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Food } from './entities/food.entity';
import { MealLog } from './entities/meal-log.entity';
import { NutritionGoal } from './entities/nutrition-goal.entity';

@Injectable()
export class NutritionService {
  constructor(
    @InjectRepository(Food)
    private foodRepository: Repository<Food>,
    @InjectRepository(MealLog)
    private mealLogRepository: Repository<MealLog>,
    @InjectRepository(NutritionGoal)
    private nutritionGoalRepository: Repository<NutritionGoal>,
  ) {}

  async searchFoods(search?: string): Promise<Food[]> {
    const where: any = { status: true };
    if (search) {
      where.name = Like(`%${search}%`);
    }
    return this.foodRepository.find({ where, order: { name: 'ASC' }, take: 50 });
  }

  async getGoals(userId: string): Promise<NutritionGoal | null> {
    const goals = await this.nutritionGoalRepository.findOne({ where: { userId } });
    return goals || null;
  }

  async updateGoals(userId: string, data: Partial<NutritionGoal>): Promise<NutritionGoal> {
    let goals = await this.nutritionGoalRepository.findOne({ where: { userId } });
    if (!goals) {
      goals = this.nutritionGoalRepository.create({ userId });
    }
    Object.assign(goals, data);
    return this.nutritionGoalRepository.save(goals);
  }

  async logMeal(userId: string, data: Partial<MealLog>): Promise<MealLog> {
    const log = this.mealLogRepository.create({ userId, ...data });
    return this.mealLogRepository.save(log);
  }

  async getDailySummary(userId: string, date: string): Promise<any> {
    const logs = await this.mealLogRepository.find({
      where: { userId, date: date as any },
      relations: ['food'],
    });

    const total = logs.reduce(
      (acc, log) => ({
        calories: acc.calories + Number(log.calories || 0),
        protein: acc.protein + Number(log.protein || 0),
        carbs: acc.carbs + Number(log.carbs || 0),
        fat: acc.fat + Number(log.fat || 0),
      }),
      { calories: 0, protein: 0, carbs: 0, fat: 0 },
    );

    return { logs, total };
  }

  async getHistory(userId: string): Promise<MealLog[]> {
    return this.mealLogRepository.find({
      where: { userId },
      relations: ['food'],
      order: { createdAt: 'DESC' },
      take: 100,
    });
  }

  async removeMeal(id: string): Promise<void> {
    await this.mealLogRepository.delete(id);
  }
}

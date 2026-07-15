import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Food } from './food.entity';

@Entity('meal_logs')
export class MealLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'food_id' })
  foodId: string;

  @Column({ name: 'meal_type', length: 50, comment: 'breakfast, lunch, dinner, snack' })
  mealType: string;

  @Column({ type: 'decimal', precision: 6, scale: 2, default: 100, name: 'quantity' })
  quantity: number;

  @Column({ type: 'decimal', precision: 7, scale: 2 })
  calories: number;

  @Column({ type: 'decimal', precision: 6, scale: 2 })
  protein: number;

  @Column({ name: 'carbs', type: 'decimal', precision: 6, scale: 2 })
  carbs: number;

  @Column({ type: 'decimal', precision: 6, scale: 2 })
  fat: number;

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true })
  fiber: number;

  @Column({ type: 'date' })
  date: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Food)
  @JoinColumn({ name: 'food_id' })
  food: Food;
}

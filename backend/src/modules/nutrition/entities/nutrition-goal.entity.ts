import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('nutrition_goals')
export class NutritionGoal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'daily_calories', type: 'int', nullable: true })
  dailyCalories: number;

  @Column({ name: 'protein_target', type: 'decimal', precision: 6, scale: 2, nullable: true })
  proteinTarget: number;

  @Column({ name: 'carb_target', type: 'decimal', precision: 6, scale: 2, nullable: true })
  carbTarget: number;

  @Column({ name: 'fat_target', type: 'decimal', precision: 6, scale: 2, nullable: true })
  fatTarget: number;

  @Column({ name: 'water_target', type: 'int', nullable: true, comment: 'em ml' })
  waterTarget: number;

  @Column({ nullable: true })
  goal: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}

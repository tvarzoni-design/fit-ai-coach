import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

export enum Goal {
  HYPERTROPHY = 'hypertrophy',
  FAT_LOSS = 'fat_loss',
  DEFINITION = 'definition',
  STRENGTH = 'strength',
  HEALTH = 'health',
  CONDITIONING = 'conditioning',
}

export enum ExperienceLevel {
  BEGINNER = 'beginner',
  INTERMEDIATE = 'intermediate',
  ADVANCED = 'advanced',
}

export enum TrainingLocation {
  FULL_GYM = 'full_gym',
  SMALL_GYM = 'small_gym',
  HOME = 'home',
  CONDO = 'condo',
  OUTDOOR = 'outdoor',
}

@Entity('user_profiles')
export class UserProfile {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', unique: true })
  userId: string;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  height: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  weight: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, name: 'target_weight' })
  targetWeight: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, name: 'body_fat' })
  bodyFat: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, name: 'muscle_mass' })
  muscleMass: number;

  @Column({ type: 'enum', enum: Goal, nullable: true })
  goal: Goal;

  @Column({ name: 'secondary_goals', type: 'simple-array', nullable: true })
  secondaryGoals: Goal[];

  @Column({ type: 'enum', enum: ExperienceLevel, nullable: true, name: 'experience_level' })
  experienceLevel: ExperienceLevel;

  @Column({ name: 'training_days', type: 'int', default: 3 })
  trainingDays: number;

  @Column({ name: 'training_time', type: 'int', default: 60, comment: 'Tempo disponível em minutos' })
  trainingTime: number;

  @Column({ type: 'enum', enum: TrainingLocation, nullable: true, name: 'training_location' })
  trainingLocation: TrainingLocation;

  @Column({ name: 'equipment_available', type: 'simple-array', nullable: true })
  equipmentAvailable: string[];

  @Column({ name: 'injuries', type: 'simple-array', nullable: true })
  injuries: string[];

  @Column({ name: 'sleep_hours', type: 'decimal', precision: 3, scale: 1, nullable: true })
  sleepHours: number;

  @Column({ name: 'stress_level', type: 'int', nullable: true })
  stressLevel: number;

  @Column({ name: 'training_preferences', type: 'simple-array', nullable: true })
  trainingPreferences: string[];

  @Column({ name: 'onboarding_completed', default: false })
  onboardingCompleted: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToOne(() => User, (user) => user.profile)
  @JoinColumn({ name: 'user_id' })
  user: User;
}

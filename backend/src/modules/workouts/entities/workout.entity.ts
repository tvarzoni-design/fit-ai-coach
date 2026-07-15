import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { WorkoutExercise } from './workout-exercise.entity';

export enum WorkoutStatus {
  ACTIVE = 'active',
  COMPLETED = 'completed',
  PAUSED = 'paused',
  CANCELLED = 'cancelled',
}

export enum GeneratedBy {
  AI = 'ai',
  USER = 'user',
  ADMIN = 'admin',
}

@Entity('workouts')
export class Workout {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ length: 200 })
  name: string;

  @Column({ nullable: true })
  goal: string;

  @Column({ name: 'week_number', type: 'int', default: 1 })
  weekNumber: number;

  @Column({ type: 'int', nullable: true, name: 'estimated_duration' })
  estimatedDuration: number;

  @Column({ type: 'enum', enum: WorkoutStatus, default: WorkoutStatus.ACTIVE })
  status: WorkoutStatus;

  @Column({ type: 'enum', enum: GeneratedBy, default: GeneratedBy.AI, name: 'generated_by' })
  generatedBy: GeneratedBy;

  @Column({ nullable: true })
  notes: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.achievements)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @OneToMany(() => WorkoutExercise, (we) => we.workout)
  exercises: WorkoutExercise[];
}

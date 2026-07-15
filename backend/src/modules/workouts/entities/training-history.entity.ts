import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Workout } from '../../workouts/entities/workout.entity';
import { Exercise } from '../../exercises/entities/exercise.entity';

@Entity('training_history')
export class TrainingHistory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'workout_id', nullable: true })
  workoutId: string;

  @Column({ name: 'exercise_id' })
  exerciseId: string;

  @Column({ type: 'date' })
  date: Date;

  @Column({ name: 'sets_completed', type: 'int' })
  setsCompleted: number;

  @Column({ name: 'repetitions_done', length: 50 })
  repetitionsDone: string;

  @Column({ name: 'weight_used', type: 'decimal', precision: 6, scale: 2, nullable: true })
  weightUsed: number;

  @Column({ type: 'int', nullable: true })
  rpe: number;

  @Column({ type: 'int', nullable: true })
  rir: number;

  @Column({ name: 'pain_level', type: 'int', nullable: true })
  painLevel: number;

  @Column({ nullable: true })
  notes: string;

  @Column({ name: 'set_number', type: 'int' })
  setNumber: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Workout)
  @JoinColumn({ name: 'workout_id' })
  workout: Workout;

  @ManyToOne(() => Exercise)
  @JoinColumn({ name: 'exercise_id' })
  exercise: Exercise;
}

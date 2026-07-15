import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Workout } from './workout.entity';
import { Exercise } from '../../exercises/entities/exercise.entity';

@Entity('workout_exercises')
export class WorkoutExercise {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'workout_id' })
  workoutId: string;

  @Column({ name: 'exercise_id', nullable: true })
  exerciseId: string;

  @Column({ nullable: true, length: 200 })
  name: string;

  @Column({ name: 'order_number', type: 'int' })
  orderNumber: number;

  @Column({ type: 'int', default: 3 })
  sets: number;

  @Column({ length: 20, default: '10', comment: 'Pode ser número ou faixa como 8-12' })
  repetitions: string;

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true, name: 'target_weight' })
  targetWeight: number;

  @Column({ name: 'rest_time', type: 'int', default: 90, comment: 'Descanso em segundos' })
  restTime: number;

  @Column({ length: 10, nullable: true, comment: 'Ex: 3-1-1-0' })
  tempo: string;

  @Column({ type: 'int', nullable: true, name: 'rpe_target' })
  rpeTarget: number;

  @Column({ type: 'int', nullable: true, name: 'rir_target' })
  rirTarget: number;

  @Column({ nullable: true })
  notes: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => Workout)
  @JoinColumn({ name: 'workout_id' })
  workout: Workout;

  @ManyToOne(() => Exercise)
  @JoinColumn({ name: 'exercise_id' })
  exercise: Exercise;
}

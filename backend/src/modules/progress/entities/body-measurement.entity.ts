import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('body_measurements')
export class BodyMeasurement {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  weight: number;

  @Column({ name: 'body_fat', type: 'decimal', precision: 5, scale: 2, nullable: true })
  bodyFat: number;

  @Column({ name: 'muscle_mass', type: 'decimal', precision: 5, scale: 2, nullable: true })
  muscleMass: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  chest: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  waist: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  hip: number;

  @Column({ name: 'arm_left', type: 'decimal', precision: 5, scale: 2, nullable: true })
  armLeft: number;

  @Column({ name: 'arm_right', type: 'decimal', precision: 5, scale: 2, nullable: true })
  armRight: number;

  @Column({ name: 'thigh_left', type: 'decimal', precision: 5, scale: 2, nullable: true })
  thighLeft: number;

  @Column({ name: 'thigh_right', type: 'decimal', precision: 5, scale: 2, nullable: true })
  thighRight: number;

  @Column({ name: 'calf_left', type: 'decimal', precision: 5, scale: 2, nullable: true })
  calfLeft: number;

  @Column({ name: 'calf_right', type: 'decimal', precision: 5, scale: 2, nullable: true })
  calfRight: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  neck: number;

  @Column({ nullable: true })
  observation: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('cardio_sessions')
export class CardioSession {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ length: 50 })
  type: string;

  @Column({ type: 'int', comment: 'Duração em minutos' })
  duration: number;

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true })
  distance: number;

  @Column({ type: 'decimal', precision: 5, scale: 1, nullable: true })
  speed: number;

  @Column({ type: 'decimal', precision: 5, scale: 1, nullable: true })
  inclination: number;

  @Column({ name: 'heart_rate', type: 'int', nullable: true })
  heartRate: number;

  @Column({ type: 'int', nullable: true })
  calories: number;

  @Column({ length: 100, nullable: true })
  location: string;

  @Column({ type: 'int', nullable: true, comment: 'Zona cardíaca 1-5' })
  zone: number;

  @Column({ type: 'int', nullable: true, comment: 'Percepção de esforço 1-10' })
  effortLevel: number;

  @Column({ type: 'date' })
  date: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}

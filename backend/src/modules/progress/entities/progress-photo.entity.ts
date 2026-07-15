import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('progress_photos')
export class ProgressPhoto {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'front_url', length: 500, nullable: true })
  frontUrl: string;

  @Column({ name: 'side_url', length: 500, nullable: true })
  sideUrl: string;

  @Column({ name: 'back_url', length: 500, nullable: true })
  backUrl: string;

  @Column({ name: 'analysis_status', length: 50, default: 'pending' })
  analysisStatus: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}

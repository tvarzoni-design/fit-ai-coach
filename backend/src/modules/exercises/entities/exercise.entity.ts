import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('exercises')
export class Exercise {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 200 })
  name: string;

  @Column({ name: 'english_name', length: 200, nullable: true })
  englishName: string;

  @Column({ name: 'main_muscle', length: 100 })
  mainMuscle: string;

  @Column({ name: 'secondary_muscles', type: 'simple-array', nullable: true })
  secondaryMuscles: string[];

  @Column({ length: 100, nullable: true })
  equipment: string;

  @Column({ length: 50, nullable: true })
  difficulty: string;

  @Column({ name: 'movement_type', length: 50, nullable: true })
  movementType: string;

  @Column({ nullable: true })
  description: string;

  @Column({ type: 'text', nullable: true })
  execution: string;

  @Column({ length: 500, nullable: true })
  breathing: string;

  @Column({ name: 'common_errors', type: 'text', nullable: true })
  commonErrors: string;

  @Column({ type: 'text', nullable: true })
  tips: string;

  @Column({ name: 'video_url', length: 500, nullable: true })
  videoUrl: string;

  @Column({ name: 'thumbnail_url', length: 500, nullable: true })
  thumbnailUrl: string;

  @Column({ name: 'gif_url', length: 500, nullable: true })
  gifUrl: string;

  @Column({ name: 'contraindications', type: 'text', nullable: true })
  contraindications: string;

  @Column({ name: 'is_composite', default: false })
  isComposite: boolean;

  @Column({ name: 'is_unilateral', default: false })
  isUnilateral: boolean;

  @Column({ name: 'note_hypertrophy', type: 'int', default: 0 })
  noteHypertrophy: number;

  @Column({ name: 'note_strength', type: 'int', default: 0 })
  noteStrength: number;

  @Column({ name: 'note_fat_loss', type: 'int', default: 0 })
  noteFatLoss: number;

  @Column({ name: 'note_safety', type: 'int', default: 0 })
  noteSafety: number;

  @Column({ name: 'note_beginners', type: 'int', default: 0 })
  noteBeginners: number;

  @Column({ default: true })
  status: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

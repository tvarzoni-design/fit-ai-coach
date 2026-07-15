import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('foods')
export class Food {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 200 })
  name: string;

  @Column({ length: 100, nullable: true })
  category: string;

  @Column({ name: 'serving_size', length: 50, nullable: true })
  servingSize: string;

  @Column({ name: 'serving_grams', type: 'decimal', precision: 6, scale: 2, default: 100 })
  servingGrams: number;

  @Column({ type: 'decimal', precision: 7, scale: 2 })
  calories: number;

  @Column({ type: 'decimal', precision: 6, scale: 2 })
  protein: number;

  @Column({ name: 'carbohydrates', type: 'decimal', precision: 6, scale: 2 })
  carbohydrates: number;

  @Column({ type: 'decimal', precision: 6, scale: 2 })
  fat: number;

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true })
  fiber: number;

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true })
  sodium: number;

  @Column({ type: 'decimal', precision: 6, scale: 2, nullable: true })
  sugar: number;

  @Column({ default: true })
  status: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

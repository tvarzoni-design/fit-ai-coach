import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Exercise } from './entities/exercise.entity';
import { MuscleGroup } from './entities/muscle-group.entity';

@Injectable()
export class ExercisesService {
  constructor(
    @InjectRepository(Exercise)
    private exerciseRepository: Repository<Exercise>,
    @InjectRepository(MuscleGroup)
    private muscleGroupRepository: Repository<MuscleGroup>,
  ) {}

  async findAll(filters?: {
    muscle?: string;
    equipment?: string;
    difficulty?: string;
    search?: string;
  }): Promise<Exercise[]> {
    const where: any = { status: true };

    if (filters?.muscle) {
      where.mainMuscle = filters.muscle;
    }
    if (filters?.equipment) {
      where.equipment = filters.equipment;
    }
    if (filters?.difficulty) {
      where.difficulty = filters.difficulty;
    }
    if (filters?.search) {
      where.name = Like(`%${filters.search}%`);
    }

    return this.exerciseRepository.find({
      where,
      order: { name: 'ASC' },
    });
  }

  async findById(id: string): Promise<Exercise> {
    const exercise = await this.exerciseRepository.findOne({ where: { id } });
    if (!exercise) {
      throw new NotFoundException('Exercício não encontrado');
    }
    return exercise;
  }

  async findByMuscle(muscle: string): Promise<Exercise[]> {
    return this.exerciseRepository.find({
      where: { mainMuscle: muscle, status: true },
      order: { noteHypertrophy: 'DESC' },
    });
  }

  async getMuscleGroups(): Promise<MuscleGroup[]> {
    return this.muscleGroupRepository.find({ order: { name: 'ASC' } });
  }

  async create(data: Partial<Exercise>): Promise<Exercise> {
    const exercise = this.exerciseRepository.create(data);
    return this.exerciseRepository.save(exercise);
  }

  async update(id: string, data: Partial<Exercise>): Promise<Exercise> {
    const exercise = await this.findById(id);
    Object.assign(exercise, data);
    return this.exerciseRepository.save(exercise);
  }

  async remove(id: string): Promise<void> {
    await this.exerciseRepository.delete(id);
  }
}

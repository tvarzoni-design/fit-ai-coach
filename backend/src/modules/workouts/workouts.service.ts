import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Workout } from './entities/workout.entity';
import { WorkoutExercise } from './entities/workout-exercise.entity';
import { TrainingHistory } from './entities/training-history.entity';

@Injectable()
export class WorkoutsService {
  constructor(
    @InjectRepository(Workout)
    private workoutRepository: Repository<Workout>,
    @InjectRepository(WorkoutExercise)
    private workoutExerciseRepository: Repository<WorkoutExercise>,
    @InjectRepository(TrainingHistory)
    private trainingHistoryRepository: Repository<TrainingHistory>,
  ) {}

  async findAllByUser(userId: string): Promise<Workout[]> {
    return this.workoutRepository.find({
      where: { userId },
      relations: ['exercises'],
      order: { createdAt: 'DESC' },
    });
  }

  async findById(id: string): Promise<Workout> {
    const workout = await this.workoutRepository.findOne({
      where: { id },
      relations: ['exercises', 'exercises.exercise'],
    });

    if (!workout) {
      throw new NotFoundException('Treino não encontrado');
    }

    return workout;
  }

  async create(userId: string, data: Partial<Workout>): Promise<Workout> {
    const workout = this.workoutRepository.create({
      userId,
      ...data,
    });
    return this.workoutRepository.save(workout);
  }

  async update(id: string, data: Partial<Workout>): Promise<Workout> {
    await this.workoutRepository.update(id, data);
    return this.findById(id);
  }

  async addExercise(workoutId: string, exerciseData: Partial<WorkoutExercise>): Promise<WorkoutExercise> {
    const exercise = this.workoutExerciseRepository.create({
      workoutId,
      ...exerciseData,
    });
    return this.workoutExerciseRepository.save(exercise);
  }

  async recordSet(userId: string, data: {
    workoutId?: string;
    exerciseId: string;
    setNumber: number;
    weight: number;
    repetitions: string;
    rpe?: number;
    rir?: number;
    painLevel?: number;
    notes?: string;
  }): Promise<TrainingHistory> {
    const history = this.trainingHistoryRepository.create({
      userId,
      workoutId: data.workoutId,
      exerciseId: data.exerciseId,
      date: new Date(),
      setNumber: data.setNumber,
      setsCompleted: 1,
      repetitionsDone: data.repetitions,
      weightUsed: data.weight,
      rpe: data.rpe,
      rir: data.rir,
      painLevel: data.painLevel,
      notes: data.notes,
    });

    return this.trainingHistoryRepository.save(history);
  }

  async getHistory(userId: string, limit = 50): Promise<TrainingHistory[]> {
    return this.trainingHistoryRepository.find({
      where: { userId },
      relations: ['exercise'],
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  async getExerciseHistory(userId: string, exerciseId: string): Promise<TrainingHistory[]> {
    return this.trainingHistoryRepository.find({
      where: { userId, exerciseId },
      order: { date: 'DESC', setNumber: 'ASC' },
      take: 100,
    });
  }

  async remove(id: string): Promise<void> {
    await this.workoutRepository.delete(id);
  }
}

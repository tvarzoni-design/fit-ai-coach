import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BodyMeasurement } from './entities/body-measurement.entity';
import { ProgressPhoto } from './entities/progress-photo.entity';

@Injectable()
export class ProgressService {
  constructor(
    @InjectRepository(BodyMeasurement)
    private measurementRepository: Repository<BodyMeasurement>,
    @InjectRepository(ProgressPhoto)
    private photoRepository: Repository<ProgressPhoto>,
  ) {}

  async getMeasurements(userId: string): Promise<BodyMeasurement[]> {
    return this.measurementRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async addMeasurement(userId: string, data: Partial<BodyMeasurement>): Promise<BodyMeasurement> {
    const measurement = this.measurementRepository.create({ userId, ...data });
    return this.measurementRepository.save(measurement);
  }

  async getPhotos(userId: string): Promise<ProgressPhoto[]> {
    return this.photoRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async addPhoto(userId: string, data: Partial<ProgressPhoto>): Promise<ProgressPhoto> {
    const photo = this.photoRepository.create({ userId, ...data });
    return this.photoRepository.save(photo);
  }

  async getLatestMeasurement(userId: string): Promise<BodyMeasurement | null> {
    return this.measurementRepository.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async removeMeasurement(id: string): Promise<void> {
    await this.measurementRepository.delete(id);
  }
}

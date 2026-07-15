import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Exercises (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('v1');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
        transformOptions: { enableImplicitConversion: true },
      }),
    );
    await app.init();
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  describe('GET /v1/exercises', () => {
    it('should return an array of exercises', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/exercises')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    it('should filter exercises by muscle group', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/exercises?muscle=chest')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    it('should filter exercises by equipment', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/exercises?equipment=barbell')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    it('should filter exercises by difficulty', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/exercises?difficulty=beginner')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    it('should search exercises by name', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/exercises?search=bench')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    it('should combine multiple filters', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/exercises?muscle=chest&difficulty=beginner')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });
  });

  describe('GET /v1/exercises/muscles', () => {
    it('should return muscle groups', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/exercises/muscles')
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });
  });
});

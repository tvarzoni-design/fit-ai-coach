import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Community (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;
  let postId: string;

  const testEmail = `e2e-community-${Date.now()}@test.com`;
  const testPassword = 'TestPass@123';

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

    const registerResponse = await request(app.getHttpServer())
      .post('/v1/auth/register')
      .send({
        firstName: 'CommunityTest',
        email: testEmail,
        password: testPassword,
      });

    accessToken = registerResponse.body.accessToken;
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  describe('POST /v1/community/posts', () => {
    it('should create a community post', async () => {
      const response = await request(app.getHttpServer())
        .post('/v1/community/posts')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          content: 'Treinei pesado hoje! Nova record no supino!',
        })
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body.content).toBe('Treinei pesado hoje! Nova record no supino!');

      postId = response.body.id;
    });

    it('should return 401 without auth token', async () => {
      await request(app.getHttpServer())
        .post('/v1/community/posts')
        .send({
          content: 'Post without auth',
        })
        .expect(401);
    });

    it('should return 401 with invalid token', async () => {
      await request(app.getHttpServer())
        .post('/v1/community/posts')
        .set('Authorization', 'Bearer invalid-token')
        .send({
          content: 'Post with invalid token',
        })
        .expect(401);
    });
  });

  describe('GET /v1/community/posts', () => {
    it('should list community posts (public endpoint)', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/community/posts')
        .expect(200);

      expect(response.body).toBeDefined();
    });

    it('should support pagination', async () => {
      const response = await request(app.getHttpServer())
        .get('/v1/community/posts?page=1&limit=10')
        .expect(200);

      expect(response.body).toBeDefined();
    });
  });

  describe('GET /v1/community/posts/:id', () => {
    it('should get a single post by id', async () => {
      const response = await request(app.getHttpServer())
        .get(`/v1/community/posts/${postId}`)
        .expect(200);

      expect(response.body).toHaveProperty('id');
      expect(response.body.id).toBe(postId);
    });
  });
});

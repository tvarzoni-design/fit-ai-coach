"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const common_1 = require("@nestjs/common");
const request = require("supertest");
const app_module_1 = require("../src/app.module");
describe('Workouts (e2e)', () => {
    let app;
    let accessToken;
    let userId;
    let workoutId;
    const testEmail = `e2e-workouts-${Date.now()}@test.com`;
    const testPassword = 'TestPass@123';
    beforeAll(async () => {
        const moduleFixture = await testing_1.Test.createTestingModule({
            imports: [app_module_1.AppModule],
        }).compile();
        app = moduleFixture.createNestApplication();
        app.setGlobalPrefix('v1');
        app.useGlobalPipes(new common_1.ValidationPipe({
            whitelist: true,
            forbidNonWhitelisted: true,
            transform: true,
            transformOptions: { enableImplicitConversion: true },
        }));
        await app.init();
        const registerResponse = await request(app.getHttpServer())
            .post('/v1/auth/register')
            .send({
            firstName: 'WorkoutTest',
            email: testEmail,
            password: testPassword,
        });
        accessToken = registerResponse.body.accessToken;
        userId = registerResponse.body.user.id;
    }, 30000);
    afterAll(async () => {
        await app.close();
    });
    describe('POST /v1/workouts', () => {
        it('should create a new workout', async () => {
            const response = await request(app.getHttpServer())
                .post('/v1/workouts')
                .set('Authorization', `Bearer ${accessToken}`)
                .send({
                name: 'Treino A - Peito e Tríceps',
                description: 'Treino focado em peito e tríceps',
                dayOfWeek: 1,
            })
                .expect(201);
            expect(response.body).toHaveProperty('id');
            expect(response.body.name).toBe('Treino A - Peito e Tríceps');
            expect(response.body.userId).toBe(userId);
            workoutId = response.body.id;
        });
        it('should return 401 without auth token', async () => {
            await request(app.getHttpServer())
                .post('/v1/workouts')
                .send({
                name: 'Unauthorized Workout',
            })
                .expect(401);
        });
        it('should return 401 with invalid token', async () => {
            await request(app.getHttpServer())
                .post('/v1/workouts')
                .set('Authorization', 'Bearer invalid-token')
                .send({
                name: 'Invalid Token Workout',
            })
                .expect(401);
        });
    });
    describe('GET /v1/workouts', () => {
        it('should list workouts for authenticated user', async () => {
            const response = await request(app.getHttpServer())
                .get('/v1/workouts')
                .set('Authorization', `Bearer ${accessToken}`)
                .expect(200);
            expect(Array.isArray(response.body)).toBe(true);
            expect(response.body.length).toBeGreaterThan(0);
            expect(response.body[0]).toHaveProperty('id');
            expect(response.body[0]).toHaveProperty('name');
        });
        it('should return 401 without auth token', async () => {
            await request(app.getHttpServer())
                .get('/v1/workouts')
                .expect(401);
        });
    });
    describe('GET /v1/workouts/:id', () => {
        it('should get workout details by id', async () => {
            const response = await request(app.getHttpServer())
                .get(`/v1/workouts/${workoutId}`)
                .set('Authorization', `Bearer ${accessToken}`)
                .expect(200);
            expect(response.body).toHaveProperty('id');
            expect(response.body.id).toBe(workoutId);
            expect(response.body.name).toBe('Treino A - Peito e Tríceps');
        });
        it('should return 401 without auth token', async () => {
            await request(app.getHttpServer())
                .get(`/v1/workouts/${workoutId}`)
                .expect(401);
        });
        it('should return 404 for non-existent workout', async () => {
            await request(app.getHttpServer())
                .get('/v1/workouts/00000000-0000-0000-0000-000000000000')
                .set('Authorization', `Bearer ${accessToken}`)
                .expect(404);
        });
    });
});
//# sourceMappingURL=workouts.e2e-spec.js.map
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const common_1 = require("@nestjs/common");
const request = require("supertest");
const app_module_1 = require("../src/app.module");
describe('Exercises (e2e)', () => {
    let app;
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
//# sourceMappingURL=exercises.e2e-spec.js.map
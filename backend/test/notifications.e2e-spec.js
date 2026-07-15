"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const common_1 = require("@nestjs/common");
const request = require("supertest");
const app_module_1 = require("../src/app.module");
describe('Notifications (e2e)', () => {
    let app;
    let accessToken;
    const testEmail = `e2e-notifications-${Date.now()}@test.com`;
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
            firstName: 'NotificationTest',
            email: testEmail,
            password: testPassword,
        });
        accessToken = registerResponse.body.accessToken;
    }, 30000);
    afterAll(async () => {
        await app.close();
    });
    describe('GET /v1/notifications', () => {
        it('should list notifications for authenticated user', async () => {
            const response = await request(app.getHttpServer())
                .get('/v1/notifications')
                .set('Authorization', `Bearer ${accessToken}`)
                .expect(200);
            expect(Array.isArray(response.body)).toBe(true);
        });
        it('should return 401 without auth token', async () => {
            await request(app.getHttpServer())
                .get('/v1/notifications')
                .expect(401);
        });
        it('should return 401 with invalid token', async () => {
            await request(app.getHttpServer())
                .get('/v1/notifications')
                .set('Authorization', 'Bearer invalid-token')
                .expect(401);
        });
    });
    describe('GET /v1/notifications/unread-count', () => {
        it('should return unread count for authenticated user', async () => {
            const response = await request(app.getHttpServer())
                .get('/v1/notifications/unread-count')
                .set('Authorization', `Bearer ${accessToken}`)
                .expect(200);
            expect(response.body).toHaveProperty('count');
            expect(typeof response.body.count).toBe('number');
        });
        it('should return 401 without auth token', async () => {
            await request(app.getHttpServer())
                .get('/v1/notifications/unread-count')
                .expect(401);
        });
    });
});
//# sourceMappingURL=notifications.e2e-spec.js.map
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ThrottlerModule } from '@nestjs/throttler';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('v1');

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  app.enableCors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:3001',
    credentials: true,
  });

  const config = new DocumentBuilder()
    .setTitle('Fit AI Coach API')
    .setDescription('API do aplicativo Fit AI Coach - Coach de Musculação e Cardio com IA')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('auth', 'Autenticação')
    .addTag('users', 'Usuários')
    .addTag('workouts', 'Treinos')
    .addTag('exercises', 'Exercícios')
    .addTag('ai-coach', 'Coach IA')
    .addTag('cardio', 'Cardio')
    .addTag('nutrition', 'Nutrição')
    .addTag('progress', 'Evolução')
    .addTag('subscriptions', 'Assinaturas')
    .addTag('notifications', 'Notificações')
    .addTag('community', 'Comunidade')
    .addTag('admin', 'Administração')
    .addTag('lgpd', 'LGPD / Privacidade')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  const port = process.env.APP_PORT || 3000;
  await app.listen(port);
  console.log(`Fit AI Coach API running on port ${port}`);
  console.log(`Swagger docs: http://localhost:${port}/docs`);
}
bootstrap();

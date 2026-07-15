import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { WorkoutsModule } from './modules/workouts/workouts.module';
import { ExercisesModule } from './modules/exercises/exercises.module';
import { AiCoachModule } from './modules/ai-coach/ai-coach.module';
import { CardioModule } from './modules/cardio/cardio.module';
import { NutritionModule } from './modules/nutrition/nutrition.module';
import { ProgressModule } from './modules/progress/progress.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { AdminModule } from './modules/admin/admin.module';
import { GamificationModule } from './modules/gamification/gamification.module';
import { LgpdModule } from './modules/lgpd/lgpd.module';
import { CommunityModule } from './modules/community/community.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 60,
    }]),

    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const dbUrl = config.get<string>('DATABASE_URL');
        if (dbUrl) {
          return {
            type: 'postgres' as const,
            url: dbUrl,
            ssl: { rejectUnauthorized: false },
            autoLoadEntities: true,
            synchronize: config.get('APP_ENV') !== 'production',
            logging: config.get('APP_ENV') === 'development',
          };
        }
        return {
          type: 'postgres' as const,
          host: config.get('DB_HOST', 'localhost'),
          port: config.get<number>('DB_PORT', 5432),
          username: config.get('DB_USERNAME', 'fitcoach'),
          password: config.get('DB_PASSWORD'),
          database: config.get('DB_NAME', 'fit_ai_coach'),
          autoLoadEntities: true,
          synchronize: config.get('APP_ENV') !== 'production',
          logging: config.get('APP_ENV') === 'development',
        };
      },
    }),

    AuthModule,
    UsersModule,
    WorkoutsModule,
    ExercisesModule,
    AiCoachModule,
    CardioModule,
    NutritionModule,
    ProgressModule,
    SubscriptionsModule,
    NotificationsModule,
    AdminModule,
    GamificationModule,
    LgpdModule,
    CommunityModule,
  ],
})
export class AppModule {}

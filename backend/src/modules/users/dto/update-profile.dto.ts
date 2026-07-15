import { IsOptional, IsEnum, IsNumber, IsArray, IsBoolean, Min, Max } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProfileDto {
  @ApiPropertyOptional({ example: 180 })
  @IsOptional()
  @IsNumber()
  @Min(100)
  @Max(250)
  height?: number;

  @ApiPropertyOptional({ example: 85 })
  @IsOptional()
  @IsNumber()
  @Min(20)
  @Max(350)
  weight?: number;

  @ApiPropertyOptional({ example: 75 })
  @IsOptional()
  @IsNumber()
  @Min(20)
  @Max(350)
  targetWeight?: number;

  @ApiPropertyOptional({ example: 15 })
  @IsOptional()
  @IsNumber()
  @Min(3)
  @Max(60)
  bodyFat?: number;

  @ApiPropertyOptional({ enum: ['hypertrophy', 'fat_loss', 'definition', 'strength', 'health', 'conditioning'] })
  @IsOptional()
  @IsEnum(['hypertrophy', 'fat_loss', 'definition', 'strength', 'health', 'conditioning'])
  goal?: string;

  @ApiPropertyOptional({ enum: ['beginner', 'intermediate', 'advanced'] })
  @IsOptional()
  @IsEnum(['beginner', 'intermediate', 'advanced'])
  experienceLevel?: string;

  @ApiPropertyOptional({ example: 5 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(7)
  trainingDays?: number;

  @ApiPropertyOptional({ example: 60 })
  @IsOptional()
  @IsNumber()
  @Min(15)
  @Max(240)
  trainingTime?: number;

  @ApiPropertyOptional({ enum: ['full_gym', 'small_gym', 'home', 'condo', 'outdoor'] })
  @IsOptional()
  @IsEnum(['full_gym', 'small_gym', 'home', 'condo', 'outdoor'])
  trainingLocation?: string;

  @ApiPropertyOptional({ example: ['barbell', 'dumbbell', 'machines'] })
  @IsOptional()
  @IsArray()
  equipmentAvailable?: string[];

  @ApiPropertyOptional({ example: ['shoulder', 'lower_back'] })
  @IsOptional()
  @IsArray()
  injuries?: string[];

  @ApiPropertyOptional({ example: 7.5 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(24)
  sleepHours?: number;

  @ApiPropertyOptional({ example: 5 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(10)
  stressLevel?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  onboardingCompleted?: boolean;
}

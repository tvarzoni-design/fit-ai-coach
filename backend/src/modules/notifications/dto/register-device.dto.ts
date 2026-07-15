import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDeviceDto {
  @ApiProperty({ description: 'Token FCM do dispositivo' })
  @IsString()
  @IsNotEmpty()
  fcmToken: string;

  @ApiProperty({ description: 'Plataforma do dispositivo', example: 'mobile', required: false })
  @IsString()
  @IsOptional()
  platform?: string;
}

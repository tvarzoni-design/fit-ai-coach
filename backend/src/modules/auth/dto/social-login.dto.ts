import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GoogleLoginDto {
  @ApiProperty({ description: 'Google ID token obtido pelo google_sign_in' })
  @IsString()
  @IsNotEmpty()
  idToken: string;
}

export class AppleLoginDto {
  @ApiProperty({ description: 'Apple identity token obtido pelo sign_in_with_apple' })
  @IsString()
  @IsNotEmpty()
  identityToken: string;

  @ApiProperty({ description: 'Apple authorization code', required: false })
  @IsString()
  @IsOptional()
  authorizationCode?: string;

  @ApiProperty({ description: 'Nome completo do usuário Apple', required: false })
  @IsString()
  @IsOptional()
  fullName?: string;
}

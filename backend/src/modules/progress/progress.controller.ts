import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ProgressService } from './progress.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('progress')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('progress')
export class ProgressController {
  constructor(private readonly progressService: ProgressService) {}

  @Get('measurements')
  @ApiOperation({ summary: 'Buscar medidas corporais' })
  async getMeasurements(@Request() req) {
    return this.progressService.getMeasurements(req.user.id);
  }

  @Get('measurements/latest')
  @ApiOperation({ summary: 'Buscar última medida registrada' })
  async getLatestMeasurement(@Request() req) {
    return this.progressService.getLatestMeasurement(req.user.id);
  }

  @Post('measurements')
  @ApiOperation({ summary: 'Registrar nova medida' })
  async addMeasurement(@Request() req, @Body() body: any) {
    return this.progressService.addMeasurement(req.user.id, body);
  }

  @Get('photos')
  @ApiOperation({ summary: 'Buscar fotos de evolução' })
  async getPhotos(@Request() req) {
    return this.progressService.getPhotos(req.user.id);
  }

  @Post('photos')
  @ApiOperation({ summary: 'Enviar fotos de evolução' })
  async addPhoto(@Request() req, @Body() body: any) {
    return this.progressService.addPhoto(req.user.id, body);
  }

  @Delete('measurements/:id')
  @ApiOperation({ summary: 'Excluir medida' })
  async removeMeasurement(@Param('id') id: string) {
    return this.progressService.removeMeasurement(id);
  }
}

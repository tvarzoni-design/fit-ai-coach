import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AiCoachService } from './ai-coach.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('ai-coach')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AiCoachController {
  constructor(private readonly aiCoachService: AiCoachService) {}

  @Post('chat')
  @ApiOperation({ summary: 'Conversar com o Coach IA' })
  async chat(@Request() req, @Body() body: { message: string }) {
    return this.aiCoachService.chat(req.user.id, body.message);
  }

  @Post('generate-workout')
  @ApiOperation({ summary: 'Gerar treino com IA' })
  async generateWorkout(@Request() req) {
    return this.aiCoachService.generateWorkout(req.user.id);
  }

  @Post('analyze-progress')
  @ApiOperation({ summary: 'Analisar evolução com IA' })
  async analyzeProgress(@Request() req) {
    return this.aiCoachService.analyzeProgress(req.user.id);
  }

  @Get('daily-coach')
  @ApiOperation({ summary: 'Recomendação diária da IA' })
  async getDailyCoach(@Request() req) {
    return this.aiCoachService.getDailyCoach(req.user.id);
  }

  @Get('recommendations')
  @ApiOperation({ summary: 'Buscar recomendações da IA' })
  async getRecommendations(@Request() req) {
    return this.aiCoachService.getRecommendations(req.user.id);
  }

  @Get('alerts')
  @ApiOperation({ summary: 'Buscar alertas da IA' })
  async getAlerts(@Request() req) {
    return this.aiCoachService.getAlerts(req.user.id);
  }

  @Get('memory')
  @ApiOperation({ summary: 'Buscar memória da IA' })
  async getMemory(@Request() req) {
    return this.aiCoachService.getMemory(req.user.id);
  }

  @Get('predictions')
  @ApiOperation({ summary: 'Buscar predições de evolução' })
  async getPredictions(@Request() req) {
    return this.aiCoachService.getPredictions(req.user.id);
  }
}

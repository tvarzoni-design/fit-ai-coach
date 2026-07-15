import { Controller, Get, Post, Param, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { GamificationService } from './gamification.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('gamification')
@Controller('gamification')
export class GamificationController {
  constructor(private readonly gamificationService: GamificationService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('profile')
  @ApiOperation({ summary: 'Buscar perfil de gamificação' })
  async getProfile(@Request() req) {
    return this.gamificationService.getProfile(req.user.id);
  }

  @Get('achievements')
  @ApiOperation({ summary: 'Listar todas conquistas disponíveis' })
  async getAchievements() {
    return this.gamificationService.getAchievements();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('achievements/mine')
  @ApiOperation({ summary: 'Buscar conquistas do usuário' })
  async getUserAchievements(@Request() req) {
    return this.gamificationService.getUserAchievements(req.user.id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('daily-challenges')
  @ApiOperation({ summary: 'Buscar desafios diários' })
  async getDailyChallenges(@Request() req) {
    return this.gamificationService.getDailyChallenges(req.user.id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('daily-challenges/:id/complete')
  @ApiOperation({ summary: 'Completar desafio diário' })
  async completeChallenge(@Request() req, @Param('id') challengeId: string) {
    return this.gamificationService.completeChallenge(req.user.id, challengeId);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('leaderboard')
  @ApiOperation({ summary: 'Buscar leaderboard' })
  async getLeaderboard(@Request() req) {
    return this.gamificationService.getLeaderboard(req.user.id);
  }

  @Get('leagues')
  @ApiOperation({ summary: 'Buscar ligas disponíveis' })
  async getLeagues() {
    return this.gamificationService.getLeagues();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('weekly-stats')
  @ApiOperation({ summary: 'Buscar estatísticas semanais' })
  async getWeeklyStats(@Request() req) {
    return this.gamificationService.getWeeklyStats(req.user.id);
  }
}

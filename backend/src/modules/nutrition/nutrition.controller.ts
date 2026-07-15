import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NutritionService } from './nutrition.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('nutrition')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('nutrition')
export class NutritionController {
  constructor(private readonly nutritionService: NutritionService) {}

  @Get('foods')
  @ApiOperation({ summary: 'Pesquisar alimentos' })
  async searchFoods(@Query('search') search?: string) {
    return this.nutritionService.searchFoods(search);
  }

  @Get('goals')
  @ApiOperation({ summary: 'Buscar metas nutricionais' })
  async getGoals(@Request() req) {
    return this.nutritionService.getGoals(req.user.id);
  }

  @Put('goals')
  @ApiOperation({ summary: 'Atualizar metas nutricionais' })
  async updateGoals(@Request() req, @Body() body: any) {
    return this.nutritionService.updateGoals(req.user.id, body);
  }

  @Post('meal')
  @ApiOperation({ summary: 'Registrar refeição' })
  async logMeal(@Request() req, @Body() body: any) {
    return this.nutritionService.logMeal(req.user.id, body);
  }

  @Get('daily')
  @ApiOperation({ summary: 'Resumo diário de nutrição' })
  async getDailySummary(@Request() req, @Query('date') date: string) {
    return this.nutritionService.getDailySummary(req.user.id, date);
  }

  @Get('history')
  @ApiOperation({ summary: 'Histórico de refeições' })
  async getHistory(@Request() req) {
    return this.nutritionService.getHistory(req.user.id);
  }

  @Delete('meal/:id')
  @ApiOperation({ summary: 'Excluir registro de refeição' })
  async removeMeal(@Param('id') id: string) {
    return this.nutritionService.removeMeal(id);
  }
}

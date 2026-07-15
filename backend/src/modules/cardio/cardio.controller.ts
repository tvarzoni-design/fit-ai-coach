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
import { CardioService } from './cardio.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('cardio')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('cardio')
export class CardioController {
  constructor(private readonly cardioService: CardioService) {}

  @Get()
  @ApiOperation({ summary: 'Listar sessões de cardio' })
  async findAll(@Request() req) {
    return this.cardioService.findAllByUser(req.user.id);
  }

  @Get('weekly')
  @ApiOperation({ summary: 'Resumo semanal de cardio' })
  async getWeeklySummary(@Request() req) {
    return this.cardioService.getWeeklySummary(req.user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Registrar sessão de cardio' })
  async create(@Request() req, @Body() body: any) {
    return this.cardioService.create(req.user.id, body);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Excluir sessão de cardio' })
  async remove(@Param('id') id: string) {
    return this.cardioService.remove(id);
  }
}

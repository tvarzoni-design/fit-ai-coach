import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { WorkoutsService } from './workouts.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('workouts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('workouts')
export class WorkoutsController {
  constructor(private readonly workoutsService: WorkoutsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar treinos do usuário' })
  async findAll(@Request() req) {
    return this.workoutsService.findAllByUser(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar treino por ID' })
  async findOne(@Param('id') id: string) {
    return this.workoutsService.findById(id);
  }

  @Post()
  @ApiOperation({ summary: 'Criar novo treino' })
  async create(@Request() req, @Body() body: any) {
    return this.workoutsService.create(req.user.id, body);
  }

  @Post(':id/exercises')
  @ApiOperation({ summary: 'Adicionar exercício ao treino' })
  async addExercise(@Param('id') id: string, @Body() body: any) {
    return this.workoutsService.addExercise(id, body);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Atualizar treino' })
  async update(@Param('id') id: string, @Body() body: any) {
    return this.workoutsService.update(id, body);
  }

  @Post('history')
  @ApiOperation({ summary: 'Registrar série executada' })
  async recordSet(@Request() req, @Body() body: any) {
    return this.workoutsService.recordSet(req.user.id, body);
  }

  @Get('history/all')
  @ApiOperation({ summary: 'Histórico completo de treinos' })
  async getHistory(@Request() req) {
    return this.workoutsService.getHistory(req.user.id);
  }

  @Get('history/exercise/:exerciseId')
  @ApiOperation({ summary: 'Histórico de um exercício específico' })
  async getExerciseHistory(@Request() req, @Param('exerciseId') exerciseId: string) {
    return this.workoutsService.getExerciseHistory(req.user.id, exerciseId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Excluir treino' })
  async remove(@Param('id') id: string) {
    return this.workoutsService.remove(id);
  }
}

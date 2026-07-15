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
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ExercisesService } from './exercises.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('exercises')
@Controller('exercises')
export class ExercisesController {
  constructor(private readonly exercisesService: ExercisesService) {}

  @Get()
  @ApiOperation({ summary: 'Listar exercícios' })
  @ApiQuery({ name: 'muscle', required: false })
  @ApiQuery({ name: 'equipment', required: false })
  @ApiQuery({ name: 'difficulty', required: false })
  @ApiQuery({ name: 'search', required: false })
  async findAll(
    @Query('muscle') muscle?: string,
    @Query('equipment') equipment?: string,
    @Query('difficulty') difficulty?: string,
    @Query('search') search?: string,
  ) {
    return this.exercisesService.findAll({ muscle, equipment, difficulty, search });
  }

  @Get('muscles')
  @ApiOperation({ summary: 'Listar grupos musculares' })
  async getMuscleGroups() {
    return this.exercisesService.getMuscleGroups();
  }

  @Get('muscle-groups')
  @ApiOperation({ summary: 'Listar grupos musculares (alias)' })
  async getMuscleGroupsAlias() {
    return this.exercisesService.getMuscleGroups();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar exercício por ID' })
  async findOne(@Param('id') id: string) {
    return this.exercisesService.findById(id);
  }

  @Get('muscle/:muscle')
  @ApiOperation({ summary: 'Buscar exercícios por músculo' })
  async findByMuscle(@Param('muscle') muscle: string) {
    return this.exercisesService.findByMuscle(muscle);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post()
  @ApiOperation({ summary: 'Criar exercício (admin)' })
  async create(@Body() body: any) {
    return this.exercisesService.create(body);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Put(':id')
  @ApiOperation({ summary: 'Atualizar exercício (admin)' })
  async update(@Param('id') id: string, @Body() body: any) {
    return this.exercisesService.update(id, body);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  @ApiOperation({ summary: 'Excluir exercício (admin)' })
  async remove(@Param('id') id: string) {
    return this.exercisesService.remove(id);
  }
}

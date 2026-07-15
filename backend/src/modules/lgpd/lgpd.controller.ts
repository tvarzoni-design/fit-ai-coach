import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
  Res,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { Response } from 'express';
import { LgpdService } from './lgpd.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('lgpd')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('lgpd')
export class LgpdController {
  constructor(private readonly lgpdService: LgpdService) {}

  @Post('consent')
  @ApiOperation({ summary: 'Registrar consentimento (LGPD Art. 8)' })
  async recordConsent(
    @Request() req,
    @Body() body: { consentType: string; granted: boolean },
  ) {
    const ip = req.ip || req.connection?.remoteAddress;
    const userAgent = req.headers['user-agent'];
    return this.lgpdService.recordConsent(
      req.user.id,
      body.consentType,
      body.granted,
      ip,
      userAgent,
    );
  }

  @Get('consent')
  @ApiOperation({ summary: 'Consultar status dos consentimentos' })
  async getConsentStatus(@Request() req) {
    return this.lgpdService.getConsentStatus(req.user.id);
  }

  @Get('export')
  @ApiOperation({ summary: 'Exportar todos os dados pessoais (LGPD Art. 18, II)' })
  async exportData(@Request() req, @Res() res: Response) {
    const data = await this.lgpdService.exportUserData(req.user.id);
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', 
      `attachment; filename="fit-ai-coach-dados-${req.user.id}.json"`);
    return res.json(data);
  }

  @Delete('account')
  @ApiOperation({ summary: 'Solicitar exclusão/anonimização de dados (LGPD Art. 18, VI)' })
  async deleteAccount(@Request() req) {
    return this.lgpdService.deleteUserData(req.user.id);
  }

  @Get('processing-logs')
  @ApiOperation({ summary: 'Consultar logs de processamento de dados' })
  async getProcessingLogs(@Request() req) {
    return this.lgpdService.getProcessingLogs(req.user.id);
  }
}

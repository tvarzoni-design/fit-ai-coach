import {
  Controller,
  Get,
  Put,
  Delete,
  Post,
  Param,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RegisterDeviceDto } from './dto/register-device.dto';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar notificações' })
  async findAll(@Request() req) {
    return this.notificationsService.findAllByUser(req.user.id);
  }

  @Get('unread-count')
  @ApiOperation({ summary: 'Contar notificações não lidas' })
  async getUnreadCount(@Request() req) {
    return { count: await this.notificationsService.getUnreadCount(req.user.id) };
  }

  @Put(':id/read')
  @ApiOperation({ summary: 'Marcar notificação como lida' })
  async markAsRead(@Param('id') id: string) {
    return this.notificationsService.markAsRead(id);
  }

  @Put('read-all')
  @ApiOperation({ summary: 'Marcar todas como lidas' })
  async markAllAsRead(@Request() req) {
    return this.notificationsService.markAllAsRead(req.user.id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Excluir notificação' })
  async remove(@Param('id') id: string) {
    return this.notificationsService.remove(id);
  }

  @Get('smart')
  @ApiOperation({ summary: 'Buscar configurações de notificações inteligentes' })
  async getSmartNotifications(@Request() req) {
    return this.notificationsService.getSmartNotifications(req.user.id);
  }

  @Put('smart/:id/toggle')
  @ApiOperation({ summary: 'Ativar/desativar notificação inteligente' })
  async toggleSmartNotification(@Request() req, @Param('id') id: string) {
    return this.notificationsService.toggleSmartNotification(req.user.id, id);
  }

  @Post('send')
  @ApiOperation({ summary: 'Enviar notificação push' })
  async sendNotification(@Request() req, @Body() body: { title: string; body: string; type?: string }) {
    const data = body.type ? { type: body.type } : undefined;
    return this.notificationsService.sendPushNotification(req.user.id, body.title, body.body, data);
  }

  @Post('register-device')
  @ApiOperation({ summary: 'Registrar dispositivo FCM' })
  async registerDevice(@Request() req, @Body() dto: RegisterDeviceDto) {
    await this.notificationsService.registerDeviceToken(req.user.id, dto.fcmToken, dto.platform);
    return { success: true };
  }

  @Post('unregister-device')
  @ApiOperation({ summary: 'Remover dispositivo FCM' })
  async unregisterDevice(@Request() req, @Body() body: { fcmToken: string }) {
    await this.notificationsService.removeDeviceToken(req.user.id, body.fcmToken);
    return { success: true };
  }
}

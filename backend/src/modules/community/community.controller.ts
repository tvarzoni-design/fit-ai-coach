import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CommunityService } from './community.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('community')
@Controller('community')
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  @Post('posts')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Criar post na comunidade' })
  async createPost(@Request() req, @Body() body: { content: string; imageUrl?: string; workoutId?: string }) {
    return this.communityService.createPost(req.user.id, body.content, body.imageUrl, body.workoutId);
  }

  @Get('posts')
  @ApiOperation({ summary: 'Feed da comunidade' })
  async getFeed(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.communityService.getFeed('', page || 1, limit || 20);
  }

  @Get('posts/:id')
  @ApiOperation({ summary: 'Detalhes do post' })
  async getPost(@Param('id') id: string) {
    return this.communityService.getPostById(id);
  }

  @Delete('posts/:id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Deletar post' })
  async deletePost(@Request() req, @Param('id') id: string) {
    return this.communityService.deletePost(req.user.id, id);
  }

  @Post('posts/:id/like')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Curtir/descurtir post' })
  async likePost(@Request() req, @Param('id') id: string) {
    return this.communityService.likePost(req.user.id, id);
  }

  @Get('posts/:id/comments')
  @ApiOperation({ summary: 'Comentários do post' })
  async getComments(@Param('id') id: string, @Query('page') page?: number) {
    return this.communityService.getComments(id, page || 1);
  }

  @Post('posts/:id/comments')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Adicionar comentário' })
  async addComment(@Request() req, @Param('id') id: string, @Body() body: { content: string }) {
    return this.communityService.addComment(req.user.id, id, body.content);
  }

  @Post('follow/:userId')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Seguir usuário' })
  async followUser(@Request() req, @Param('userId') userId: string) {
    return this.communityService.followUser(req.user.id, userId);
  }

  @Delete('follow/:userId')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Deixar de seguir usuário' })
  async unfollowUser(@Request() req, @Param('userId') userId: string) {
    return this.communityService.followUser(req.user.id, userId);
  }

  @Get('followers')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Meus seguidores' })
  async getMyFollowers(@Request() req) {
    return this.communityService.getFollowers(req.user.id);
  }

  @Get('following')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Quem eu sigo' })
  async getMyFollowing(@Request() req) {
    return this.communityService.getFollowing(req.user.id);
  }

  @Get('users/:id/followers')
  @ApiOperation({ summary: 'Seguidores do usuário' })
  async getFollowers(@Param('id') id: string) {
    return this.communityService.getFollowers(id);
  }

  @Get('users/:id/following')
  @ApiOperation({ summary: 'Quem o usuário segue' })
  async getFollowing(@Param('id') id: string) {
    return this.communityService.getFollowing(id);
  }

  @Get('users/:id/posts')
  @ApiOperation({ summary: 'Posts do usuário' })
  async getUserPosts(@Param('id') id: string) {
    return this.communityService.getUserPosts(id);
  }
}

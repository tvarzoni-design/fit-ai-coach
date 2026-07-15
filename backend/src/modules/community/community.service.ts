import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommunityPost } from './entities/community-post.entity';
import { CommunityLike } from './entities/community-like.entity';
import { CommunityComment } from './entities/community-comment.entity';
import { CommunityFollow } from './entities/community-follow.entity';

@Injectable()
export class CommunityService {
  constructor(
    @InjectRepository(CommunityPost)
    private postRepository: Repository<CommunityPost>,
    @InjectRepository(CommunityLike)
    private likeRepository: Repository<CommunityLike>,
    @InjectRepository(CommunityComment)
    private commentRepository: Repository<CommunityComment>,
    @InjectRepository(CommunityFollow)
    private followRepository: Repository<CommunityFollow>,
  ) {}

  async createPost(userId: string, content: string, imageUrl?: string, workoutId?: string): Promise<CommunityPost> {
    const post = this.postRepository.create({
      userId,
      content,
      imageUrl,
      workoutId,
    });
    return this.postRepository.save(post);
  }

  async getFeed(userId: string, page = 1, limit = 20): Promise<CommunityPost[]> {
    return this.postRepository.find({
      where: { active: true },
      relations: ['user'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });
  }

  async getPostById(id: string): Promise<CommunityPost> {
    const post = await this.postRepository.findOne({
      where: { id },
      relations: ['user'],
    });
    if (!post) throw new NotFoundException('Post não encontrado');
    return post;
  }

  async deletePost(userId: string, postId: string): Promise<void> {
    const post = await this.postRepository.findOne({ where: { id: postId } });
    if (!post) throw new NotFoundException('Post não encontrado');
    if (post.userId !== userId) throw new ForbiddenException('Não autorizado');
    post.active = false;
    await this.postRepository.save(post);
  }

  async likePost(userId: string, postId: string): Promise<{ liked: boolean }> {
    const existing = await this.likeRepository.findOne({ where: { userId, postId } });
    if (existing) {
      await this.likeRepository.delete(existing.id);
      await this.postRepository.decrement({ id: postId }, 'likesCount', 1);
      return { liked: false };
    }
    const like = this.likeRepository.create({ userId, postId });
    await this.likeRepository.save(like);
    await this.postRepository.increment({ id: postId }, 'likesCount', 1);
    return { liked: true };
  }

  async addComment(userId: string, postId: string, content: string): Promise<CommunityComment> {
    const comment = this.commentRepository.create({ userId, postId, content });
    const saved = await this.commentRepository.save(comment);
    await this.postRepository.increment({ id: postId }, 'commentsCount', 1);
    return saved;
  }

  async getComments(postId: string, page = 1, limit = 20): Promise<CommunityComment[]> {
    return this.commentRepository.find({
      where: { postId },
      relations: ['user'],
      order: { createdAt: 'ASC' },
      skip: (page - 1) * limit,
      take: limit,
    });
  }

  async followUser(followerId: string, followingId: string): Promise<{ followed: boolean }> {
    if (followerId === followingId) throw new ForbiddenException('Não pode seguir a si mesmo');
    const existing = await this.followRepository.findOne({ where: { followerId, followingId } });
    if (existing) {
      await this.followRepository.delete(existing.id);
      return { followed: false };
    }
    const follow = this.followRepository.create({ followerId, followingId });
    await this.followRepository.save(follow);
    return { followed: true };
  }

  async getFollowers(userId: string): Promise<CommunityFollow[]> {
    return this.followRepository.find({ where: { followingId: userId }, relations: ['follower'] });
  }

  async getFollowing(userId: string): Promise<CommunityFollow[]> {
    return this.followRepository.find({ where: { followerId: userId }, relations: ['following'] });
  }

  async getUserPosts(userId: string): Promise<CommunityPost[]> {
    return this.postRepository.find({ where: { userId, active: true }, order: { createdAt: 'DESC' } });
  }
}

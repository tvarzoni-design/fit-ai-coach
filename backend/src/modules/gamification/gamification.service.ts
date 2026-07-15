import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Achievement } from './entities/achievement.entity';
import { UserXp } from './entities/user-xp.entity';
import { UserAchievement } from './entities/user-achievement.entity';

@Injectable()
export class GamificationService {
  constructor(
    @InjectRepository(Achievement)
    private achievementRepository: Repository<Achievement>,
    @InjectRepository(UserXp)
    private userXpRepository: Repository<UserXp>,
    @InjectRepository(UserAchievement)
    private userAchievementRepository: Repository<UserAchievement>,
  ) {}

  async getProfile(userId: string): Promise<any> {
    let userXp = await this.userXpRepository.findOne({ where: { userId } });
    if (!userXp) {
      userXp = this.userXpRepository.create({ userId, xpTotal: 0, level: 1 });
      await this.userXpRepository.save(userXp);
    }

    const achievements = await this.userAchievementRepository.find({
      where: { userId },
      relations: ['achievement'],
    });

    const xpToNextLevel = this.getXpForLevel(userXp.level + 1);
    const weeklyRank = await this.getWeeklyRank(userId);

    return {
      xp: userXp.xpTotal,
      level: userXp.level,
      xpToNextLevel,
      currentStreak: userXp.currentStreak,
      longestStreak: userXp.longestStreak,
      rank: this.getRankTitle(userXp.level),
      weeklyRank,
      achievements: achievements.map((a) => a.achievement),
    };
  }

  async addXp(userId: string, xp: number): Promise<UserXp> {
    let userXp = await this.userXpRepository.findOne({ where: { userId } });
    if (!userXp) {
      userXp = this.userXpRepository.create({ userId, xpTotal: 0, level: 1 });
    }

    userXp.xpTotal += xp;
    userXp.level = this.calculateLevel(userXp.xpTotal);

    return this.userXpRepository.save(userXp);
  }

  async unlockAchievement(userId: string, achievementId: string): Promise<void> {
    const existing = await this.userAchievementRepository.findOne({
      where: { userId, achievementId },
    });

    if (!existing) {
      const userAchievement = this.userAchievementRepository.create({
        userId,
        achievementId,
        unlockedAt: new Date(),
      });
      await this.userAchievementRepository.save(userAchievement);
    }
  }

  async getAchievements(): Promise<Achievement[]> {
    return this.achievementRepository.find({ order: { category: 'ASC', name: 'ASC' } });
  }

  async getUserAchievements(userId: string): Promise<UserAchievement[]> {
    return this.userAchievementRepository.find({
      where: { userId },
      relations: ['achievement'],
    });
  }

  async getDailyChallenges(userId: string): Promise<any[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    return [
      {
        id: 'dc-001',
        title: '100 Flexões',
        description: 'Faça 100 flexões hoje',
        xpReward: 150,
        completed: false,
        progress: 0,
        target: 100,
        category: 'strength',
        expiresAt: new Date(today.getTime() + 24 * 60 * 60 * 1000),
      },
      {
        id: 'dc-002',
        title: 'Beber 3L de Água',
        description: 'Mantenha-se hidratado hoje',
        xpReward: 100,
        completed: false,
        progress: 0,
        target: 3000,
        category: 'health',
        expiresAt: new Date(today.getTime() + 24 * 60 * 60 * 1000),
      },
      {
        id: 'dc-003',
        title: '30 Minutos de Cardio',
        description: 'Faça 30 min de qualquer cardio',
        xpReward: 120,
        completed: false,
        progress: 0,
        target: 30,
        category: 'cardio',
        expiresAt: new Date(today.getTime() + 24 * 60 * 60 * 1000),
      },
    ];
  }

  async completeChallenge(userId: string, challengeId: string): Promise<any> {
    const challenge = (await this.getDailyChallenges(userId)).find(c => c.id === challengeId);
    if (challenge) {
      challenge.completed = true;
      challenge.progress = challenge.target;
      await this.addXp(userId, challenge.xpReward);
    }
    return challenge;
  }

  async getLeaderboard(userId: string): Promise<any[]> {
    const allUsers = await this.userXpRepository.find({
      order: { xpTotal: 'DESC' },
      take: 50,
    });

    return allUsers.map((u, index) => ({
      rank: index + 1,
      userId: u.userId,
      xp: u.xpTotal,
      level: u.level,
      streak: u.currentStreak,
      isMe: u.userId === userId,
    }));
  }

  async getLeagues(): Promise<any[]> {
    return [
      { name: 'Bronze', minXp: 0, maxXp: 1000, icon: '🥉', color: '0xFFCD7F32' },
      { name: 'Prata', minXp: 1000, maxXp: 3000, icon: '🥈', color: '0xFFC0C0C0' },
      { name: 'Ouro', minXp: 3000, maxXp: 6000, icon: '🥇', color: '0xFFFFD700' },
      { name: 'Platina', minXp: 6000, maxXp: 10000, icon: '💎', color: '0xFFE5E4E2' },
      { name: 'Diamante', minXp: 10000, maxXp: 99999, icon: '💠', color: '0xFFB9F2FF' },
    ];
  }

  async getWeeklyStats(userId: string): Promise<any> {
    return {
      workoutsCompleted: 3,
      caloriesBurned: 1850,
      totalVolume: 12450,
      xpEarned: 450,
      challengesCompleted: 1,
    };
  }

  private async getWeeklyRank(userId: string): Promise<number> {
    const weekStart = new Date();
    weekStart.setDate(weekStart.getDate() - weekStart.getDay());
    weekStart.setHours(0, 0, 0, 0);

    const allUsers = await this.userXpRepository.find({
      order: { xpTotal: 'DESC' },
      take: 100,
    });

    const userIndex = allUsers.findIndex(u => u.userId === userId);
    return userIndex >= 0 ? userIndex + 1 : allUsers.length + 1;
  }

  private getRankTitle(level: number): string {
    if (level >= 15) return 'Diamante';
    if (level >= 12) return 'Platina';
    if (level >= 8) return 'Ouro';
    if (level >= 4) return 'Prata';
    return 'Bronze';
  }

  private getXpForLevel(level: number): number {
    const levels = [0, 500, 1200, 2100, 3300, 4800, 6600, 8800, 11400, 14400, 18000, 22000, 26500, 31500, 37000, 43000];
    if (level <= 0) return 0;
    if (level >= levels.length) return levels[levels.length - 1] + (level - levels.length + 1) * 5000;
    return levels[level];
  }

  private calculateLevel(xp: number): number {
    const levels = [0, 500, 1200, 2100, 3300, 4800, 6600, 8800, 11400, 14400, 18000];
    for (let i = levels.length - 1; i >= 0; i--) {
      if (xp >= levels[i]) return i + 1;
    }
    return 1;
  }
}

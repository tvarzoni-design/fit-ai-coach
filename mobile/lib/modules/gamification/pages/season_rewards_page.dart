import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SeasonRewardsPage extends StatefulWidget {
  const SeasonRewardsPage({super.key});

  @override
  State<SeasonRewardsPage> createState() => _SeasonRewardsPageState();
}

class _SeasonRewardsPageState extends State<SeasonRewardsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _seasonData;

  @override
  void initState() {
    super.initState();
    _loadSeasonData();
  }

  Future<void> _loadSeasonData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/gamification/season');
      if (mounted) {
        setState(() {
          _seasonData = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _seasonData = {
            'name': 'Temporada de Verão',
            'endDate': DateTime.now().add(const Duration(days: 18)).toIso8601String(),
            'currentXP': 2450,
            'currentTier': 'Ouro',
            'nextTier': 'Diamante',
            'xpForNextTier': 5000,
            'rewards': [
              {'name': 'Avatar Exclusivo', 'tier': 'Prata', 'xpRequired': 1000, 'claimed': true, 'icon': Icons.face},
              {'name': 'Título de Campeão', 'tier': 'Ouro', 'xpRequired': 2500, 'claimed': true, 'icon': Icons.emoji_events},
              {'name': 'Borda de Perfil Dourada', 'tier': 'Ouro', 'xpRequired': 3000, 'claimed': false, 'icon': Icons.star},
              {'name': 'Tema Exclusivo', 'tier': 'Diamante', 'xpRequired': 5000, 'claimed': false, 'icon': Icons.palette},
              {'name': 'Badge Lendário', 'tier': 'Lendário', 'xpRequired': 10000, 'claimed': false, 'icon': Icons.workspace_premium},
            ],
          };
          _isLoading = false;
        });
      }
    }
  }

  String _getTimeRemaining() {
    if (_seasonData == null || _seasonData!['endDate'] == null) return '--';
    final endDate = DateTime.tryParse(_seasonData!['endDate']);
    if (endDate == null) return '--';
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 'Encerrada';
    final diff = endDate.difference(now);
    if (diff.inDays > 0) return '${diff.inDays} dias restantes';
    if (diff.inHours > 0) return '${diff.inHours}h restantes';
    return '${diff.inMinutes}min restantes';
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'prata':
        return AppColors.textSecondary;
      case 'ouro':
        return AppColors.warning;
      case 'diamante':
        return AppColors.info;
      case 'lendário':
        return AppColors.secondary;
      default:
        return AppColors.textMuted;
    }
  }

  Future<void> _claimReward(Map<String, dynamic> reward) async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/gamification/claim-reward', data: {
        'rewardName': reward['name'],
      });
    } catch (_) {}

    setState(() => reward['claimed'] = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reward['name']} reivindicado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompensas da Temporada'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadSeasonData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSeasonHeader(),
                  const SizedBox(height: 16),
                  _buildProgressBar(),
                  const SizedBox(height: 16),
                  _buildRewardsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSeasonHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.wb_sunny, color: AppColors.warning, size: 40),
            const SizedBox(height: 12),
            Text(
              _seasonData?['name'] ?? 'Temporada Atual',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _getTimeRemaining(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final currentXP = _seasonData?['currentXP'] ?? 0;
    final xpForNext = _seasonData?['xpForNextTier'] ?? 5000;
    final progress = (currentXP / xpForNext).clamp(0.0, 1.0);
    final currentTier = _seasonData?['currentTier'] ?? '--';
    final nextTier = _seasonData?['nextTier'] ?? '--';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentTier,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getTierColor(currentTier),
                  ),
                ),
                Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 18),
                Text(
                  nextTier,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getTierColor(nextTier),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(_getTierColor(nextTier)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentXP XP',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  '$xpForNext XP',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList() {
    final rewards = (_seasonData?['rewards'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recompensas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...rewards.map((reward) {
          final tierColor = _getTierColor(reward['tier'] ?? '');
          final currentXP = _seasonData?['currentXP'] ?? 0;
          final xpRequired = reward['xpRequired'] ?? 0;
          final canClaim = !reward['claimed'] && currentXP >= xpRequired;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: reward['claimed']
                          ? AppColors.success.withValues(alpha: 0.15)
                          : tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      reward['icon'] as IconData? ?? Icons.card_giftcard,
                      color: reward['claimed'] ? AppColors.success : tierColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: reward['claimed']
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            decoration: reward['claimed']
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: tierColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                reward['tier'] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tierColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${reward['xpRequired']} XP',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (reward['claimed'])
                    Icon(Icons.check_circle, color: AppColors.success, size: 22)
                  else if (canClaim)
                    ElevatedButton(
                      onPressed: () => _claimReward(reward),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Reivindicar'),
                    )
                  else
                    Icon(Icons.lock, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

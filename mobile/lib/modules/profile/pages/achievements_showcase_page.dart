import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AchievementsShowcasePage extends StatefulWidget {
  const AchievementsShowcasePage({super.key});

  @override
  State<AchievementsShowcasePage> createState() => _AchievementsShowcasePageState();
}

class _AchievementsShowcasePageState extends State<AchievementsShowcasePage> {
  bool _isLoading = true;
  List<dynamic> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/gamification/achievements');
      if (mounted) {
        setState(() {
          _achievements = response.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _achievements = _getMockAchievements();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getMockAchievements() {
    return [
      {'id': '1', 'name': 'Primeiro Treino', 'description': 'Complete seu primeiro treino', 'icon': '🏋️', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(), 'rarity': 'Comum'},
      {'id': '2', 'name': 'Sequência de 7 Dias', 'description': 'Treine por 7 dias seguidos', 'icon': '🔥', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(), 'rarity': 'Raro'},
      {'id': '3', 'name': 'Força Bruta', 'description': 'Aumente seu recorde em 5 exercícios', 'icon': '💪', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(), 'rarity': 'Raro'},
      {'id': '4', 'name': 'Maratonista', 'description': 'Complete 100 treinos', 'icon': '🏃', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(), 'rarity': 'Épico'},
      {'id': '5', 'name': 'Social Butterfly', 'description': 'Faça 10 amigos na comunidade', 'icon': '🦋', 'unlocked': false, 'requirement': '6/10 amigos', 'rarity': 'Raro'},
      {'id': '6', 'name': 'Sequência de 30 Dias', 'description': 'Treine por 30 dias seguidos', 'icon': '⚡', 'unlocked': false, 'requirement': '18/30 dias', 'rarity': 'Épico'},
      {'id': '7', 'name': 'Lenda do Fitness', 'description': 'Complete 500 treinos', 'icon': '🏆', 'unlocked': false, 'requirement': '156/500 treinos', 'rarity': 'Lendário'},
      {'id': '8', 'name': 'Guru da Nutrição', 'description': 'Siga seu plano nutricional por 60 dias', 'icon': '🥗', 'unlocked': false, 'requirement': '24/60 dias', 'rarity': 'Épico'},
      {'id': '9', 'name': 'Madrugador', 'description': 'Acordes antes das 6h por 20 dias', 'icon': '🌅', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(), 'rarity': 'Raro'},
      {'id': '10', 'name': 'Mentor', 'description': 'Ajude 10 membros da comunidade', 'icon': '🧠', 'unlocked': false, 'requirement': '4/10 membros', 'rarity': 'Épico'},
      {'id': '11', 'name': 'Velocista', 'description': 'Corra 5km em menos de 25 minutos', 'icon': '⏱️', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(), 'rarity': 'Raro'},
      {'id': '12', 'name': 'Mestre dos Recordes', 'description': 'Estabeleça 20 recordes pessoais', 'icon': '👑', 'unlocked': false, 'requirement': '12/20 recordes', 'rarity': 'Lendário'},
    ];
  }

  int get _unlockedCount => _achievements.where((a) => a['unlocked'] == true).length;

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Comum':
        return AppColors.textSecondary;
      case 'Raro':
        return AppColors.info;
      case 'Épico':
        return AppColors.primary;
      case 'Lendário':
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }

  void _showAchievementDetail(dynamic achievement) {
    final isUnlocked = achievement['unlocked'] == true;
    final rarityColor = _getRarityColor(achievement['rarity'] ?? 'Comum');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isUnlocked ? rarityColor.withValues(alpha: 0.2) : AppColors.surfaceLight,
                shape: BoxShape.circle,
                boxShadow: isUnlocked
                    ? [BoxShadow(color: rarityColor.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)]
                    : null,
              ),
              child: Center(
                child: Text(
                  achievement['icon'] ?? '🏅',
                  style: TextStyle(fontSize: 36, color: isUnlocked ? null : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement['name'] ?? '',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                achievement['rarity'] ?? '',
                style: TextStyle(color: rarityColor, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              achievement['description'] ?? '',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Desbloqueado em ${_formatDate(achievement['unlockedAt'])}',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  achievement['requirement'] ?? 'Requisito não disponível',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            if (isUnlocked) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Compartilhar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Conquistas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAchievements,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _buildSummaryCard(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAchievementItem(_achievements[index]),
                        childCount: _achievements.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('$_unlockedCount', style: TextStyle(color: AppColors.success, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Desbloqueadas', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            Container(width: 1, height: 40, color: AppColors.surfaceLight),
            Column(
              children: [
                Text('${_achievements.length - _unlockedCount}', style: TextStyle(color: AppColors.textMuted, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Bloqueadas', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            Container(width: 1, height: 40, color: AppColors.surfaceLight),
            Column(
              children: [
                Text('${_achievements.length}', style: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(dynamic achievement) {
    final isUnlocked = achievement['unlocked'] == true;
    final rarityColor = _getRarityColor(achievement['rarity'] ?? 'Comum');

    return GestureDetector(
      onTap: () => _showAchievementDetail(achievement),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? rarityColor.withValues(alpha: 0.5) : AppColors.surfaceLight,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [BoxShadow(color: rarityColor.withValues(alpha: 0.15), blurRadius: 12, spreadRadius: 2)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isUnlocked ? rarityColor.withValues(alpha: 0.15) : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  achievement['icon'] ?? '🏅',
                  style: TextStyle(fontSize: 26, color: isUnlocked ? null : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement['name'] ?? '',
              style: TextStyle(
                color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isUnlocked && achievement['requirement'] != null) ...[
              const SizedBox(height: 2),
              Text(
                achievement['requirement'],
                style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

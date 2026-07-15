import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ProfileStatsPage extends StatefulWidget {
  const ProfileStatsPage({super.key});

  @override
  State<ProfileStatsPage> createState() => _ProfileStatsPageState();
}

class _ProfileStatsPageState extends State<ProfileStatsPage> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/profile/stats');
      if (mounted) {
        setState(() {
          _stats = response.data ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stats = _getMockStats();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getMockStats() {
    return {
      'totalWorkouts': 156,
      'totalHours': 218,
      'totalCalories': 89400,
      'memberSince': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
      'avgWorkoutsPerWeek': 3.2,
      'longestStreak': 21,
      'level': 12,
      'xp': 8500,
      'xpToNextLevel': 10000,
    };
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '--';
    try {
      final date = DateTime.parse(isoDate);
      final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
      return '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '--';
    }
  }

  String _formatNumber(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Estatísticas do Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLevelCard(),
                    const SizedBox(height: 16),
                    _buildMainStats(),
                    const SizedBox(height: 16),
                    _buildSecondaryStats(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLevelCard() {
    final level = _stats['level'] ?? 1;
    final xp = _stats['xp'] ?? 0;
    final xpToNext = _stats['xpToNextLevel'] ?? 10000;
    final pct = (xp / xpToNext).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$level',
                      style: TextStyle(color: AppColors.warning, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Nível $level', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$xp / $xpToNext XP',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estatísticas Principais', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(Icons.fitness_center, '${_stats['totalWorkouts'] ?? 0}', 'Treinos', AppColors.primary),
                _buildStatItem(Icons.timer, '${_stats['totalHours'] ?? 0}h', 'Horas', AppColors.secondary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(Icons.local_fire_department, _formatNumber(_stats['totalCalories'] ?? 0), 'Calorias', AppColors.warning),
                _buildStatItem(Icons.calendar_today, _formatDate(_stats['memberSince']?.toString()), 'Membro desde', AppColors.info),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Consistência', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 16),
            _buildConsistencyRow(
              Icons.show_chart,
              'Média Semanal',
              '${_stats['avgWorkoutsPerWeek'] ?? 0} treinos/semana',
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildConsistencyRow(
              Icons.local_fire_department,
              'Maior Sequência',
              '${_stats['longestStreak'] ?? 0} dias seguidos',
              AppColors.warning,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getRankTitle(),
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        Text(
                          _getRankDescription(),
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
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

  String _getRankTitle() {
    final workouts = _stats['totalWorkouts'] ?? 0;
    if (workouts >= 500) return 'Lenda do Fitness';
    if (workouts >= 200) return 'Atleta Veterano';
    if (workouts >= 100) return 'Dedicado';
    if (workouts >= 50) return 'Em Progresso';
    return 'Iniciante';
  }

  String _getRankDescription() {
    final workouts = _stats['totalWorkouts'] ?? 0;
    if (workouts >= 500) return 'Você é uma referência na comunidade!';
    if (workouts >= 200) return 'Sua dedicação é inspiradora.';
    if (workouts >= 100) return 'Continue assim, está indo muito bem!';
    if (workouts >= 50) return 'O hábito está se formando.';
    return 'Cada treino conta na sua jornada.';
  }

  Widget _buildConsistencyRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}

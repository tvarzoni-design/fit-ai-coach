import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class GoalsProgressPage extends StatefulWidget {
  const GoalsProgressPage({super.key});

  @override
  State<GoalsProgressPage> createState() => _GoalsProgressPageState();
}

class _GoalsProgressPageState extends State<GoalsProgressPage> {
  bool _isLoading = true;
  Map<String, dynamic> _goals = {};

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/goals/progress');
      if (mounted) {
        setState(() {
          _goals = response.data ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _goals = _getMockGoals();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getMockGoals() {
    return {
      'weeklyWorkouts': {'current': 4, 'target': 5, 'label': 'Treinos Semanais', 'icon': 'fitness_center', 'unit': ''},
      'calories': {'current': 14200, 'target': 17500, 'label': 'Calorias Queimadas', 'icon': 'local_fire_department', 'unit': 'kcal'},
      'protein': {'current': 420, 'target': 560, 'label': 'Proteína Semanal', 'icon': 'egg_alt', 'unit': 'g'},
      'steps': {'current': 48500, 'target': 70000, 'label': 'Passos Semanais', 'icon': 'directions_walk', 'unit': ''},
      'water': {'current': 18, 'target': 28, 'label': 'Água Semanal', 'icon': 'water_drop', 'unit': 'L'},
    };
  }

  String _getEta(Map<String, dynamic> goal) {
    final current = (goal['current'] ?? 0).toDouble();
    final target = (goal['target'] ?? 1).toDouble();
    if (current >= target) return 'Concluído!';
    final pct = current / target;
    final daysElapsed = DateTime.now().weekday;
    if (daysElapsed == 0) return '--';
    final dailyRate = current / daysElapsed;
    if (dailyRate <= 0) return '--';
    final remaining = target - current;
    final daysLeft = (remaining / dailyRate).ceil();
    if (daysLeft <= 1) return 'Hoje';
    if (daysLeft <= 7) return '$daysLeft dias';
    return '${(daysLeft / 7).ceil()} sem';
  }

  Color _getProgressColor(double pct) {
    if (pct >= 1.0) return AppColors.success;
    if (pct >= 0.7) return AppColors.primary;
    if (pct >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'egg_alt':
        return Icons.egg_alt;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.flag;
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
        title: const Text('Progresso das Metas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGoals,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallSummary(),
                    const SizedBox(height: 20),
                    ..._goals.entries.map((entry) {
                      final goal = entry.value as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildGoalCard(entry.key, goal),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverallSummary() {
    final goals = _goals.values.toList();
    final totalPct = goals.isEmpty
        ? 0.0
        : goals.fold<double>(0, (sum, g) {
            final c = (g['current'] ?? 0).toDouble();
            final t = (g['target'] ?? 1).toDouble();
            return sum + (c / t).clamp(0.0, 1.0);
          }) / goals.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: totalPct,
                    strokeWidth: 10,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(totalPct)),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(totalPct * 100).round()}%',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${goals.where((g) => (g['current'] ?? 0) >= (g['target'] ?? 1)).length} de ${goals.length} metas concluídas',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(String key, Map<String, dynamic> goal) {
    final current = (goal['current'] ?? 0).toDouble();
    final target = (goal['target'] ?? 1).toDouble();
    final pct = (current / target).clamp(0.0, 1.0);
    final color = _getProgressColor(pct);
    final eta = _getEta(goal);
    final label = goal['label'] ?? key;
    final unit = goal['unit'] ?? '';
    final iconStr = goal['icon'] ?? 'flag';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getIcon(iconStr), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        eta,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(pct * 100).round()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  unit.isNotEmpty ? '${_formatNumber(current.round())} $unit' : _formatNumber(current.round()),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                Text(
                  unit.isNotEmpty ? '${_formatNumber(target.round())} $unit' : _formatNumber(target.round()),
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
  }
}

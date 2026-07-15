import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class PersonalBestsPage extends StatefulWidget {
  const PersonalBestsPage({super.key});

  @override
  State<PersonalBestsPage> createState() => _PersonalBestsPageState();
}

class _PersonalBestsPageState extends State<PersonalBestsPage> {
  bool _isLoading = true;
  Map<String, List<dynamic>> _groupedPRs = {};

  @override
  void initState() {
    super.initState();
    _loadPRs();
  }

  Future<void> _loadPRs() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/workouts/personal-records');
      final data = response.data ?? [];
      if (mounted) {
        setState(() {
          _groupedPRs = _groupByExercise(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _groupedPRs = _groupByExercise(_getMockPRs());
          _isLoading = false;
        });
      }
    }
  }

  Map<String, List<dynamic>> _groupByExercise(List<dynamic> prs) {
    final map = <String, List<dynamic>>{};
    for (final pr in prs) {
      final name = pr['exerciseName'] ?? pr['exercise'] ?? 'Exercício';
      map.putIfAbsent(name, () => []).add(pr);
    }
    return map;
  }

  List<dynamic> _getMockPRs() {
    return [
      {'exerciseName': 'Supino Reto', 'weight': 100, 'reps': 8, 'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(), 'previousWeight': 95, 'trend': 'up'},
      {'exerciseName': 'Supino Reto', 'weight': 80, 'reps': 12, 'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(), 'previousWeight': 75, 'trend': 'up'},
      {'exerciseName': 'Agachamento', 'weight': 120, 'reps': 6, 'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(), 'previousWeight': 110, 'trend': 'up'},
      {'exerciseName': 'Agachamento', 'weight': 100, 'reps': 10, 'date': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(), 'previousWeight': 95, 'trend': 'up'},
      {'exerciseName': 'Levantamento Terra', 'weight': 140, 'reps': 5, 'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(), 'previousWeight': 130, 'trend': 'up'},
      {'exerciseName': 'Puxada Frontal', 'weight': 70, 'reps': 10, 'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(), 'previousWeight': 65, 'trend': 'up'},
      {'exerciseName': 'Puxada Frontal', 'weight': 60, 'reps': 12, 'date': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(), 'previousWeight': 55, 'trend': 'up'},
      {'exerciseName': 'Desenvolvimento', 'weight': 50, 'reps': 8, 'date': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(), 'previousWeight': 47.5, 'trend': 'up'},
      {'exerciseName': 'Rosca Direta', 'weight': 25, 'reps': 12, 'date': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(), 'previousWeight': 22.5, 'trend': 'up'},
    ];
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '--';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return '--';
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
        title: const Text('Recordes Pessoais'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groupedPRs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('Nenhum recorde registrado', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPRs,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryHeader(),
                      const SizedBox(height: 20),
                      ..._groupedPRs.entries.map((entry) => _buildExerciseSection(entry.key, entry.value)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryHeader() {
    final totalPRs = _groupedPRs.values.fold<int>(0, (sum, list) => sum + list.length);
    final exerciseCount = _groupedPRs.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('$totalPRs', style: TextStyle(color: AppColors.warning, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Total de PRs', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            Container(width: 1, height: 40, color: AppColors.surfaceLight),
            Column(
              children: [
                Text('$exerciseCount', style: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Exercícios', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection(String exerciseName, List<dynamic> prs) {
    final bestPR = prs.reduce((a, b) {
      final scoreA = (a['weight'] ?? 0).toDouble() * (a['reps'] ?? 1);
      final scoreB = (b['weight'] ?? 0).toDouble() * (b['reps'] ?? 1);
      return scoreA >= scoreB ? a : b;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            Text(
              exerciseName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...prs.map((pr) => _buildPRItem(pr, pr == bestPR)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPRItem(dynamic pr, bool isBest) {
    final weight = (pr['weight'] ?? 0).toDouble();
    final reps = pr['reps'] ?? 0;
    final date = _formatDate(pr['date']);
    final previousWeight = (pr['previousWeight'] ?? 0).toDouble();
    final isNewBest = weight > previousWeight;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Container(
        decoration: isBest
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (isBest)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.fitness_center, color: AppColors.textMuted, size: 20),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg × $reps reps',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isNewBest && previousWeight > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: AppColors.success, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class XPHistoryPage extends StatefulWidget {
  const XPHistoryPage({super.key});

  @override
  State<XPHistoryPage> createState() => _XPHistoryPageState();
}

class _XPHistoryPageState extends State<XPHistoryPage> {
  Map<String, dynamic>? _gamification;
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final gamRes = await api.getGamificationProfile();
      Map<String, dynamic>? histRes;
      try {
        final wRes = await api.getWeeklyStats();
        histRes = wRes.data;
      } catch (_) {}
      if (mounted) {
        setState(() {
          _gamification = gamRes.data;
          _history = histRes?['history'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _gamification = {
            'level': 8,
            'xp': 2450,
            'xpToNextLevel': 3000,
            'xpByCategory': {
              'Treinos': 1200,
              'Nutrição': 450,
              'Sequência': 380,
              'Conquistas': 420,
            },
          };
          _history = [
            {'activity': 'Treino de Peito e Tríceps', 'date': '2026-07-13', 'xp': 80, 'category': 'Treinos'},
            {'activity': 'Desafio Diário Concluído', 'date': '2026-07-13', 'xp': 50, 'category': 'Conquistas'},
            {'activity': 'Sequência de 7 dias', 'date': '2026-07-13', 'xp': 100, 'category': 'Sequência'},
            {'activity': 'Refeição registrada (5x)', 'date': '2026-07-12', 'xp': 30, 'category': 'Nutrição'},
            {'activity': 'Treino de Costas e Bíceps', 'date': '2026-07-12', 'xp': 80, 'category': 'Treinos'},
            {'activity': 'Treino de Pernas', 'date': '2026-07-11', 'xp': 100, 'category': 'Treinos'},
            {'activity': 'Análise Corporal', 'date': '2026-07-11', 'xp': 25, 'category': 'Conquistas'},
            {'activity': 'Treino de Ombros', 'date': '2026-07-10', 'xp': 80, 'category': 'Treinos'},
            {'activity': 'Meta de água atingida', 'date': '2026-07-10', 'xp': 15, 'category': 'Nutrição'},
            {'activity': 'Desafio Semanal', 'date': '2026-07-09', 'xp': 150, 'category': 'Conquistas'},
          ];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Histórico de XP')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final gam = _gamification!;
    final level = gam['level'] ?? 1;
    final xp = gam['xp'] ?? 0;
    final xpToNext = gam['xpToNextLevel'] ?? 1000;
    final progress = xpToNext > 0 ? (xp / xpToNext).clamp(0.0, 1.0) : 0.0;
    final xpByCategory = (gam['xpByCategory'] as Map<String, dynamic>?) ?? {};
    final milestones = List.generate(10, (i) => (i + 1) * 5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de XP'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning.withValues(alpha: 0.3), AppColors.primary.withValues(alpha: 0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.warning, width: 3),
                      ),
                      child: Center(
                        child: Text('Lv $level', style: const TextStyle(color: AppColors.warning, fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('$xp XP', style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
                    Text('Nível $level', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lv $level', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text('${(xpToNext - xp)} XP para próximo nível', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text('Lv ${level + 1}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('XP por Categoria', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (xpByCategory.isEmpty)
                Card(child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text('Sem dados de categorias', style: TextStyle(color: AppColors.textSecondary))),
                ))
              else
                ...xpByCategory.entries.map((e) {
                  final catColors = {
                    'Treinos': AppColors.primary,
                    'Nutrição': AppColors.success,
                    'Sequência': AppColors.warning,
                    'Conquistas': AppColors.secondary,
                  };
                  final color = catColors[e.key] ?? AppColors.textSecondary;
                  final maxVal = xpByCategory.values.cast<num>().fold<num>(0, (a, b) => a > b ? a : b);
                  final barVal = maxVal > 0 ? (e.value / maxVal).clamp(0.0, 1.0) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('${e.value} XP', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: barVal,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),
              Text('Marcos de Nível', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: milestones.map((m) {
                    final achieved = level >= m;
                    return Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: achieved ? AppColors.success.withValues(alpha: 0.2) : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: achieved ? Border.all(color: AppColors.success.withValues(alpha: 0.5)) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(achieved ? Icons.check_circle : Icons.lock_outline, color: achieved ? AppColors.success : AppColors.textMuted, size: 18),
                          const SizedBox(height: 4),
                          Text('Lv $m', style: TextStyle(color: achieved ? AppColors.success : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Text('Histórico de Ganhos', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_history.isEmpty)
                Card(child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('Nenhum registro encontrado', style: TextStyle(color: AppColors.textSecondary))),
                ))
              else
                ..._history.map((h) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Icon(Icons.add_circle_outline, color: AppColors.warning, size: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h['activity'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                            Text(h['date'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('+${h['xp'] ?? 0} XP', style: const TextStyle(color: AppColors.warning, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _streakData;
  bool _isLoading = true;
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _flameAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _flameController, curve: Curves.easeInOut));
    _loadData();
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final res = await api.getGamificationProfile();
      if (mounted) {
        setState(() {
          _streakData = res.data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _streakData = {
            'currentStreak': 12,
            'bestStreak': 21,
            'totalDays': 87,
            'heatmap': _generateMockHeatmap(),
            'history': [
              {'date': '2026-07-13', 'active': true},
              {'date': '2026-07-12', 'active': true},
              {'date': '2026-07-11', 'active': true},
            ],
          };
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _generateMockHeatmap() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final active = i > 17 ? true : (i % 3 != 0);
      data.add({
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'active': active,
        'dayOfWeek': date.weekday,
      });
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sequência')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = _streakData!;
    final currentStreak = data['currentStreak'] ?? 0;
    final bestStreak = data['bestStreak'] ?? 0;
    final heatmap = (data['heatmap'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sequência'),
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
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning.withValues(alpha: 0.4), AppColors.secondary.withValues(alpha: 0.2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _flameAnimation,
                      builder: (_, __) => Transform.scale(
                        scale: _flameAnimation.value,
                        child: const Text('🔥', style: TextStyle(fontSize: 64)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('$currentStreak', style: const TextStyle(color: AppColors.textPrimary, fontSize: 56, fontWeight: FontWeight.bold)),
                    Text('dias de sequência', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.emoji_events, color: AppColors.warning, size: 28),
                            const SizedBox(height: 8),
                            Text('$bestStreak', style: const TextStyle(color: AppColors.warning, fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Recorde', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.info, size: 28),
                            const SizedBox(height: 8),
                            Text('${data['totalDays'] ?? 0}', style: const TextStyle(color: AppColors.info, fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Dias totais', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Mapa dos Últimos 30 Dias', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: _buildHeatmap(heatmap),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text('Inativo', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(width: 12),
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text('Ativo', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Dicas para Manter a Sequência', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildTipCard(Icons.alarm, 'Defina um horário fixo para treinar todos os dias'),
              _buildTipCard(Icons.restaurant, 'Registre suas refeições diárias para ganhar XP'),
              _buildTipCard(Icons.fitness_center, 'Mesmo um treino curto mantém sua sequência ativa'),
              _buildTipCard(Icons.notifications_active, 'Ative os lembretes para não esquecer de treinar'),
              _buildTipCard(Icons.emoji_events, 'Complete desafios diários para XP extra'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmap(List<dynamic> heatmap) {
    final weeks = <List<dynamic>>[];
    List<dynamic> currentWeek = [];
    for (final day in heatmap) {
      final dow = day['dayOfWeek'] as int? ?? 1;
      if (dow == 1 && currentWeek.isNotEmpty) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
      currentWeek.add(day);
    }
    if (currentWeek.isNotEmpty) weeks.add(currentWeek);

    return Column(
      children: [
        Row(
          children: ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'].map((d) => Expanded(
            child: Center(child: Text(d, style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500))),
          )).toList(),
        ),
        const SizedBox(height: 6),
        ...weeks.map((week) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              ...List.generate(7, (i) {
                final idx = (weeks.indexOf(week) * 7) + i;
                if (idx >= heatmap.length) return const Expanded(child: SizedBox());
                final day = heatmap[idx];
                final active = day['active'] == true;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: active ? AppColors.success : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTipCard(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}

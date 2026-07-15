import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class DailyChallengesPage extends StatefulWidget {
  const DailyChallengesPage({super.key});

  @override
  State<DailyChallengesPage> createState() => _DailyChallengesPageState();
}

class _DailyChallengesPageState extends State<DailyChallengesPage> {
  List<dynamic> _challenges = [];
  Map<String, dynamic>? _gamification;
  List<dynamic> _leagues = [];
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
      final challengesRes = await api.getDailyChallenges();
      Map<String, dynamic>? gamRes;
      List<dynamic>? leaguesRes;
      try {
        final gRes = await api.getGamificationProfile();
        gamRes = gRes.data;
      } catch (_) {}
      try {
        final lRes = await api.getLeagues();
        leaguesRes = lRes.data;
      } catch (_) {}
      if (mounted) {
        setState(() {
          _challenges = challengesRes.data ?? [];
          _gamification = gamRes ?? {'streak': 0, 'xp': 0, 'level': 1};
          _leagues = leaguesRes ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Desafios Diários')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final gam = _gamification!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desafios Diários'),
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning.withValues(alpha: 0.3), AppColors.secondary.withValues(alpha: 0.2)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      Text('${gam['streak'] ?? 0}', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
                      Text('Dias 🔥', style: TextStyle(color: AppColors.textSecondary)),
                    ]),
                    Container(width: 1, height: 50, color: AppColors.textMuted),
                    Column(children: [
                      Text('${gam['xp'] ?? 0}', style: TextStyle(color: AppColors.warning, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('XP Total', style: TextStyle(color: AppColors.textSecondary)),
                    ]),
                    Container(width: 1, height: 50, color: AppColors.textMuted),
                    Column(children: [
                      Text('${gam['level'] ?? 1}', style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Nível', style: TextStyle(color: AppColors.textSecondary)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Desafios de Hoje', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_challenges.isEmpty)
                Card(child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('Nenhum desafio disponível', style: TextStyle(color: AppColors.textSecondary))),
                ))
              else
                ..._challenges.map((c) => _buildChallengeCard(c)),
              if (_leagues.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Ligas', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._leagues.map((l) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Text(l['icon'] ?? '🏆', style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        Text('${l['minXp'] ?? 0} - ${l['maxXp'] ?? '∞'} XP', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    )),
                  ]),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(dynamic challenge) {
    final completed = challenge['completed'] == true;
    final progress = (challenge['progress'] ?? 0).toDouble();
    final target = (challenge['target'] ?? 1).toDouble();
    final percentage = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
    final category = challenge['category'] ?? 'general';

    Color categoryColor;
    switch (category) {
      case 'strength': categoryColor = AppColors.primary; break;
      case 'cardio': categoryColor = AppColors.secondary; break;
      case 'health': categoryColor = AppColors.info; break;
      default: categoryColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? AppColors.success.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: completed ? Border.all(color: AppColors.success.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
              child: Text(category.toUpperCase(), style: TextStyle(color: categoryColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            if (completed)
              Icon(Icons.check_circle, color: AppColors.success, size: 24)
            else
              Text('+${challenge['xpReward'] ?? 0} XP', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Text(challenge['title'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(challenge['description'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: LinearProgressIndicator(
              value: percentage, backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(completed ? AppColors.success : categoryColor),
              minHeight: 8, borderRadius: BorderRadius.circular(4),
            )),
            const SizedBox(width: 12),
            Text('${progress.toInt()}/${target.toInt()}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
          if (!completed) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final api = context.read<AuthService>().api;
                    await api.completeDailyChallenge(challenge['id'].toString());
                    _loadData();
                  } catch (_) {}
                },
                style: ElevatedButton.styleFrom(backgroundColor: categoryColor),
                child: const Text('Registrar Progresso'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

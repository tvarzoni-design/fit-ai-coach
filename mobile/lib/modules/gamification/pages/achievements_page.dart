import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  List<dynamic> _achievements = [];
  Map<String, dynamic>? _gamification;
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
      final achievementsRes = await api.getMyAchievements();
      Map<String, dynamic>? gamRes;
      try {
        final gRes = await api.getGamificationProfile();
        gamRes = gRes.data;
      } catch (_) {}
      if (mounted) {
        setState(() {
          _achievements = achievementsRes.data ?? [];
          _gamification = gamRes ?? {'level': 1, 'xp': 0};
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
        appBar: AppBar(title: const Text('Conquistas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final gamification = _gamification!;
    final unlockedCount = _achievements.where((a) => a['unlocked'] == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Conquistas')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat('Nível', '${gamification['level'] ?? 1}', AppColors.primary),
                          _buildStat('XP Total', '${gamification['xp'] ?? 0}', AppColors.warning),
                          _buildStat('Desbloqueadas', '$unlockedCount/${_achievements.length}', AppColors.success),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Todas as Conquistas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._achievements.map((a) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: (a['unlocked'] == true ? AppColors.success : AppColors.surfaceLight).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      a['unlocked'] == true ? Icons.emoji_events : Icons.lock_outline,
                      color: a['unlocked'] == true ? AppColors.success : AppColors.textMuted,
                    ),
                  ),
                  title: Text(a['name'] ?? a['title'] ?? 'Conquista', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(a['description'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: a['unlocked'] == true
                      ? Icon(Icons.check_circle, color: AppColors.success)
                      : Icon(Icons.lock_outline, color: AppColors.textMuted),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

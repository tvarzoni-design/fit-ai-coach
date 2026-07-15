import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<dynamic> _leaderboard = [];
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
      final lbRes = await api.getLeaderboard();
      Map<String, dynamic>? gamRes;
      try {
        final gRes = await api.getGamificationProfile();
        gamRes = gRes.data;
      } catch (_) {}
      if (mounted) {
        setState(() {
          _leaderboard = lbRes.data ?? [];
          _gamification = gamRes ?? {'weeklyRank': 0, 'level': 1, 'xp': 0, 'streak': 0};
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
        appBar: AppBar(title: const Text('Leaderboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final gam = _gamification!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabStat('Seu Rank', '#${gam['weeklyRank'] ?? 0}', AppColors.primary),
                _buildTabStat('Nível', '${gam['level'] ?? 1}', AppColors.warning),
                _buildTabStat('XP', '${gam['xp'] ?? 0}', AppColors.success),
                _buildTabStat('Streak', '${gam['streak'] ?? 0} dias', AppColors.secondary),
              ],
            ),
          ),
          Expanded(
            child: _leaderboard.isEmpty
                ? Center(child: Text('Nenhum dado disponível', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = _leaderboard[index];
                      final isMe = entry['isMe'] == true;
                      return _buildLeaderboardEntry(entry, isMe);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _buildLeaderboardEntry(dynamic entry, bool isMe) {
    final rank = entry['rank'] ?? 0;
    Color rankColor;
    switch (rank) {
      case 1: rankColor = Color(0xFFFFD700); break;
      case 2: rankColor = Color(0xFFC0C0C0); break;
      case 3: rankColor = Color(0xFFCD7F32); break;
      default: rankColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isMe ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('$rank', style: TextStyle(color: rank <= 3 ? rankColor : AppColors.textSecondary, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: rankColor.withValues(alpha: 0.2),
            child: Text('${entry['name'] ?? 'U'}'[0], style: TextStyle(color: rankColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['name'] ?? 'Usuário', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Nível ${entry['level'] ?? 1} • ${entry['streak'] ?? 0} dias 🔥', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text('${entry['xp'] ?? 0} XP', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class LeagueDetailPage extends StatefulWidget {
  const LeagueDetailPage({super.key});

  @override
  State<LeagueDetailPage> createState() => _LeagueDetailPageState();
}

class _LeagueDetailPageState extends State<LeagueDetailPage> {
  Map<String, dynamic>? _league;
  List<dynamic> _members = [];
  bool _isLoading = true;
  String _myId = 'me';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final leaguesRes = await api.getLeagues();
      final leaderRes = await api.getLeaderboard();
      final leagues = leaguesRes.data as List<dynamic>? ?? [];
      final members = leaderRes.data as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _league = leagues.isNotEmpty ? leagues.first : null;
          _members = members;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _league = {
            'name': 'Liga Ouro',
            'icon': '🏆',
            'minXp': 500,
            'maxXp': 1500,
            'periodDays': 30,
            'daysRemaining': 12,
          };
          _members = [
            {'userId': '1', 'name': 'Lucas M.', 'xp': 1280, 'avatar': null, 'isMe': false},
            {'userId': '2', 'name': 'Ana P.', 'xp': 1150, 'avatar': null, 'isMe': false},
            {'userId': '3', 'name': 'Carlos R.', 'xp': 980, 'avatar': null, 'isMe': false},
            {'userId': 'me', 'name': 'Você', 'xp': 850, 'avatar': null, 'isMe': true},
            {'userId': '5', 'name': 'Fernanda L.', 'xp': 720, 'avatar': null, 'isMe': false},
            {'userId': '6', 'name': 'Pedro H.', 'xp': 680, 'avatar': null, 'isMe': false},
            {'userId': '7', 'name': 'Julia S.', 'xp': 590, 'avatar': null, 'isMe': false},
            {'userId': '8', 'name': 'Rafael G.', 'xp': 540, 'avatar': null, 'isMe': false},
            {'userId': '9', 'name': 'Beatriz A.', 'xp': 480, 'avatar': null, 'isMe': false},
            {'userId': '10', 'name': 'Thiago F.', 'xp': 350, 'avatar': null, 'isMe': false},
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
        appBar: AppBar(title: const Text('Detalhe da Liga')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final league = _league;
    final daysRemaining = league?['daysRemaining'] ?? 0;
    final sorted = List<dynamic>.from(_members)..sort((a, b) => (b['xp'] ?? 0).compareTo(a['xp'] ?? 0));
    final totalMembers = sorted.length;
    final promotionLimit = (totalMembers * 0.3).ceil();
    final relegationStart = totalMembers - (totalMembers * 0.3).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe da Liga'),
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
                    colors: [AppColors.warning.withValues(alpha: 0.3), AppColors.surface],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(league?['icon'] ?? '🏆', style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text(league?['name'] ?? 'Liga', style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      'Requisito: ${league?['minXp'] ?? 0} - ${league?['maxXp'] ?? '∞'} XP',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text('Encerra em $daysRemaining dias', style: const TextStyle(color: AppColors.warning, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_upward, color: AppColors.success, size: 20),
                          const SizedBox(height: 4),
                          Text('Top $promotionLimit', style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Promovidos', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Icon(Icons.remove, color: AppColors.info, size: 20),
                          const SizedBox(height: 4),
                          Text('Meio', style: const TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Mantidos', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Icon(Icons.arrow_downward, color: AppColors.error, size: 20),
                          const SizedBox(height: 4),
                          Text('Últimos $promotionLimit', style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Rebaixados', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Ranking', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...List.generate(sorted.length, (i) {
                final m = sorted[i];
                final isMe = m['isMe'] == true;
                final isPromotion = i < promotionLimit;
                final isRelegation = i >= relegationStart;
                Color zoneColor = AppColors.info;
                if (isPromotion) zoneColor = AppColors.success;
                if (isRelegation) zoneColor = AppColors.error;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: isMe ? Border.all(color: AppColors.primary.withValues(alpha: 0.5)) : Border.all(color: zoneColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: zoneColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('${i + 1}', style: TextStyle(color: zoneColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            (m['name'] ?? '?')[0].toUpperCase(),
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? 'Você' : (m['name'] ?? ''),
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            if (isPromotion)
                              Text('Zona de promoção', style: TextStyle(color: AppColors.success, fontSize: 10)),
                            if (isRelegation)
                              Text('Zona de rebaixamento', style: TextStyle(color: AppColors.error, fontSize: 10)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.warning, size: 16),
                          const SizedBox(width: 4),
                          Text('${m['xp'] ?? 0} XP', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

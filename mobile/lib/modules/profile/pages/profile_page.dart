import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;
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
      final profileRes = await api.getProfile();
      Map<String, dynamic>? gamRes;
      try {
        final gRes = await api.getGamificationProfile();
        gamRes = gRes.data;
      } catch (_) {}
      if (mounted) {
        setState(() {
          _profile = profileRes.data;
          _gamification = gamRes ?? {'level': 1, 'xp': 0, 'streak': 0};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _profile = {'firstName': 'Usuário', 'email': 'user@email.com'};
          _gamification = {'level': 1, 'xp': 0, 'streak': 0};
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final profile = _profile!;
    final gamification = _gamification!;
    final name = profile['firstName'] ?? 'Usuário';
    final email = profile['email'] ?? '';
    final level = gamification['level'] ?? 1;
    final xp = gamification['xp'] ?? 0;
    final streak = gamification['streak'] ?? 0;
    final nextLevelXp = (level * 1000);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.go('/settings')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(email, style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sua Jornada', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildGamificationStat('Nível', '$level', AppColors.primary),
                          _buildGamificationStat('XP', '$xp', AppColors.warning),
                          _buildGamificationStat('Sequência', '🔥 $streak', AppColors.secondary),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (xp / nextLevelXp).clamp(0.0, 1.0),
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$xp / $nextLevelXp XP', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _buildMenuItem(Icons.person_outline, 'Editar Perfil', () => context.go('/profile/edit')),
                    _buildMenuItem(Icons.emoji_events_outlined, 'Conquistas', () => context.go('/achievements')),
                    _buildMenuItem(Icons.stars, 'Desafios Diários', () => context.go('/daily-challenges')),
                    _buildMenuItem(Icons.monitor_weight, 'Análise Corporal', () => context.go('/body-analysis')),
                    _buildMenuItem(Icons.psychology, 'Predições IA', () => context.go('/predictive')),
                    _buildMenuItem(Icons.people, 'Comunidade', () => context.go('/community')),
                    _buildMenuItem(Icons.diamond, 'Premium', () => context.go('/premium')),
                    _buildMenuItem(Icons.notifications_outlined, 'Notificações', () => context.go('/notifications')),
                    _buildMenuItem(Icons.settings_outlined, 'Configurações', () => context.go('/settings')),
                    const Divider(),
                    _buildMenuItem(Icons.logout, 'Sair', () {
                      context.read<AuthService>().logout();
                      context.go('/');
                    }, isDestructive: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamificationStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textSecondary),
      title: Text(label, style: TextStyle(color: isDestructive ? AppColors.error : null)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class RewardDetailPage extends StatefulWidget {
  final Map<String, dynamic>? reward;
  const RewardDetailPage({super.key, this.reward});

  @override
  State<RewardDetailPage> createState() => _RewardDetailPageState();
}

class _RewardDetailPageState extends State<RewardDetailPage> {
  Map<String, dynamic> _reward = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reward = widget.reward ?? {};
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/gamification/rewards/${_reward['id'] ?? ''}');
      if (mounted) setState(() { _reward = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _reward = _reward.isNotEmpty ? _reward : {
            'name': 'Primeiro Treino',
            'description': 'Complete seu primeiro treino no Fit AI Coach.',
            'icon': 'emoji_events',
            'earned': true,
            'dateEarned': '10/07/2026',
            'progress': 1.0,
            'rarity': 'Comum',
            'xpReward': 50,
          };
          _isLoading = false;
        });
      }
    }
  }

  IconData _iconFromName(String? name) {
    switch (name) {
      case 'emoji_events': return Icons.emoji_events;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'fitness_center': return Icons.fitness_center;
      case 'directions_walk': return Icons.directions_walk;
      case 'star': return Icons.star;
      case 'bolt': return Icons.bolt;
      case 'military_tech': return Icons.military_tech;
      default: return Icons.emoji_events;
    }
  }

  Color _rarityColor(String? rarity) {
    switch (rarity) {
      case 'Comum': return AppColors.textSecondary;
      case 'Raro': return AppColors.info;
      case 'Épico': return AppColors.primary;
      case 'Lendário': return AppColors.warning;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conquista')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final name = _reward['name'] ?? 'Conquista';
    final desc = _reward['description'] ?? '';
    final earned = _reward['earned'] == true;
    final progress = (_reward['progress'] ?? 0.0).toDouble().clamp(0.0, 1.0);
    final rarity = _reward['rarity'] ?? 'Comum';
    final dateEarned = _reward['dateEarned'];
    final xpReward = _reward['xpReward'] ?? 0;
    final icon = _reward['icon'] ?? 'emoji_events';

    return Scaffold(
      appBar: AppBar(title: const Text('Conquista')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildMedal(icon, earned),
            const SizedBox(height: 24),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            _buildRarityBadge(rarity),
            const SizedBox(height: 20),
            _buildProgressBar(progress, earned),
            const SizedBox(height: 16),
            _buildInfoCard(dateEarned, xpReward),
            const SizedBox(height: 24),
            _buildShareButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedal(String icon, bool earned) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: earned
            ? const LinearGradient(colors: [AppColors.warning, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : const LinearGradient(colors: [AppColors.surfaceLight, AppColors.surface]),
        boxShadow: earned ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)] : null,
      ),
      child: Icon(
        _iconFromName(icon),
        size: 56,
        color: earned ? Colors.white : AppColors.textMuted,
      ),
    );
  }

  Widget _buildRarityBadge(String rarity) {
    final color = _rarityColor(rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(rarity, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildProgressBar(double progress, bool earned) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(earned ? 'Desbloqueada!' : 'Em progresso', style: TextStyle(color: earned ? AppColors.success : AppColors.textSecondary, fontWeight: FontWeight.w600)),
            Text('${(progress * 100).toInt()}%', style: TextStyle(color: earned ? AppColors.success : AppColors.textMuted, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(earned ? AppColors.success : AppColors.primary),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String? dateEarned, int xpReward) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(dateEarned != null ? Icons.calendar_today : Icons.hourglass_empty, color: AppColors.textMuted, size: 20),
              title: Text('Data', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              trailing: Text(dateEarned ?? 'Em progresso', style: const TextStyle(fontWeight: FontWeight.w600)),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(color: AppColors.surfaceLight),
            ListTile(
              leading: Icon(Icons.bolt, color: AppColors.warning, size: 20),
              title: Text('Recompensa XP', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              trailing: Text('+$xpReward XP', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Função de compartilhar em breve!'), backgroundColor: AppColors.info),
          );
        },
        icon: const Icon(Icons.share),
        label: const Text('Compartilhar'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

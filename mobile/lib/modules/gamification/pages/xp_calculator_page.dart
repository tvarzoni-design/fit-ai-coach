import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class XPCalculatorPage extends StatefulWidget {
  const XPCalculatorPage({super.key});

  @override
  State<XPCalculatorPage> createState() => _XPCalculatorPageState();
}

class _XPCalculatorPageState extends State<XPCalculatorPage> {
  Map<String, dynamic>? _xpData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadXPData();
  }

  Future<void> _loadXPData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/gamification/xp');
      if (mounted) setState(() { _xpData = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _xpData = {
            'currentXP': 3450,
            'currentLevel': 12,
            'nextLevelXP': 5000,
            'totalXPEarned': 18750,
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calculadora XP')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentXP = _xpData!['currentXP'] ?? 0;
    final currentLevel = _xpData!['currentLevel'] ?? 1;
    final nextLevelXP = _xpData!['nextLevelXP'] ?? 5000;
    final xpRemaining = nextLevelXP - currentXP;
    final progress = currentXP / nextLevelXP;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora XP'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadXPData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelCard(currentLevel, currentXP, nextLevelXP, progress, xpRemaining),
              const SizedBox(height: 20),
              Text(
                'Fontes de XP',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildXPSourceItem(Icons.fitness_center, 'Treino Completo', 50, AppColors.success),
              _buildXPSourceItem(Icons.restaurant, 'Refeição Registrada', 10, AppColors.info),
              _buildXPSourceItem(Icons.emoji_events, 'Desafio Completo', 100, AppColors.warning),
              _buildXPSourceItem(Icons.whatshot, 'Sequência Diária', 25, AppColors.error),
              _buildXPSourceItem(Icons.water_drop, 'Meta de Água', 15, AppColors.primary),
              _buildXPSourceItem(Icons.star, 'Record Pessoal', 75, AppColors.secondary),
              _buildXPSourceItem(Icons.share, 'Compartilhar Treino', 20, AppColors.info),
              _buildXPSourceItem(Icons.comment, 'Postar na Comunidade', 10, AppColors.textMuted),
              const SizedBox(height: 20),
              _buildEstimateCard(currentXP, nextLevelXP),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(int level, int currentXP, int nextLevelXP, double progress, int remaining) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$level',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nível $level',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$currentXP / $nextLevelXP XP',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '$remaining XP para o próximo nível',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildXPSourceItem(IconData icon, String label, int xp, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${xp}XP',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateCard(int currentXP, int nextLevelXP) {
    final remaining = nextLevelXP - currentXP;
    final workoutsNeeded = (remaining / 50).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Estimativa',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Para alcançar o nível ${(_xpData!['currentLevel'] ?? 12) + 1}, você precisa de mais $remaining XP.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Isso equivale a aproximadamente $workoutsNeeded treinos completos.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class StreakFreezePage extends StatefulWidget {
  const StreakFreezePage({super.key});

  @override
  State<StreakFreezePage> createState() => _StreakFreezePageState();
}

class _StreakFreezePageState extends State<StreakFreezePage> {
  Map<String, dynamic>? _streakData;
  bool _isLoading = true;
  bool _isBuying = false;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/gamification/streak');
      if (mounted) setState(() { _streakData = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _streakData = {
            'currentStreak': 23,
            'longestStreak': 45,
            'availableFreezes': 2,
            'freezeCost': 100,
            'userCoins': 350,
            'freezeActive': false,
            'freezeHistory': [
              {'date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(), 'action': 'used'},
              {'date': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(), 'action': 'purchased'},
              {'date': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(), 'action': 'used'},
            ],
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Streak Freeze')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentStreak = _streakData!['currentStreak'] ?? 0;
    final availableFreezes = _streakData!['availableFreezes'] ?? 0;
    final freezeActive = _streakData!['freezeActive'] ?? false;
    final freezeCost = _streakData!['freezeCost'] ?? 100;
    final userCoins = _streakData!['userCoins'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Freeze'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStreakData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStreakInfo(currentStreak, freezeActive),
              const SizedBox(height: 20),
              _buildFreezeStatus(availableFreezes, freezeActive),
              const SizedBox(height: 20),
              _buildBuyFreezeSection(freezeCost, userCoins, availableFreezes),
              const SizedBox(height: 20),
              _buildFreezeHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakInfo(int currentStreak, bool freezeActive) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, AppColors.warning.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.whatshot, color: Colors.white, size: 40),
              const SizedBox(width: 8),
              Text(
                '$currentStreak',
                style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dias de Sequência',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 16),
          ),
          if (freezeActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Freeze Ativo Hoje',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFreezeStatus(int availableFreezes, bool freezeActive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status do Freeze',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.ac_unit, color: AppColors.info, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$availableFreezes disponíveis',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Cada freeze protege sua sequência por 1 dia',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: availableFreezes > 0 ? _toggleFreeze : null,
                icon: Icon(
                  freezeActive ? Icons.stop : Icons.play_arrow,
                  size: 18,
                ),
                label: Text(freezeActive ? 'Desativar Freeze' : 'Ativar Freeze Hoje'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyFreezeSection(int freezeCost, int userCoins, int currentFreezes) {
    final canAfford = userCoins >= freezeCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Comprar Freeze',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: AppColors.warning, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$userCoins',
                      style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.ac_unit, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1 Streak Freeze', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        Text('Protege sua sequência por 1 dia', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: AppColors.warning, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$freezeCost',
                        style: TextStyle(
                          color: canAfford ? AppColors.textPrimary : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (canAfford && !_isBuying) ? _buyFreeze : null,
                icon: _isBuying
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.shopping_cart, size: 18),
                label: Text(_isBuying ? 'Comprando...' : 'Comprar Freeze'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreezeHistory() {
    final history = List<Map<String, dynamic>>.from(_streakData!['freezeHistory'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico de Freezes',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('Nenhum histórico de freeze', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          )
        else
          ...history.map((entry) => _buildHistoryItem(entry)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final action = entry['action'] ?? 'unknown';
    final date = DateTime.tryParse(entry['date'] ?? '');
    final isUsed = action == 'used';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isUsed ? AppColors.info : AppColors.success).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isUsed ? Icons.ac_unit : Icons.shopping_cart,
              color: isUsed ? AppColors.info : AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUsed ? 'Freeze Utilizado' : 'Freeze Comprado',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
                ),
                if (date != null)
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFreeze() async {
    final freezeActive = _streakData!['freezeActive'] ?? false;
    try {
      final api = context.read<AuthService>().api;
      await api.post('/gamification/streak/freeze', data: {'activate': !freezeActive});
      if (mounted) {
        setState(() => _streakData!['freezeActive'] = !freezeActive);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(freezeActive ? 'Freeze desativado' : 'Freeze ativado para hoje'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Erro ao alterar freeze'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _buyFreeze() async {
    setState(() => _isBuying = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/gamification/streak/freeze/buy', data: {});
      if (mounted) {
        setState(() {
          _isBuying = false;
          _streakData!['availableFreezes'] = (_streakData!['availableFreezes'] ?? 0) + 1;
          _streakData!['userCoins'] = (_streakData!['userCoins'] ?? 0) - (_streakData!['freezeCost'] ?? 100);
          (_streakData!['freezeHistory'] as List).insert(0, {
            'date': DateTime.now().toIso8601String(),
            'action': 'purchased',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Freeze comprado com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBuying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Erro ao comprar freeze'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

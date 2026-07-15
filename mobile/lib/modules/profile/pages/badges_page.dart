import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  List<dynamic> _badges = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/gamification/badges');
      if (mounted) setState(() { _badges = response.data ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _badges = _getMockBadges();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getMockBadges() {
    return [
      {'id': '1', 'name': 'Primeiro Treino', 'description': 'Complete seu primeiro treino', 'icon': '🏋️', 'category': 'Treino', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String()},
      {'id': '2', 'name': 'Sequência de 7 Dias', 'description': 'Treine por 7 dias seguidos', 'icon': '🔥', 'category': 'Consistência', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String()},
      {'id': '3', 'name': 'Força Bruta', 'description': 'Aumente seu record em 3 exercícios', 'icon': '💪', 'category': 'Treino', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String()},
      {'id': '4', 'name': '100 Treinos', 'description': 'Complete 100 treinos no total', 'icon': '🎯', 'category': 'Treino', 'unlocked': false, 'requirement': '72/100 treinos'},
      {'id': '5', 'name': 'Social Butterfly', 'description': 'Faça 10 amigos na comunidade', 'icon': '🦋', 'category': 'Comunidade', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String()},
      {'id': '6', 'name': 'Sequência de 30 Dias', 'description': 'Treine por 30 dias seguidos', 'icon': '⚡', 'category': 'Consistência', 'unlocked': false, 'requirement': '18/30 dias'},
      {'id': '7', 'name': 'Maratonista', 'description': 'Complete 500 treinos no total', 'icon': '🏃', 'category': 'Treino', 'unlocked': false, 'requirement': '72/500 treinos'},
      {'id': '8', 'name': 'Post Popular', 'description': 'Receba 50 likes em um post', 'icon': '⭐', 'category': 'Comunidade', 'unlocked': false, 'requirement': '32/50 likes'},
      {'id': '9', 'name': 'Nutricionista', 'description': 'Siga seu plano nutricional por 30 dias', 'icon': '🥗', 'category': 'Especial', 'unlocked': false, 'requirement': '12/30 dias'},
      {'id': '10', 'name': 'Madrugador', 'description': 'Acordes antes das 6h por 10 dias', 'icon': '🌅', 'category': 'Especial', 'unlocked': true, 'unlockedAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String()},
      {'id': '11', 'name': 'Mentor', 'description': 'Ajude 5 membros da comunidade', 'icon': '🧠', 'category': 'Comunidade', 'unlocked': false, 'requirement': '2/5 membros'},
      {'id': '12', 'name': 'Sequência de 90 Dias', 'description': 'Treine por 90 dias seguidos', 'icon': '🏆', 'category': 'Consistência', 'unlocked': false, 'requirement': '18/90 dias'},
    ];
  }

  List<dynamic> _getFilteredBadges() {
    if (_selectedCategory == 'Todas') return _badges;
    return _badges.where((b) => b['category'] == _selectedCategory).toList();
  }

  int _getUnlockedCount() => _badges.where((b) => b['unlocked'] == true).length;

  void _showBadgeDetail(dynamic badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: badge['unlocked'] == true
                    ? AppColors.warning.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                shape: BoxShape.circle,
                boxShadow: badge['unlocked'] == true
                    ? [
                        BoxShadow(
                          color: AppColors.warning.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  badge['icon'] ?? '🏅',
                  style: TextStyle(fontSize: 36, color: badge['unlocked'] == true ? null : Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge['name'],
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge['description'],
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (badge['unlocked'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Desbloqueado em ${_formatDate(badge['unlockedAt'])}',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge['requirement'] ?? 'Requisito não disponível',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    final date = DateTime.parse(isoDate);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Todas', 'Treino', 'Comunidade', 'Consistência', 'Especial'];
    final filtered = _getFilteredBadges();

    return Scaffold(
      appBar: AppBar(title: const Text('Medalhas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBadges,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildCategoryFilter(categories),
                    const SizedBox(height: 16),
                    _buildBadgesGrid(filtered),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final unlocked = _getUnlockedCount();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryStat('Total', '${_badges.length}', AppColors.primary),
            _buildSummaryStat('Desbloqueadas', '$unlocked', AppColors.success),
            _buildSummaryStat('Bloqueadas', '${_badges.length - unlocked}', AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = categories[index] == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceLight,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (_) => setState(() => _selectedCategory = categories[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgesGrid(List<dynamic> badges) {
    if (badges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Nenhuma medalha nesta categoria', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) => _buildBadgeItem(badges[index]),
    );
  }

  Widget _buildBadgeItem(dynamic badge) {
    final isUnlocked = badge['unlocked'] == true;

    return GestureDetector(
      onTap: () => _showBadgeDetail(badge),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? AppColors.warning.withValues(alpha: 0.5) : AppColors.surfaceLight,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.warning.withValues(alpha: 0.15)
                    : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge['icon'] ?? '🏅',
                  style: TextStyle(
                    fontSize: 28,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge['name'],
              style: TextStyle(
                color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isUnlocked && badge['requirement'] != null) ...[
              const SizedBox(height: 2),
              Text(
                badge['requirement'],
                style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

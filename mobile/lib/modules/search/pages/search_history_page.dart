import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SearchHistoryPage extends StatefulWidget {
  const SearchHistoryPage({super.key});

  @override
  State<SearchHistoryPage> createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  bool _isLoading = true;
  List<String> _recentSearches = [];
  List<Map<String, dynamic>> _trendingSearches = [];
  List<Map<String, dynamic>> _popularExercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/search/history');
      if (mounted) {
        setState(() {
          _recentSearches = List<String>.from(response.data?['recent'] ?? []);
          _trendingSearches = List<Map<String, dynamic>>.from(response.data?['trending'] ?? []);
          _popularExercises = List<Map<String, dynamic>>.from(response.data?['popular'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recentSearches = _getMockRecentSearches();
          _trendingSearches = _getMockTrendingSearches();
          _popularExercises = _getMockPopularExercises();
          _isLoading = false;
        });
      }
    }
  }

  List<String> _getMockRecentSearches() {
    return [
      'Treino de peito',
      'Supino reto',
      'Exercícios para costas',
      'Receita low carb',
      'Maria Silva',
      'Treino de pernas',
    ];
  }

  List<Map<String, dynamic>> _getMockTrendingSearches() {
    return [
      {'term': 'Treino HIIT', 'count': 1250, 'trend': 'up'},
      {'term': 'Dieta cetogênica', 'count': 980, 'trend': 'up'},
      {'term': 'Exercícios em casa', 'count': 870, 'trend': 'stable'},
      {'term': 'Alongamento', 'count': 750, 'trend': 'up'},
      {'term': 'Creatina', 'count': 620, 'trend': 'stable'},
    ];
  }

  List<Map<String, dynamic>> _getMockPopularExercises() {
    return [
      {'name': 'Supino Reto', 'muscle': 'Peito', 'icon': 'fitness_center', 'color': 'primary'},
      {'name': 'Agachamento Livre', 'muscle': 'Pernas', 'icon': 'fitness_center', 'color': 'secondary'},
      {'name': 'Puxada Frontal', 'muscle': 'Costas', 'icon': 'fitness_center', 'color': 'success'},
      {'name': 'Desenvolvimento', 'muscle': 'Ombros', 'icon': 'fitness_center', 'color': 'warning'},
      {'name': 'Rosca Direta', 'muscle': 'Bíceps', 'icon': 'fitness_center', 'color': 'info'},
      {'name': 'Leg Press', 'muscle': 'Pernas', 'icon': 'fitness_center', 'color': 'secondary'},
    ];
  }

  void _clearHistory() {
    setState(() => _recentSearches.clear());
  }

  void _removeSearch(String search) {
    setState(() => _recentSearches.remove(search));
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'primary':
        return AppColors.primary;
      case 'secondary':
        return AppColors.secondary;
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Histórico de Busca'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecentSearches(),
                    const SizedBox(height: 24),
                    _buildTrendingSearches(),
                    const SizedBox(height: 24),
                    _buildPopularExercises(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text('Buscas Recentes', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
            if (_recentSearches.isNotEmpty)
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Text('Limpar histórico', style: TextStyle(color: AppColors.textPrimary)),
                      content: Text('Deseja limpar todo o histórico de buscas?', style: TextStyle(color: AppColors.textSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearHistory();
                            Navigator.pop(ctx);
                          },
                          child: Text('Limpar', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Limpar tudo', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentSearches.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 8),
                    Text('Nenhuma busca recente', style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: _recentSearches.asMap().entries.map((entry) {
                final index = entry.key;
                final search = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                      title: Text(search, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: AppColors.textMuted, size: 18),
                        onPressed: () => _removeSearch(search),
                      ),
                      onTap: () {
                        context.go('/search');
                      },
                    ),
                    if (index < _recentSearches.length - 1)
                      Divider(height: 1, indent: 56, color: AppColors.surfaceLight),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTrendingSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Text('Buscas em Alta', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: _trendingSearches.asMap().entries.map((entry) {
                final index = entry.key;
                final trending = entry.value;
                final isTop = index < 3;

                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isTop ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isTop ? AppColors.primary : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  title: Text(trending['term'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
                  subtitle: Text(
                    '${trending['count']} buscas',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  trailing: Icon(
                    trending['trend'] == 'up' ? Icons.trending_up : Icons.trending_flat,
                    color: trending['trend'] == 'up' ? AppColors.success : AppColors.textMuted,
                    size: 18,
                  ),
                  onTap: () => context.go('/search'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularExercises() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Exercícios Populares', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularExercises.length,
            itemBuilder: (context, index) {
              final exercise = _popularExercises[index];
              final color = _getColor(exercise['color'] ?? 'primary');

              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.fitness_center, color: color, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise['name'] ?? '',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          exercise['muscle'] ?? '',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

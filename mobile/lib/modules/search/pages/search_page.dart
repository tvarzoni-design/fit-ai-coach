import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _query = '';
  bool _isSearching = false;
  List<String> _recentSearches = [
    'Treino de peito',
    'Exercícios para costas',
    'Maria Silva',
    'Receita low carb',
  ];
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_query.isNotEmpty) _performSearch(_query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() { _results = []; _isSearching = false; });
      return;
    }

    setState(() { _isSearching = true; _query = query; });

    if (!_recentSearches.contains(query)) {
      setState(() => _recentSearches.insert(0, query));
      if (_recentSearches.length > 8) _recentSearches.removeLast();
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _results = _getMockResults(query);
      });
    });
  }

  List<dynamic> _getMockResults(String query) {
    final q = query.toLowerCase();
    return [
      {
        'type': 'treino',
        'name': 'Treino de Peito e Tríceps',
        'subtitle': '60 min • Intermediário',
        'icon': 'fitness_center',
        'color': 'primary',
      },
      {
        'type': 'exercicio',
        'name': 'Supino Reto com Barra',
        'subtitle': 'Peito, Tríceps, Ombros',
        'icon': 'sports_martial_arts',
        'color': 'info',
      },
      {
        'type': 'usuario',
        'name': 'Maria Silva',
        'subtitle': '128 treinos • Nível 15',
        'icon': 'person',
        'color': 'secondary',
      },
      {
        'type': 'post',
        'name': 'Dicas de alimentação pré-treino',
        'subtitle': 'Postado há 2 dias • 45 likes',
        'icon': 'article',
        'color': 'success',
      },
    ].where((r) => (r['name'] as String?)?.toLowerCase().contains(q) == true || (r['type'] as String?)?.contains(q) == true).toList();
  }

  void _removeRecentSearch(String search) {
    setState(() => _recentSearches.remove(search));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Treinos'),
            Tab(text: 'Exercícios'),
            Tab(text: 'Pessoas'),
          ],
        ),
      ),
      body: _query.isEmpty
          ? _buildRecentSearches()
          : _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
                  ? _buildEmptyState()
                  : _buildResultsList(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      onChanged: _performSearch,
      decoration: InputDecoration(
        hintText: 'Buscar treinos, exercícios, pessoas...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textMuted),
                onPressed: () {
                  _searchController.clear();
                  setState(() { _query = ''; _results = []; });
                },
              )
            : null,
        border: InputBorder.none,
        filled: false,
      ),
      style: TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Buscas Recentes', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            if (_recentSearches.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _recentSearches.clear()),
                child: Text('Limpar', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.map((search) => ListTile(
              leading: Icon(Icons.history, color: AppColors.textMuted, size: 20),
              title: Text(search, style: TextStyle(color: AppColors.textPrimary)),
              trailing: IconButton(
                icon: Icon(Icons.close, color: AppColors.textMuted, size: 18),
                onPressed: () => _removeRecentSearch(search),
              ),
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
            )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('Nenhum resultado encontrado', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Tente buscar com outros termos', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final tabLabels = ['Todos', 'Treinos', 'Exercícios', 'Pessoas'];
    final tabTypes = [null, 'treino', 'exercicio', 'usuario'];
    final currentType = tabTypes[_tabController.index];

    final filtered = currentType == null
        ? _results
        : _results.where((r) => r['type'] == currentType).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Nenhum ${tabLabels[_tabController.index].toLowerCase()} encontrado',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildResultItem(filtered[index]),
    );
  }

  Widget _buildResultItem(dynamic result) {
    final color = _getColor(result['color']);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_getIcon(result['icon']), color: color),
      ),
      title: Text(result['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(result['subtitle'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: () {
        switch (result['type']) {
          case 'treino':
            context.go('/workouts');
          case 'exercicio':
            context.go('/exercise/1');
          case 'usuario':
            context.go('/profile');
          case 'post':
            context.go('/community');
        }
      },
    );
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'primary': return AppColors.primary;
      case 'secondary': return AppColors.secondary;
      case 'success': return AppColors.success;
      case 'warning': return AppColors.warning;
      case 'info': return AppColors.info;
      default: return AppColors.textMuted;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fitness_center': return Icons.fitness_center;
      case 'sports_martial_arts': return Icons.sports_martial_arts;
      case 'person': return Icons.person;
      case 'article': return Icons.article;
      default: return Icons.circle;
    }
  }
}

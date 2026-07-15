import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class WorkoutCategoriesPage extends StatefulWidget {
  const WorkoutCategoriesPage({super.key});

  @override
  State<WorkoutCategoriesPage> createState() => _WorkoutCategoriesPageState();
}

class _WorkoutCategoriesPageState extends State<WorkoutCategoriesPage> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Musculação', 'icon': Icons.fitness_center, 'color': AppColors.primary},
    {'name': 'Cardio', 'icon': Icons.favorite, 'color': AppColors.secondary},
    {'name': 'HIIT', 'icon': Icons.bolt, 'color': AppColors.warning},
    {'name': 'Funcional', 'icon': Icons.accessibility_new, 'color': AppColors.success},
    {'name': 'Yoga', 'icon': Icons.spa, 'color': const Color(0xFF81C784)},
    {'name': 'Pilates', 'icon': Icons.self_improvement, 'color': const Color(0xFF90CAF9)},
    {'name': 'Crossfit', 'icon': Icons.sports_gymnastics, 'color': AppColors.error},
    {'name': 'Calistenia', 'icon': Icons.sports_martial_arts, 'color': const Color(0xFFFFB74D)},
  ];

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Categorias'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar categorias...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text('Nenhuma categoria encontrada',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final color = category['color'] as Color;
    return GestureDetector(
      onTap: () => context.push('/workouts?category=${category['name']}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(category['icon'] as IconData, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              category['name'] as String,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

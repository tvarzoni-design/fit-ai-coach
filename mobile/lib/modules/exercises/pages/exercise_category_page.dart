import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

enum SortOption { name, difficulty, equipment }

extension SortOptionExt on SortOption {
  String get label {
    switch (this) {
      case SortOption.name:
        return 'Nome';
      case SortOption.difficulty:
        return 'Dificuldade';
      case SortOption.equipment:
        return 'Equipamento';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.name:
        return Icons.sort_by_alpha;
      case SortOption.difficulty:
        return Icons.signal_cellular_alt;
      case SortOption.equipment:
        return Icons.build;
    }
  }
}

class ExerciseCategoryPage extends StatefulWidget {
  final String categoryName;

  const ExerciseCategoryPage({super.key, required this.categoryName});

  @override
  State<ExerciseCategoryPage> createState() => _ExerciseCategoryPageState();
}

class _ExerciseCategoryPageState extends State<ExerciseCategoryPage> {
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  SortOption _sortOption = SortOption.name;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getExercises(muscle: widget.categoryName);
      if (mounted) {
        setState(() {
          _exercises = response.data is List ? response.data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _sortedExercises {
    final sorted = List<dynamic>.from(_exercises);
    switch (_sortOption) {
      case SortOption.name:
        sorted.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        break;
      case SortOption.difficulty:
        final order = {'facil': 0, 'fácil': 0, 'easy': 0, 'medio': 1, 'médio': 1, 'medium': 1, 'dificil': 2, 'difícil': 2, 'hard': 2};
        sorted.sort((a, b) {
          final da = order[(a['difficulty'] ?? '').toLowerCase()] ?? 1;
          final db = order[(b['difficulty'] ?? '').toLowerCase()] ?? 1;
          return da.compareTo(db);
        });
        break;
      case SortOption.equipment:
        sorted.sort((a, b) => (a['equipment'] ?? '').compareTo(b['equipment'] ?? ''));
        break;
    }
    return sorted;
  }

  IconData _equipmentIcon(String? equipment) {
    switch (equipment?.toLowerCase()) {
      case 'máquina':
      case 'machine':
        return Icons.settings_suggest;
      case 'halteres':
      case 'dumbbell':
        return Icons.fitness_center;
      case 'barra':
      case 'barbell':
        return Icons.linear_scale;
      case 'cabo':
      case 'cable':
        return Icons.cable;
      case 'peso corporal':
      case 'bodyweight':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<SortOption>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_sortOption.icon, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(_sortOption.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 18),
                ],
              ),
            ),
            onSelected: (option) => setState(() => _sortOption = option),
            color: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => SortOption.values.map((option) {
              final isSelected = option == _sortOption;
              return PopupMenuItem<SortOption>(
                value: option,
                child: Row(
                  children: [
                    Icon(option.icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      option.label,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'Nenhum exercício nesta categoria',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadExercises,
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sortedExercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _buildExerciseTile(_sortedExercises[index]),
                  ),
                ),
    );
  }

  Widget _buildExerciseTile(Map<String, dynamic> exercise) {
    final name = exercise['name'] ?? 'Sem nome';
    final muscle = exercise['mainMuscle'] ?? exercise['muscleGroup'] ?? widget.categoryName;
    final equipment = exercise['equipment'];
    final difficulty = exercise['difficulty'] ?? 'medio';
    final id = exercise['id']?.toString() ?? '';

    return GestureDetector(
      onTap: () => context.push('/exercise/$id'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_equipmentIcon(equipment), color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _tag(muscle, AppColors.primary),
                        if (equipment != null) ...[
                          const SizedBox(width: 6),
                          _tag(equipment, AppColors.secondary),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _difficultyChip(difficulty),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _difficultyChip(String difficulty) {
    String label;
    Color color;

    switch (difficulty.toLowerCase()) {
      case 'facil':
      case 'fácil':
      case 'easy':
        label = 'Fácil';
        color = AppColors.success;
        break;
      case 'dificil':
      case 'difícil':
      case 'hard':
        label = 'Difícil';
        color = AppColors.error;
        break;
      default:
        label = 'Médio';
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

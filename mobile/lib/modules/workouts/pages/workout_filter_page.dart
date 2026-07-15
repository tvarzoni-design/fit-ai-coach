import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class WorkoutFilterPage extends StatefulWidget {
  const WorkoutFilterPage({super.key});

  @override
  State<WorkoutFilterPage> createState() => _WorkoutFilterPageState();
}

class _WorkoutFilterPageState extends State<WorkoutFilterPage> {
  double _durationMin = 15;
  double _durationMax = 90;
  String _selectedDifficulty = '';
  final Set<String> _selectedMuscles = {};
  final Set<String> _selectedEquipment = {};

  final List<String> _difficulties = ['Iniciante', 'Intermediário', 'Avançado'];

  final List<Map<String, dynamic>> _muscleGroups = [
    {'name': 'Peito', 'icon': Icons.accessibility_new},
    {'name': 'Costas', 'icon': Icons.accessibility_new},
    {'name': 'Pernas', 'icon': Icons.accessibility_new},
    {'name': 'Ombros', 'icon': Icons.accessibility_new},
    {'name': 'Braços', 'icon': Icons.accessibility_new},
    {'name': 'Abdômen', 'icon': Icons.accessibility_new},
  ];

  final List<Map<String, dynamic>> _equipment = [
    {'name': 'Máquina', 'icon': Icons.precision_manufacturing},
    {'name': 'Halteres', 'icon': Icons.fitness_center},
    {'name': 'Barra', 'icon': Icons.square},
    {'name': 'Peso corporal', 'icon': Icons.person},
    {'name': 'Nenhum', 'icon': Icons.block},
  ];

  void _clearFilters() {
    setState(() {
      _durationMin = 15;
      _durationMax = 90;
      _selectedDifficulty = '';
      _selectedMuscles.clear();
      _selectedEquipment.clear();
    });
  }

  void _applyFilters() {
    final filters = {
      'durationMin': _durationMin.round(),
      'durationMax': _durationMax.round(),
      'difficulty': _selectedDifficulty,
      'muscles': _selectedMuscles.toList(),
      'equipment': _selectedEquipment.toList(),
    };
    context.pop(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Filtros'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Limpar', style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Duração'),
            const SizedBox(height: 8),
            _buildDurationFilter(),
            const SizedBox(height: 24),
            _buildSectionTitle('Dificuldade'),
            const SizedBox(height: 12),
            _buildDifficultyFilter(),
            const SizedBox(height: 24),
            _buildSectionTitle('Grupos Musculares'),
            const SizedBox(height: 12),
            _buildMuscleFilter(),
            const SizedBox(height: 24),
            _buildSectionTitle('Equipamentos'),
            const SizedBox(height: 12),
            _buildEquipmentFilter(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Aplicar filtros'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
  }

  Widget _buildDurationFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDurationChip('${_durationMin.round()} min'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 20),
                ),
                _buildDurationChip('${_durationMax.round()} min'),
              ],
            ),
            const SizedBox(height: 16),
            RangeSlider(
              values: RangeValues(_durationMin, _durationMax),
              min: 15,
              max: 90,
              divisions: 15,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceLight,
              labels: RangeLabels(
                '${_durationMin.round()} min',
                '${_durationMax.round()} min',
              ),
              onChanged: (values) {
                setState(() {
                  _durationMin = values.start;
                  _durationMax = values.end;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDifficultyFilter() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _difficulties.map((diff) {
        final isSelected = _selectedDifficulty == diff;
        final color = diff == 'Iniciante'
            ? AppColors.success
            : diff == 'Intermediário'
                ? AppColors.warning
                : AppColors.error;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDifficulty = isSelected ? '' : diff;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppColors.surfaceLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_circle, color: color, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  diff,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMuscleFilter() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _muscleGroups.map((muscle) {
        final isSelected = _selectedMuscles.contains(muscle['name']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMuscles.remove(muscle['name']);
              } else {
                _selectedMuscles.add(muscle['name']);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  muscle['name'],
                  style: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEquipmentFilter() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _equipment.map((eq) {
        final isSelected = _selectedEquipment.contains(eq['name']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedEquipment.remove(eq['name']);
              } else {
                _selectedEquipment.add(eq['name']);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary.withValues(alpha: 0.2) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.surfaceLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  eq['icon'] as IconData,
                  color: isSelected ? AppColors.secondary : AppColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  eq['name'],
                  style: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

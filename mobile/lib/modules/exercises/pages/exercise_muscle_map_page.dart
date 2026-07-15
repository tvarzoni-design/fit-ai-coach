import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ExerciseMuscleMapPage extends StatefulWidget {
  const ExerciseMuscleMapPage({super.key});

  @override
  State<ExerciseMuscleMapPage> createState() => _ExerciseMuscleMapPageState();
}

class _ExerciseMuscleMapPageState extends State<ExerciseMuscleMapPage> {
  bool _showFront = true;
  String? _selectedMuscle;
  List<dynamic> _exercises = [];
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _muscleGroups = {
    'chest': {
      'label': 'Peito',
      'color': AppColors.primary,
      'frontRect': Rect.fromLTWH(80, 100, 80, 60),
      'exercises': ['Supino Reto', 'Crucifixo', 'Supino Inclinado'],
    },
    'shoulders': {
      'label': 'Ombros',
      'color': AppColors.secondary,
      'frontRect': Rect.fromLTWH(62, 80, 116, 40),
      'exercises': ['Desenvolvimento', 'Elevação Lateral', 'Elevação Frontal'],
    },
    'biceps': {
      'label': 'Bíceps',
      'color': AppColors.warning,
      'frontRect': Rect.fromLTWH(48, 120, 32, 60),
      'exercises': ['Rosca Direta', 'Rosca Alternada', 'Rosca Martelo'],
    },
    'abs': {
      'label': 'Abdômen',
      'color': AppColors.success,
      'frontRect': Rect.fromLTWH(92, 160, 56, 80),
      'exercises': ['Prancha', 'Abdominal Crunch', 'Russian Twist'],
    },
    'quads': {
      'label': 'Quadríceps',
      'color': AppColors.info,
      'frontRect': Rect.fromLTWH(74, 300, 36, 100),
      'exercises': ['Agachamento', 'Leg Press', 'Cadeira Extensora'],
    },
    'calves': {
      'label': 'Panturrilhas',
      'color': AppColors.error,
      'frontRect': Rect.fromLTWH(78, 430, 28, 60),
      'exercises': ['Panturrilha em Pé', 'Panturrilha Sentado'],
    },
    'back': {
      'label': 'Costas',
      'color': AppColors.primary,
      'backRect': Rect.fromLTWH(72, 100, 96, 120),
      'exercises': ['Puxada Frontal', 'Remada Curvada', 'Barra Fixa'],
    },
    'traps': {
      'label': 'Trapezio',
      'color': AppColors.secondary,
      'backRect': Rect.fromLTWH(80, 60, 80, 50),
      'exercises': ['Encolhimento', 'Remada Alta'],
    },
    'triceps': {
      'label': 'Tríceps',
      'color': AppColors.warning,
      'backRect': Rect.fromLTWH(48, 120, 32, 60),
      'exercises': ['Tríceps Testa', 'Tríceps Corda', 'Mergulho'],
    },
    'glutes': {
      'label': 'Glúteos',
      'color': AppColors.success,
      'backRect': Rect.fromLTWH(80, 220, 80, 60),
      'exercises': ['Stiff', 'Hip Thrust', 'Cadeira Abdutora'],
    },
    'hamstrings': {
      'label': 'Isquiotibiais',
      'color': AppColors.info,
      'backRect': Rect.fromLTWH(74, 280, 36, 100),
      'exercises': ['Stiff', 'Cadeira Flexora', 'Mesa Flexora'],
    },
  };

  Future<void> _loadExercisesForMuscle(String muscleKey) async {
    setState(() {
      _isLoading = true;
      _selectedMuscle = muscleKey;
    });
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/exercises', queryParameters: {'muscle': muscleKey});
      if (mounted) {
        setState(() {
          _exercises = response.data is List ? response.data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _exercises = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Muscular'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildViewToggle(),
            const SizedBox(height: 16),
            _buildBodyMap(),
            const SizedBox(height: 16),
            _buildMuscleGrid(),
            if (_selectedMuscle != null) ...[
              const SizedBox(height: 16),
              _buildExerciseList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _showFront = true;
                _selectedMuscle = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showFront ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Frontal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _showFront ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _showFront = false;
                _selectedMuscle = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showFront ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Costas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: !_showFront ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMap() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 520,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 200,
                height: 520,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              ..._muscleGroups.entries.where((entry) {
                final hasFront = entry.value.containsKey('frontRect');
                final hasBack = entry.value.containsKey('backRect');
                return _showFront ? hasFront : hasBack;
              }).map((entry) {
                final rect = _showFront
                    ? entry.value['frontRect'] as Rect
                    : entry.value['backRect'] as Rect;
                final color = entry.value['color'] as Color;
                final isSelected = _selectedMuscle == entry.key;
                final label = entry.value['label'] as String;

                return Positioned(
                  left: rect.left + (200 - 200) / 2,
                  top: rect.top,
                  child: GestureDetector(
                    onTap: () => _loadExercisesForMuscle(entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: rect.width,
                      height: rect.height,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.5)
                            : color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleGrid() {
    final muscles = _showFront
        ? _muscleGroups.entries.where((e) => e.value.containsKey('frontRect')).toList()
        : _muscleGroups.entries.where((e) => e.value.containsKey('backRect')).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: muscles.map((entry) {
        final color = entry.value['color'] as Color;
        final label = entry.value['label'] as String;
        final isSelected = _selectedMuscle == entry.key;

        return GestureDetector(
          onTap: () => _loadExercisesForMuscle(entry.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseList() {
    final muscle = _muscleGroups[_selectedMuscle];
    if (muscle == null) return const SizedBox.shrink();

    final exercises = muscle['exercises'] as List;
    final color = muscle['color'] as Color;
    final label = muscle['label'] as String;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Exercícios para $label',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...exercises.map((name) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

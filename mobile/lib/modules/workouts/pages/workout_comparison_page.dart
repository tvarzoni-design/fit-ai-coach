import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutComparisonPage extends StatefulWidget {
  const WorkoutComparisonPage({super.key});

  @override
  State<WorkoutComparisonPage> createState() => _WorkoutComparisonPageState();
}

class _WorkoutComparisonPageState extends State<WorkoutComparisonPage> {
  bool _isLoading = true;
  List<dynamic> _workouts = [];
  dynamic _workoutA;
  dynamic _workoutB;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getWorkouts();
      if (mounted) {
        final list = response.data ?? [];
        setState(() {
          _workouts = list;
          if (list.length >= 2) {
            _workoutA = list[0];
            _workoutB = list[1];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _workouts = _getMockWorkouts();
          _workoutA = _getMockWorkouts()[0];
          _workoutB = _getMockWorkouts()[1];
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getMockWorkouts() {
    return [
      {
        'name': 'Treino A - Peito e Tríceps',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'duration': 65,
        'exercises': 6,
        'volume': 4850,
        'muscleGroups': 'Peito, Tríceps, Ombros',
        'calories': 420,
      },
      {
        'name': 'Treino B - Costas e Bíceps',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'duration': 58,
        'exercises': 5,
        'volume': 4200,
        'muscleGroups': 'Costas, Bíceps, Antebraço',
        'calories': 380,
      },
    ];
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '--';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--';
    }
  }

  Color _compareColor(dynamic a, dynamic b, {bool higherIsBetter = true}) {
    if (a == null || b == null) return AppColors.textMuted;
    final va = (a is num) ? a.toDouble() : 0.0;
    final vb = (b is num) ? b.toDouble() : 0.0;
    if (va == vb) return AppColors.textMuted;
    if (higherIsBetter) {
      return va > vb ? AppColors.success : AppColors.error;
    }
    return va < vb ? AppColors.success : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Comparar Treinos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workouts.length < 2
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.compare_arrows, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('Precisa de pelo menos 2 treinos', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSelectorRow(),
                      const SizedBox(height: 20),
                      _buildComparisonRow(
                        'Duração',
                        '${_workoutA?['duration'] ?? 0} min',
                        '${_workoutB?['duration'] ?? 0} min',
                        _workoutA?['duration'] ?? 0,
                        _workoutB?['duration'] ?? 0,
                        Icons.timer,
                        true,
                      ),
                      _buildComparisonRow(
                        'Exercícios',
                        '${_workoutA?['exercises'] ?? 0}',
                        '${_workoutB?['exercises'] ?? 0}',
                        _workoutA?['exercises'] ?? 0,
                        _workoutB?['exercises'] ?? 0,
                        Icons.format_list_numbered,
                        true,
                      ),
                      _buildComparisonRow(
                        'Volume Total',
                        '${_workoutA?['volume'] ?? 0} kg',
                        '${_workoutB?['volume'] ?? 0} kg',
                        _workoutA?['volume'] ?? 0,
                        _workoutB?['volume'] ?? 0,
                        Icons.fitness_center,
                        true,
                      ),
                      _buildComparisonRow(
                        'Calorias',
                        '${_workoutA?['calories'] ?? 0} kcal',
                        '${_workoutB?['calories'] ?? 0} kcal',
                        _workoutA?['calories'] ?? 0,
                        _workoutB?['calories'] ?? 0,
                        Icons.local_fire_department,
                        true,
                      ),
                      const SizedBox(height: 16),
                      _buildMusclesComparison(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWorkoutDropdown(String label, dynamic value, ValueChanged<dynamic> onChanged) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<dynamic>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          underline: const SizedBox(),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
          items: _workouts.map((w) {
            return DropdownMenuItem<dynamic>(
              value: w,
              child: Text(w['name'] ?? 'Treino', maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSelectorRow() {
    return Row(
      children: [
        _buildWorkoutDropdown('Treino A', _workoutA, (v) => setState(() => _workoutA = v)),
        const SizedBox(width: 12),
        Icon(Icons.compare_arrows, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        _buildWorkoutDropdown('Treino B', _workoutB, (v) => setState(() => _workoutB = v)),
      ],
    );
  }

  Widget _buildComparisonRow(
    String label,
    String valueA,
    String valueB,
    num numA,
    num numB,
    IconData icon,
    bool higherIsBetter,
  ) {
    final colorA = _compareColor(numA, numB, higherIsBetter: higherIsBetter);
    final colorB = _compareColor(numB, numA, higherIsBetter: higherIsBetter);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    valueA,
                    style: TextStyle(
                      color: colorA,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: AppColors.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    valueB,
                    style: TextStyle(
                      color: colorB,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusclesComparison() {
    final musclesA = (_workoutA?['muscleGroups'] ?? '').toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final musclesB = (_workoutB?['muscleGroups'] ?? '').toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grupos Musculares', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Treino A', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...musclesA.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(m, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: AppColors.surfaceLight,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Treino B', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        ...musclesB.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(m, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

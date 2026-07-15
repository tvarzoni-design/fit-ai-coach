import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  Map<String, dynamic>? _workout;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getWorkout(widget.workoutId);
      if (mounted) setState(() { _workout = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final workout = _workout;
    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(child: Text('Treino não encontrado', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final exercises = workout['exercises'] as List? ?? [];
    final name = workout['name'] ?? 'Treino';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.fitness_center, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(workout['muscleGroups'] ?? '', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(Icons.timer_outlined, '${workout['estimatedDuration'] ?? 0} min', 'Duração'),
                    _buildInfoItem(Icons.fitness_center, '${exercises.length}', 'Exercícios'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Exercícios', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value as Map<String, dynamic>? ?? {};
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('${index + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                  ),
                  title: Text(exercise['name'] ?? 'Exercício', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${exercise['sets'] ?? 3}x${exercise['reps'] ?? '12'} • ${exercise['rest'] ?? 60}s descanso',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () => context.go('/exercise/${exercise['id'] ?? '$index'}'),
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/workout/${widget.workoutId}/execute'),
                icon: Icon(Icons.play_arrow),
                label: const Text('Iniciar Treino'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

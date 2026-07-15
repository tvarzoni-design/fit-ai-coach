import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  List<dynamic> _workouts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getWorkouts();
      if (mounted) setState(() { _workouts = response.data ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Treinos'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _generateWorkout()),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadWorkouts, child: const Text('Tentar novamente')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWorkouts,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCurrentWeek(),
                        const SizedBox(height: 24),
                        Text('Meus Treinos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (_workouts.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.fitness_center, size: 48, color: AppColors.textMuted),
                                    const SizedBox(height: 16),
                                    Text('Nenhum treino encontrado', style: TextStyle(color: AppColors.textSecondary)),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _generateWorkout,
                                      icon: const Icon(Icons.auto_awesome),
                                      label: const Text('Gerar treino com IA'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ..._workouts.map((w) => _buildWorkoutCard(w)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCurrentWeek() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Semana Atual', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Text('Semana 1', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'].map((d) => Column(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: d == 'Seg' ? AppColors.success : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: ['Ter', 'Qui', 'Sex'].contains(d) ? Border.all(color: AppColors.primary) : null,
                    ),
                    child: Center(
                      child: d == 'Seg'
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(d, style: TextStyle(color: ['Ter', 'Qui', 'Sex'].contains(d) ? AppColors.primary : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(dynamic workout) {
    final exercises = (workout['exercises'] as List?) ?? [];
    final name = workout['name'] ?? 'Treino';
    final duration = workout['estimatedDuration'] ?? 60;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.fitness_center, color: AppColors.primary),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.fitness_center, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${exercises.length} exercícios', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(width: 12),
              Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('$duration min', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ]),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => context.go('/workout/${workout['id']}'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          child: const Text('Iniciar'),
        ),
      ),
    );
  }

  Future<void> _generateWorkout() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.generateWorkout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino gerado com sucesso!')),
        );
        await _loadWorkouts();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao gerar treino')),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutSuggestionDetailPage extends StatefulWidget {
  final Map<String, dynamic>? workout;
  const WorkoutSuggestionDetailPage({super.key, this.workout});

  @override
  State<WorkoutSuggestionDetailPage> createState() => _WorkoutSuggestionDetailPageState();
}

class _WorkoutSuggestionDetailPageState extends State<WorkoutSuggestionDetailPage> {
  Map<String, dynamic> _workout = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout ?? {};
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/coach/workout-suggestion/${_workout['id'] ?? ''}');
      if (mounted) setState(() { _workout = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _workout = _workout.isNotEmpty ? _workout : {
            'name': 'Treino Full Body',
            'description': 'Treino completo para todo o corpo com foco em hipertrofia.',
            'difficulty': 'Intermediário',
            'duration': 55,
            'exercises': [
              {'name': 'Supino Reto', 'sets': 4, 'reps': '10-12', 'rest': '90s'},
              {'name': 'Agachamento Livre', 'sets': 4, 'reps': '8-10', 'rest': '120s'},
              {'name': 'Remada Curvada', 'sets': 4, 'reps': '10-12', 'rest': '90s'},
              {'name': 'Desenvolvimento', 'sets': 3, 'reps': '12', 'rest': '60s'},
              {'name': 'Leg Press', 'sets': 3, 'reps': '12-15', 'rest': '90s'},
            ],
          };
          _isLoading = false;
        });
      }
    }
  }

  Color _difficultyColor(String? d) {
    switch (d) {
      case 'Fácil': return AppColors.success;
      case 'Intermediário': return AppColors.warning;
      case 'Difícil': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  void _startWorkout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino iniciado!'), backgroundColor: AppColors.success),
    );
  }

  void _saveForLater() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino salvo para depois'), backgroundColor: AppColors.info),
    );
  }

  void _showFeedback() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Por que não gostou?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _feedbackOption('Muito difícil'),
            _feedbackOption('Muito fácil'),
            _feedbackOption('Exercícios inadequados'),
            _feedbackOption('Duração inadequada'),
            _feedbackOption('Outro motivo'),
          ],
        ),
      ),
    );
  }

  Widget _feedbackOption(String label) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback: "$label" registrado'), backgroundColor: AppColors.info),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sugestão de Treino')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final exercises = _workout['exercises'] as List<dynamic>? ?? [];
    final difficulty = _workout['difficulty'] ?? 'Médio';
    final duration = _workout['duration'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Sugestão de Treino')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(difficulty, duration),
            const SizedBox(height: 20),
            _buildExerciseList(exercises),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildHeader(String difficulty, int duration) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_workout['name'] ?? 'Treino', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_workout['description'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildBadge(difficulty, _difficultyColor(difficulty)),
                const SizedBox(width: 12),
                _buildBadge('$duration min', AppColors.info),
                const SizedBox(width: 12),
                _buildBadge('${_workout['exercises']?.length ?? 0} exercícios', AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildExerciseList(List<dynamic> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Exercícios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...exercises.asMap().entries.map((e) {
          final ex = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text('${e.key + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              title: Text(ex['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${ex['sets']}x${ex['reps']} · Descanso ${ex['rest']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startWorkout,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar Treino'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveForLater,
                  icon: const Icon(Icons.bookmark_outline, size: 18),
                  label: const Text('Salvar para Depois'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textSecondary, side: const BorderSide(color: AppColors.surfaceLight)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showFeedback,
                  icon: const Icon(Icons.thumb_down_outlined, size: 18),
                  label: const Text('Não Gostar'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

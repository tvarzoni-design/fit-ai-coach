import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutCompletionPage extends StatefulWidget {
  final String workoutId;

  const WorkoutCompletionPage({super.key, required this.workoutId});

  @override
  State<WorkoutCompletionPage> createState() => _WorkoutCompletionPageState();
}

class _WorkoutCompletionPageState extends State<WorkoutCompletionPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _workout;
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  int _rating = 0;
  final _notesController = TextEditingController();
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getWorkout(widget.workoutId);
      if (mounted) {
        setState(() {
          _workout = response.data;
          _exercises = _workout!['exercises'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _totalSets => _exercises.fold(0, (sum, e) => sum + (e['sets'] as int? ?? 3));
  int get _totalReps => _exercises.fold(0, (sum, e) {
    final reps = int.tryParse('${e['reps'] ?? 12}') ?? 12;
    return sum + (e['sets'] as int? ?? 3) * reps;
  });

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/workouts')),
        title: const Text('Treino Concluído'),
      ),
      body: Stack(
        children: [
          _buildConfettiBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildRatingSection(),
                const SizedBox(height: 16),
                _buildNotesSection(),
                const SizedBox(height: 24),
                _buildExercisesList(),
                const SizedBox(height: 24),
                _buildShareButton(),
                const SizedBox(height: 12),
                _buildHomeButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiBackground() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, _) {
        return CustomPaint(
          painter: _ConfettiPainter(progress: _confettiController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, size: 64, color: AppColors.success),
        ),
        const SizedBox(height: 16),
        Text('Excelente treino!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(_workout?['name'] ?? 'Treino', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.fitness_center, '${_exercises.length}', 'Exercícios'),
            _buildStatItem(Icons.repeat, '$_totalSets', 'Séries'),
            _buildStatItem(Icons.numbers, '$_totalReps', 'Reps'),
            _buildStatItem(Icons.timer_outlined, '${_workout?['estimatedDuration'] ?? 0} min', 'Duração'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Como foi o treino?', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: i < _rating ? AppColors.warning : AppColors.textMuted,
                    size: 36,
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Adicionar notas sobre o treino...', border: InputBorder.none),
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exercícios concluídos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._exercises.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            title: Text(e['name'] ?? 'Exercício', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${e['sets'] ?? 3}x${e['reps'] ?? '12'}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
        )),
      ],
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.push('/workout/${widget.workoutId}/share'),
        icon: const Icon(Icons.share),
        label: const Text('Compartilhar resultado'),
      ),
    );
  }

  Widget _buildHomeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/workouts'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: const Text('Voltar aos Treinos'),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -20.0 + (progress * size.height * 1.5 + random.nextDouble() * 100) % (size.height + 40);
      final colors = [AppColors.primary, AppColors.secondary, AppColors.success, AppColors.warning];
      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: 0.6);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, startY), width: 6, height: 6), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

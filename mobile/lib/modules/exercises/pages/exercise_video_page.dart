import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ExerciseVideoPage extends StatefulWidget {
  final String exerciseId;

  const ExerciseVideoPage({super.key, required this.exerciseId});

  @override
  State<ExerciseVideoPage> createState() => _ExerciseVideoPageState();
}

class _ExerciseVideoPageState extends State<ExerciseVideoPage> {
  Map<String, dynamic>? _exercise;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  Future<void> _loadExercise() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getExercise(widget.exerciseId);
      if (mounted) setState(() { _exercise = response.data; _isLoading = false; });
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

    final exercise = _exercise ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise['name'] ?? 'Exercício'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.secondary.withValues(alpha: 0.2)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill, color: AppColors.textPrimary, size: 64),
                  const SizedBox(height: 12),
                  Text(exercise['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (exercise['execution'] != null) ...[
              _buildSection('Instruções', exercise['execution'], Icons.menu_book, AppColors.primary),
              const SizedBox(height: 16),
            ],
            if (exercise['tips'] != null) ...[
              _buildSection('Dicas', exercise['tips'], Icons.lightbulb, AppColors.warning),
              const SizedBox(height: 16),
            ],
            if (exercise['commonErrors'] != null) ...[
              _buildSection('Erros Comuns', exercise['commonErrors'], Icons.warning_amber, AppColors.error),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

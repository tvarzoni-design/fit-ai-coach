import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutExercise {
  final String id;
  String name;
  int sets;
  String reps;
  int restSeconds;

  _CreateWorkoutExercise({
    required this.id,
    required this.name,
    this.sets = 3,
    this.reps = '12',
    this.restSeconds = 60,
  });
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _duration = 45;
  String _difficulty = 'Intermediário';
  final List<_CreateWorkoutExercise> _exercises = [];
  bool _isSaving = false;
  List<dynamic> _availableExercises = [];
  bool _isLoadingExercises = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getExercises();
      if (mounted) setState(() { _availableExercises = response.data ?? []; _isLoadingExercises = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoadingExercises = false);
    }
  }

  void _addExercise(Map<String, dynamic> exercise) {
    setState(() {
      _exercises.add(_CreateWorkoutExercise(
        id: exercise['id'] ?? UniqueKey().toString(),
        name: exercise['name'] ?? 'Exercício',
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise['name']} adicionado'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
  }

  Future<void> _saveWorkout() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o treino'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um exercício'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final api = context.read<AuthService>().api;
      await api.createWorkout({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'estimatedDuration': _duration,
        'difficulty': _difficulty,
        'exercises': _exercises.map((e) => {
          'exerciseId': e.id,
          'sets': e.sets,
          'reps': e.reps,
          'rest': e.restSeconds,
        }).toList(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino salvo com sucesso!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar treino'), backgroundColor: AppColors.error),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Criar Treino'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informações Básicas'),
            const SizedBox(height: 12),
            _buildBasicInfoCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Exercícios Adicionados (${_exercises.length})'),
            const SizedBox(height: 12),
            if (_exercises.isEmpty)
              _buildEmptyExercises()
            else
              _buildExercisesList(),
            const SizedBox(height: 16),
            _buildAddExerciseButton(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveWorkout,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Salvar treino'),
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
      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Nome do treino'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Descrição (opcional)'),
            ),
            const SizedBox(height: 20),
            Text('Duração estimada: $_duration min',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _duration.toDouble(),
                min: 15,
                max: 120,
                divisions: 21,
                label: '$_duration min',
                onChanged: (v) => setState(() => _duration = v.round()),
              ),
            ),
            const SizedBox(height: 12),
            Text('Dificuldade', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: ['Iniciante', 'Intermediário', 'Avançado'].map((d) {
                final isSelected = _difficulty == d;
                final color = d == 'Iniciante'
                    ? AppColors.success
                    : d == 'Intermediário'
                        ? AppColors.warning
                        : AppColors.error;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            color: isSelected ? color : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyExercises() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.fitness_center, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Nenhum exercício adicionado', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercisesList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _exercises.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _exercises.removeAt(oldIndex);
          _exercises.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return Card(
          key: ValueKey(exercise.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.drag_handle, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text('${index + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(exercise.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      onPressed: () => _removeExercise(index),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildExerciseConfig(
                      label: 'Séries',
                      value: '${exercise.sets}',
                      onIncrease: () => setState(() => exercise.sets++),
                      onDecrease: exercise.sets > 1 ? () => setState(() => exercise.sets--) : null,
                    ),
                    const SizedBox(width: 8),
                    _buildExerciseConfig(
                      label: 'Reps',
                      value: exercise.reps,
                      onIncrease: () {
                        final current = int.tryParse(exercise.reps) ?? 12;
                        setState(() => exercise.reps = '${current + 1}');
                      },
                      onDecrease: () {
                        final current = int.tryParse(exercise.reps) ?? 12;
                        if (current > 1) setState(() => exercise.reps = '${current - 1}');
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildExerciseConfig(
                      label: 'Descanso',
                      value: '${exercise.restSeconds}s',
                      onIncrease: () => setState(() => exercise.restSeconds += 15),
                      onDecrease: exercise.restSeconds > 15 ? () => setState(() => exercise.restSeconds -= 15) : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseConfig({
    required String label,
    required String value,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onDecrease,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: onDecrease != null ? AppColors.surface : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.remove, size: 14, color: onDecrease != null ? AppColors.textPrimary : AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onIncrease,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 14, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton() {
    return GestureDetector(
      onTap: () => _showExercisePicker(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Adicionar exercício', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Selecionar Exercício', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Expanded(
                child: _isLoadingExercises
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _availableExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _availableExercises[index];
                          return ListTile(
                            leading: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                            ),
                            title: Text(exercise['name'] ?? 'Exercício', style: const TextStyle(color: AppColors.textPrimary)),
                            subtitle: Text(exercise['mainMuscle'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            trailing: Icon(Icons.add_circle, color: AppColors.primary),
                            onTap: () {
                              _addExercise(exercise);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

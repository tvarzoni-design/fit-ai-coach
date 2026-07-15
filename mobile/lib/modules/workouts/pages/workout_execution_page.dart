import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutExecutionPage extends StatefulWidget {
  final String workoutId;

  const WorkoutExecutionPage({super.key, required this.workoutId});

  @override
  State<WorkoutExecutionPage> createState() => _WorkoutExecutionPageState();
}

class _WorkoutExecutionPageState extends State<WorkoutExecutionPage> {
  Map<String, dynamic>? _workout;
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _restSeconds = 0;
  Timer? _timer;
  bool _workoutFinished = false;
  final Map<String, List<Map<String, dynamic>>> _completedSets = {};

  @override
  void initState() {
    super.initState();
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
          _restSeconds = (_exercises.isNotEmpty ? (_exercises[0]['rest'] ?? 60) : 60);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRest() {
    _restSeconds = (_currentExercise['rest'] ?? 60);
    _isResting = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isResting = false;
          _currentSet++;
          if (_currentSet > (_currentExercise['sets'] ?? 3)) _nextExercise();
        });
      } else {
        setState(() => _restSeconds--);
      }
    });
    setState(() {});
  }

  void _completeSet() {
    final exerciseId = _currentExercise['id'] ?? '$_currentExerciseIndex';
    if (!_completedSets.containsKey(exerciseId)) _completedSets[exerciseId] = [];
    _completedSets[exerciseId]!.add({'set': _currentSet, 'reps': _currentExercise['reps'] ?? '12', 'weight': '80'});
    _startRest();
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() { _currentExerciseIndex++; _currentSet = 1; });
    } else {
      _timer?.cancel();
      setState(() => _workoutFinished = true);
    }
  }

  void _skipExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      _timer?.cancel();
      setState(() { _currentExerciseIndex++; _currentSet = 1; _isResting = false; });
    } else {
      _timer?.cancel();
      setState(() => _workoutFinished = true);
    }
  }

  dynamic get _currentExercise => _exercises.isNotEmpty ? _exercises[_currentExerciseIndex] : {'name': '', 'sets': 3, 'reps': '12', 'rest': 60};

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: const Text('Carregando...')), body: const Center(child: CircularProgressIndicator()));
    }

    if (_workoutFinished) return _buildFinishedScreen();

    return Scaffold(
      appBar: AppBar(
        title: Text(_workout?['name'] ?? 'Treino'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/workouts')),
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          if (_isResting) Expanded(child: _buildRestScreen()) else Expanded(child: _buildExerciseScreen()),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _exercises.isNotEmpty ? ((_currentExerciseIndex + (_currentSet - 1) / (_currentExercise['sets'] ?? 3)) / _exercises.length) : 0.0;
    return Column(children: [
      LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: AppColors.surfaceLight, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), minHeight: 4),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Exercício ${_currentExerciseIndex + 1} de ${_exercises.length}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text('Série $_currentSet de ${_currentExercise['sets'] ?? 3}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    ]);
  }

  Widget _buildExerciseScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.fitness_center, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(_currentExercise['name'] ?? '', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('${_currentExercise['sets']} séries x ${_currentExercise['reps']} reps', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildRestScreen() {
    final maxRest = _currentExercise['rest'] ?? 60;
    final progress = 1 - (_restSeconds / maxRest);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Descanse', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            width: 180, height: 180,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 180, height: 180, child: CircularProgressIndicator(value: progress.clamp(0.0, 1.0), strokeWidth: 8, backgroundColor: AppColors.surfaceLight, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary))),
              Text('$_restSeconds', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 24),
          Text('Próxima: ${_currentExercise['name']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.surfaceLight))),
      child: _isResting
          ? OutlinedButton(onPressed: () { _timer?.cancel(); setState(() { _isResting = false; _currentSet++; if (_currentSet > (_currentExercise['sets'] ?? 3)) _nextExercise(); }); }, child: const Text('Pular Descanso'))
          : Row(children: [
              Expanded(child: OutlinedButton(onPressed: _skipExercise, child: const Text('Pular'))),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: ElevatedButton.icon(onPressed: _completeSet, icon: const Icon(Icons.check), label: const Text('Concluir Série'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
            ]),
    );
  }

  Widget _buildFinishedScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Treino Concluído!')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.emoji_events, size: 64, color: AppColors.success)),
              const SizedBox(height: 24),
              Text('Parabéns!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Você completou ${_workout?['name'] ?? 'o treino'}', style: TextStyle(color: AppColors.textSecondary, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => context.go('/workouts'), child: const Text('Voltar aos Treinos'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ExerciseComparisonPage extends StatefulWidget {
  const ExerciseComparisonPage({super.key});

  @override
  State<ExerciseComparisonPage> createState() => _ExerciseComparisonPageState();
}

class _ExerciseComparisonPageState extends State<ExerciseComparisonPage> {
  bool _isLoading = true;
  List<dynamic> _exercises = [];
  Map<String, dynamic>? _exerciseA;
  Map<String, dynamic>? _exerciseB;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/exercises');
      if (mounted) {
        setState(() {
          _exercises = response.data is List ? response.data : [];
          if (_exercises.length >= 2) {
            _exerciseA = _exercises[0];
            _exerciseB = _exercises[1];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _exercises = [];
          _isLoading = false;
          _exerciseA = {
            'name': 'Supino Reto',
            'muscleGroup': 'Peito',
            'difficulty': 'Intermediário',
            'equipment': 'Barra e Banco',
            'caloriesPerMin': 8.5,
            'tips': 'Mantenha os pés firmes no chão. Não trave os cotovelos.',
          };
          _exerciseB = {
            'name': 'Flexão de Braços',
            'muscleGroup': 'Peito',
            'difficulty': 'Iniciante',
            'equipment': 'Peso Corporal',
            'caloriesPerMin': 7.2,
            'tips': 'Mantenha o corpo reto. Desça até o peito quase tocar o chão.',
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparar Exercícios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildExerciseSelectors(),
                  const SizedBox(height: 20),
                  if (_exerciseA != null && _exerciseB != null) ...[
                    _buildComparisonHeader(),
                    const SizedBox(height: 12),
                    _buildComparisonCard(
                      'Grupo Muscular',
                      _exerciseA!['muscleGroup'] ?? '--',
                      _exerciseB!['muscleGroup'] ?? '--',
                      Icons.fitness_center,
                    ),
                    _buildComparisonCard(
                      'Dificuldade',
                      _exerciseA!['difficulty'] ?? '--',
                      _exerciseB!['difficulty'] ?? '--',
                      Icons.signal_cellular_alt,
                    ),
                    _buildComparisonCard(
                      'Equipamento',
                      _exerciseA!['equipment'] ?? '--',
                      _exerciseB!['equipment'] ?? '--',
                      Icons.sports_gymnastics,
                    ),
                    _buildComparisonCard(
                      'Calorias/min',
                      '${_exerciseA!['caloriesPerMin'] ?? '--'}',
                      '${_exerciseB!['caloriesPerMin'] ?? '--'}',
                      Icons.local_fire_department,
                    ),
                    const SizedBox(height: 16),
                    _buildTipsSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildExerciseSelectors() {
    return Row(
      children: [
        Expanded(child: _buildSelector(_exerciseA, true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.compare_arrows, color: AppColors.textMuted, size: 22),
          ),
        ),
        Expanded(child: _buildSelector(_exerciseB, false)),
      ],
    );
  }

  Widget _buildSelector(Map<String, dynamic>? exercise, bool isA) {
    final color = isA ? AppColors.primary : AppColors.secondary;
    return GestureDetector(
      onTap: () => _showExercisePicker(isA),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  exercise != null ? Icons.fitness_center : Icons.add,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise?['name'] ?? 'Selecionar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: exercise != null ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (exercise != null) ...[
                const SizedBox(height: 2),
                Text(
                  exercise['muscleGroup'] ?? '',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showExercisePicker(bool isA) {
    final list = _exercises.isNotEmpty
        ? _exercises
        : [
            {'name': 'Supino Reto', 'muscleGroup': 'Peito', 'difficulty': 'Intermediário', 'equipment': 'Barra e Banco', 'caloriesPerMin': 8.5, 'tips': 'Mantenha os pés firmes no chão.'},
            {'name': 'Agachamento', 'muscleGroup': 'Pernas', 'difficulty': 'Intermediário', 'equipment': 'Barra', 'caloriesPerMin': 10.2, 'tips': 'Mantenha as costas retas.'},
            {'name': 'Flexão de Braços', 'muscleGroup': 'Peito', 'difficulty': 'Iniciante', 'equipment': 'Peso Corporal', 'caloriesPerMin': 7.2, 'tips': 'Mantenha o corpo reto.'},
            {'name': 'Remada Curvada', 'muscleGroup': 'Costas', 'difficulty': 'Intermediário', 'equipment': 'Barra', 'caloriesPerMin': 9.0, 'tips': 'Mantenha as costas retas.'},
            {'name': 'Levantamento Terra', 'muscleGroup': 'Costas', 'difficulty': 'Avançado', 'equipment': 'Barra', 'caloriesPerMin': 12.5, 'tips': 'Mantenha a barra próxima ao corpo.'},
          ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecionar Exercício',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final ex = list[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceLight,
                      child: Icon(Icons.fitness_center, color: AppColors.textMuted, size: 20),
                    ),
                    title: Text(ex['name'], style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(ex['muscleGroup'], style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    onTap: () {
                      setState(() {
                        if (isA) {
                          _exerciseA = ex;
                        } else {
                          _exerciseB = ex;
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _exerciseA!['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Text(
            _exerciseB!['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(String label, String valueA, String valueB, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                valueA,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 16),
            ),
            Expanded(
              child: Text(
                valueB,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Dicas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _exerciseA!['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _exerciseA!['tips'] ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _exerciseB!['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _exerciseB!['tips'] ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
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

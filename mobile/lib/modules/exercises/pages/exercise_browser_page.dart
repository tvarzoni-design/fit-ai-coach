import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ExerciseBrowserPage extends StatefulWidget {
  const ExerciseBrowserPage({super.key});

  @override
  State<ExerciseBrowserPage> createState() => _ExerciseBrowserPageState();
}

class _ExerciseBrowserPageState extends State<ExerciseBrowserPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMuscle;
  String? _selectedEquipment;
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> _muscleGroups = [
    {'label': 'Peito', 'icon': Icons.accessibility_new},
    {'label': 'Costas', 'icon': Icons.swap_vert},
    {'label': 'Pernas', 'icon': Icons.directions_walk},
    {'label': 'Ombros', 'icon': Icons.open_with},
    {'label': 'Braços', 'icon': Icons.back_hand},
    {'label': 'Abdômen', 'icon': Icons.hourglass_bottom},
    {'label': 'Glúteos', 'icon': Icons.accessibility},
  ];

  final List<Map<String, dynamic>> _equipments = [
    {'label': 'Máquina', 'icon': Icons.settings_suggest},
    {'label': 'Halteres', 'icon': Icons.fitness_center},
    {'label': 'Barra', 'icon': Icons.linear_scale},
    {'label': 'Cabo', 'icon': Icons.cable},
    {'label': 'Peso corporal', 'icon': Icons.person},
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getExercises(
        muscle: _selectedMuscle,
        equipment: _selectedEquipment,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      if (mounted) {
        setState(() {
          _exercises = response.data is List ? response.data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar exercícios';
          _isLoading = false;
        });
      }
    }
  }

  void _onMuscleFilter(String muscle) {
    setState(() {
      _selectedMuscle = _selectedMuscle == muscle ? null : muscle;
    });
    _loadExercises();
  }

  void _onEquipmentFilter(String equipment) {
    setState(() {
      _selectedEquipment = _selectedEquipment == equipment ? null : equipment;
    });
    _loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercícios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar exercícios...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _loadExercises();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              onSubmitted: (_) => _loadExercises(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _muscleGroups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final muscle = _muscleGroups[index];
                final selected = _selectedMuscle == muscle['label'];
                return FilterChip(
                  label: Text(muscle['label']),
                  avatar: Icon(muscle['icon'], size: 16),
                  selected: selected,
                  onSelected: (_) => _onMuscleFilter(muscle['label']),
                  selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  backgroundColor: AppColors.surfaceLight,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                  checkmarkColor: AppColors.primary,
                  side: BorderSide(
                    color: selected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.surfaceLight,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _equipments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final eq = _equipments[index];
                final selected = _selectedEquipment == eq['label'];
                return FilterChip(
                  label: Text(eq['label']),
                  avatar: Icon(eq['icon'], size: 16),
                  selected: selected,
                  onSelected: (_) => _onEquipmentFilter(eq['label']),
                  selectedColor: AppColors.secondary.withValues(alpha: 0.3),
                  backgroundColor: AppColors.surfaceLight,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.secondary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                  checkmarkColor: AppColors.secondary,
                  side: BorderSide(
                    color: selected ? AppColors.secondary.withValues(alpha: 0.5) : AppColors.surfaceLight,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadExercises,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text('Nenhum exercício encontrado', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExercises,
      color: AppColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _exercises.length,
        itemBuilder: (context, index) => _buildExerciseCard(_exercises[index]),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final name = exercise['name'] ?? 'Sem nome';
    final muscle = exercise['mainMuscle'] ?? exercise['muscleGroup'] ?? 'Geral';
    final difficulty = exercise['difficulty'] ?? 'medio';
    final id = exercise['id']?.toString() ?? '';

    return GestureDetector(
      onTap: () => context.push('/exercise/$id'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      muscle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                  _difficultyIcon(difficulty),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _difficultyIcon(String difficulty) {
    IconData icon;
    Color color;

    switch (difficulty.toLowerCase()) {
      case 'facil':
      case 'fácil':
      case 'easy':
        icon = Icons.sentiment_satisfied;
        color = AppColors.success;
        break;
      case 'dificil':
      case 'difícil':
      case 'hard':
        icon = Icons.whatshot;
        color = AppColors.error;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = AppColors.warning;
    }

    return Icon(icon, size: 18, color: color);
  }
}

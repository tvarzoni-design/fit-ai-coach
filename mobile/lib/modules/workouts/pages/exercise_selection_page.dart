import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ExerciseSelectionPage extends StatefulWidget {
  final List<String> selectedExerciseIds;

  const ExerciseSelectionPage({super.key, required this.selectedExerciseIds});

  @override
  State<ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  List<dynamic> _allExercises = [];
  List<dynamic> _filteredExercises = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedMuscle = 'Todos';
  late Set<String> _selectedIds;

  final List<String> _muscleGroups = ['Todos', 'Peito', 'Costas', 'Ombros', 'Bíceps', 'Tríceps', 'Pernas', 'Abdômen', 'Glúteos'];

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.selectedExerciseIds);
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getExercises();
      if (mounted) {
        setState(() {
          _allExercises = response.data ?? [];
          _filteredExercises = _allExercises;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredExercises = _allExercises.where((e) {
        final name = (e['name'] ?? '').toString().toLowerCase();
        final muscle = (e['mainMuscle'] ?? '').toString();
        final matchSearch = _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());
        final matchMuscle = _selectedMuscle == 'Todos' || muscle.contains(_selectedMuscle);
        return matchSearch && matchMuscle;
      }).toList();
    });
  }

  void _toggleExercise(dynamic exercise) {
    final id = (exercise['id'] ?? '').toString();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _confirmSelection() {
    final selected = _allExercises.where((e) => _selectedIds.contains('${e['id']}')).toList();
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Selecionar Exercícios'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Buscar exercício...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) {
                _searchQuery = v;
                _applyFilters();
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _muscleGroups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final muscle = _muscleGroups[index];
                final isSelected = _selectedMuscle == muscle;
                return GestureDetector(
                  onTap: () {
                    _selectedMuscle = muscle;
                    _applyFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                    ),
                    child: Center(child: Text(muscle, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExercises.isEmpty
                    ? Center(child: Text('Nenhum exercício encontrado', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _filteredExercises[index];
                          final id = '${exercise['id']}';
                          final isSelected = _selectedIds.contains(id);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                              ),
                              title: Text(exercise['name'] ?? 'Exercício', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${exercise['mainMuscle'] ?? ''} • ${exercise['equipment'] ?? 'Peso livre'}',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                onChanged: (_) => _toggleExercise(exercise),
                              ),
                              onTap: () => _toggleExercise(exercise),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.surfaceLight))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedIds.isEmpty ? null : _confirmSelection,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _selectedIds.isEmpty ? AppColors.surfaceLight : AppColors.primary,
            ),
            child: Text(
              _selectedIds.isEmpty ? 'Nenhum selecionado' : 'Adicionar ${_selectedIds.length} exercício${_selectedIds.length > 1 ? 's' : ''}',
              style: TextStyle(color: _selectedIds.isEmpty ? AppColors.textMuted : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

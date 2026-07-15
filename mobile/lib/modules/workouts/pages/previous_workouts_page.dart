import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class PreviousWorkoutsPage extends StatefulWidget {
  const PreviousWorkoutsPage({super.key});

  @override
  State<PreviousWorkoutsPage> createState() => _PreviousWorkoutsPageState();
}

class _PreviousWorkoutsPageState extends State<PreviousWorkoutsPage> {
  List<dynamic> _workouts = [];
  String _filter = 'Todos';
  bool _isLoading = true;
  int _totalWorkouts = 0;
  int _completedWorkouts = 0;
  int _totalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/workouts/history');
      if (mounted) {
        final data = response.data as List<dynamic>? ?? [];
        setState(() {
          _workouts = data;
          _totalWorkouts = data.length;
          _completedWorkouts = data.where((w) => w['completed'] == true).length;
          _totalMinutes = data.fold(0, (sum, w) => sum + ((w['duration'] ?? 0) as int));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _workouts = [
            {'name': 'Treino A - Peito e Tríceps', 'date': '2026-07-14', 'exercises': 8, 'duration': 55, 'completed': true},
            {'name': 'Treino B - Costas e Bíceps', 'date': '2026-07-13', 'exercises': 7, 'duration': 50, 'completed': true},
            {'name': 'Treino C - Pernas', 'date': '2026-07-12', 'exercises': 6, 'duration': 60, 'completed': false},
            {'name': 'Treino D - Ombros e Abdômen', 'date': '2026-07-11', 'exercises': 8, 'duration': 45, 'completed': true},
            {'name': 'Treino A - Peito e Tríceps', 'date': '2026-07-08', 'exercises': 8, 'duration': 55, 'completed': true},
            {'name': 'Treino B - Costas e Bíceps', 'date': '2026-07-07', 'exercises': 7, 'duration': 48, 'completed': true},
          ];
          _totalWorkouts = _workouts.length;
          _completedWorkouts = _workouts.where((w) => w['completed'] == true).length;
          _totalMinutes = _workouts.fold(0, (sum, w) => sum + (w['duration'] as int));
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredWorkouts {
    switch (_filter) {
      case 'Concluídos': return _workouts.where((w) => w['completed'] == true).toList();
      case 'Incompletos': return _workouts.where((w) => w['completed'] != true).toList();
      default: return _workouts;
    }
  }

  Map<String, List<dynamic>> get _groupedWorkouts {
    final map = <String, List<dynamic>>{};
    for (final w in _filteredWorkouts) {
      final date = _formatDate(w['date']);
      map.putIfAbsent(date, () => []).add(w);
    }
    return map;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Sem data';
    final parts = dateStr.split('-');
    if (parts.length < 3) return dateStr;
    final months = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
    final day = int.tryParse(parts[2]) ?? 0;
    final monthIdx = (int.tryParse(parts[1]) ?? 1) - 1;
    final year = parts[0];
    final now = DateTime.now();
    if (day == now.day && monthIdx == now.month - 1 && int.tryParse(year) == now.year) return 'Hoje';
    final yesterday = now.subtract(const Duration(days: 1));
    if (day == yesterday.day && monthIdx == yesterday.month - 1) return 'Ontem';
    return '$day de ${months[monthIdx.clamp(0, 11)]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Treinos Anteriores')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  _buildStatsHeader(),
                  _buildFilterChips(),
                  Expanded(child: _buildWorkoutList()),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsHeader() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildHeaderStat('Total', '$_totalWorkouts', AppColors.primary),
            _buildHeaderStat('Concluídos', '$_completedWorkouts', AppColors.success),
            _buildHeaderStat('Minutos', '$_totalMinutes', AppColors.info),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Todos', 'Concluídos', 'Incompletos'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          final selected = _filter == f;
          return ChoiceChip(
            label: Text(f),
            selected: selected,
            onSelected: (_) => setState(() => _filter = f),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceLight,
            labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutList() {
    final grouped = _groupedWorkouts;
    if (grouped.isEmpty) {
      return Center(child: Text('Nenhum treino encontrado', style: TextStyle(color: AppColors.textMuted)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.key, style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            ...entry.value.map((w) {
              final completed = w['completed'] == true;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 4, height: 48,
                    decoration: BoxDecoration(
                      color: completed ? AppColors.success : AppColors.warning,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  title: Text(w['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('${w['exercises'] ?? 0} exercícios · ${w['duration'] ?? 0} min', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: Icon(
                    completed ? Icons.check_circle : Icons.schedule,
                    color: completed ? AppColors.success : AppColors.warning,
                    size: 20,
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}

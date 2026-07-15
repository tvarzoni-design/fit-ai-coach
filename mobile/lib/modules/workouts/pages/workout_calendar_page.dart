import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutCalendarPage extends StatefulWidget {
  const WorkoutCalendarPage({super.key});

  @override
  State<WorkoutCalendarPage> createState() => _WorkoutCalendarPageState();
}

class _WorkoutCalendarPageState extends State<WorkoutCalendarPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  List<dynamic> _workouts = [];
  List<dynamic> _workoutDays = [];
  bool _isLoading = true;
  int _streak = 0;
  int _workoutsThisMonth = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getWorkoutHistory();
      if (mounted) {
        setState(() {
          _workouts = response.data ?? [];
          _workoutDays = _workouts.map((w) => _parseDate(w['completedAt'])).whereType<DateTime>().toList();
          _isLoading = false;
        });
        _calculateStats();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime? _parseDate(dynamic dateStr) {
    if (dateStr == null) return null;
    try { return DateTime.parse(dateStr.toString()); } catch (_) { return null; }
  }

  void _calculateStats() {
    _streak = 0;
    _workoutsThisMonth = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final uniqueDays = _workoutDays.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    DateTime checkDay = today;
    while (uniqueDays.contains(checkDay)) {
      _streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    _workoutsThisMonth = uniqueDays.where((d) => d.year == _currentMonth.year && d.month == _currentMonth.month).length;
  }

  bool _hasWorkout(DateTime day) {
    return _workoutDays.any((d) => d.year == day.year && d.month == day.month && d.day == day.day);
  }

  List<dynamic> _getWorkoutsForDay(DateTime day) {
    return _workouts.where((w) {
      final d = _parseDate(w['completedAt']);
      return d != null && d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Calendário de Treinos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildCalendarHeader(),
                  const SizedBox(height: 12),
                  _buildCalendarGrid(),
                  const SizedBox(height: 24),
                  _buildDayWorkouts(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(Icons.local_fire_department, '$_streak', 'Sequência', AppColors.secondary),
        const SizedBox(width: 12),
        _buildStatCard(Icons.fitness_center, '$_workoutsThisMonth', 'Este mês', AppColors.primary),
        const SizedBox(width: 12),
        _buildStatCard(Icons.calendar_today, '${_workouts.length}', 'Total', AppColors.info),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final months = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousMonth),
        Text('${months[_currentMonth.month - 1]} ${_currentMonth.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysOfWeek = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = (firstDay.weekday - 1) % 7;
    final daysInMonth = lastDay.day;
    final today = DateTime.now();
    final totalCells = startWeekday + daysInMonth;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: daysOfWeek.map((d) => Expanded(
                child: Center(child: Text(d, style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
              )).toList(),
            ),
            const SizedBox(height: 8),
            ...List.generate((totalCells / 7).ceil(), (week) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  final cellIndex = week * 7 + dayIndex;
                  final dayNumber = cellIndex - startWeekday + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) return Expanded(child: const SizedBox(height: 40));
                  final day = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                  final hasWorkout = _hasWorkout(day);
                  final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
                  final isSelected = day.year == _selectedDate.year && day.month == _selectedDate.month && day.day == _selectedDate.day;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = day),
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : isToday ? AppColors.surfaceLight : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday ? Border.all(color: AppColors.primary, width: 1) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$dayNumber', style: TextStyle(fontWeight: isToday ? FontWeight.bold : FontWeight.normal, color: AppColors.textPrimary, fontSize: 14)),
                            if (hasWorkout) ...[
                              const SizedBox(height: 2),
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayWorkouts() {
    final dayWorkouts = _getWorkoutsForDay(_selectedDate);
    final isToday = _selectedDate.year == DateTime.now().year && _selectedDate.month == DateTime.now().month && _selectedDate.day == DateTime.now().day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isToday ? 'Hoje' : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (dayWorkouts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.fitness_center, size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 8),
                    Text('Nenhum treino neste dia', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          )
        else
          ...dayWorkouts.map((w) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.check_circle, color: AppColors.success, size: 24),
              ),
              title: Text(w['name'] ?? 'Treino', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${w['estimatedDuration'] ?? 0} min', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () => context.push('/workout/${w['id'] ?? ''}'),
            ),
          )),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({super.key});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  List<dynamic> _history = [];
  bool _isLoading = true;
  bool _isCalendarView = false;
  String? _error;
  int _totalWorkouts = 0;
  int _totalMinutes = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getWorkouts();
      final data = response.data ?? [];
      int totalMin = 0;
      for (final w in data) {
        totalMin += (w['estimatedDuration'] ?? 0) as int;
      }
      if (mounted) {
        setState(() {
          _history = data;
          _totalWorkouts = data.length;
          _totalMinutes = totalMin;
          _streak = _calculateStreak(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  int _calculateStreak(List<dynamic> data) {
    if (data.isEmpty) return 0;
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final dayStr = DateFormat('yyyy-MM-dd').format(day);
      final hasWorkout = data.any((w) {
        final date = w['completedAt'] ?? w['createdAt'] ?? '';
        return date.toString().startsWith(dayStr);
      });
      if (hasWorkout) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Histórico'),
        actions: [
          IconButton(
            icon: Icon(_isCalendarView ? Icons.list : Icons.calendar_month, size: 22),
            onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadHistory, child: const Text('Tentar novamente')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsSummary(),
                        const SizedBox(height: 24),
                        Text(
                          _isCalendarView ? 'Calendário' : 'Treinos Recentes',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        const SizedBox(height: 12),
                        if (_history.isEmpty)
                          _buildEmptyState()
                        else if (_isCalendarView)
                          _buildCalendarView()
                        else
                          _buildListView(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatsSummary() {
    return Row(
      children: [
        _buildStatCard(Icons.fitness_center, '$_totalWorkouts', 'Treinos', AppColors.primary),
        const SizedBox(width: 12),
        _buildStatCard(Icons.timer_outlined, '${_totalMinutes}min', 'Total', AppColors.secondary),
        const SizedBox(width: 12),
        _buildStatCard(Icons.local_fire_department, '$_streak', 'Sequência', AppColors.warning),
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
              Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('Nenhum treino registrado', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Complete um treino para ver o histórico', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final sorted = List<dynamic>.from(_history);
    sorted.sort((a, b) {
      final dateA = a['completedAt'] ?? a['createdAt'] ?? '';
      final dateB = b['completedAt'] ?? b['createdAt'] ?? '';
      return dateB.toString().compareTo(dateA.toString());
    });

    return Column(
      children: sorted.map<Widget>((workout) {
        final name = workout['name'] ?? 'Treino';
        final duration = workout['estimatedDuration'] ?? 0;
        final dateStr = workout['completedAt'] ?? workout['createdAt'] ?? '';
        DateTime? date;
        try { date = DateTime.parse(dateStr.toString()); } catch (_) {}

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('$duration min', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : '—',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarView() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayWeekday = DateTime(now.year, now.month, 1).weekday;

    final workoutDays = <int>{};
    for (final w in _history) {
      final dateStr = w['completedAt'] ?? w['createdAt'] ?? '';
      try {
        final d = DateTime.parse(dateStr.toString());
        if (d.year == now.year && d.month == now.month) {
          workoutDays.add(d.day);
        }
      } catch (_) {}
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              DateFormat('MMMM yyyy', 'pt_BR').format(now),
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'].map((d) {
                return SizedBox(
                  width: 40,
                  child: Center(child: Text(d, style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600))),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
              itemCount: (firstDayWeekday - 1) + daysInMonth,
              itemBuilder: (context, index) {
                final dayNum = index - (firstDayWeekday - 1) + 1;
                if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();
                final isToday = dayNum == now.day;
                final hasWorkout = workoutDays.contains(dayNum);

                return Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasWorkout
                          ? AppColors.success.withValues(alpha: 0.2)
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          color: hasWorkout
                              ? AppColors.success
                              : isToday
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                          fontWeight: hasWorkout || isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

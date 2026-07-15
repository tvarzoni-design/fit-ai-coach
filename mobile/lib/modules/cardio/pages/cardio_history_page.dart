import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CardioHistoryPage extends StatefulWidget {
  const CardioHistoryPage({super.key});

  @override
  State<CardioHistoryPage> createState() => _CardioHistoryPageState();
}

class _CardioHistoryPageState extends State<CardioHistoryPage> {
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getCardioSessions();
      if (mounted) {
        setState(() {
          _sessions = response.data is List ? response.data : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredSessions {
    if (_selectedDate == null) return _sessions;
    return _sessions.where((s) {
      final dateStr = s['date'] ?? s['createdAt'];
      if (dateStr == null) return false;
      final date = DateTime.tryParse(dateStr.toString());
      if (date == null) return false;
      return date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;
    }).toList();
  }

  double get _totalDistance {
    return _sessions.fold(0.0, (sum, s) => sum + (s['distance'] ?? 0).toDouble());
  }

  int get _totalDuration {
    return _sessions.fold(0, (sum, s) => sum + ((s['duration'] ?? 0) as int));
  }

  int get _totalCalories {
    return _sessions.fold(0, (sum, s) => sum + ((s['calories'] ?? 0) as int));
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}min';
    return '$m min';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '--';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '--';
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Cardio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadSessions,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 16),
                  _buildCalendarFilter(),
                  const SizedBox(height: 16),
                  _buildFrequencyChart(),
                  const SizedBox(height: 16),
                  _buildSessionList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _summaryCard(Icons.straighten, '${_totalDistance.toStringAsFixed(1)} km', 'Distância', AppColors.primary),
        const SizedBox(width: 10),
        _summaryCard(Icons.timer, _formatDuration(_totalDuration), 'Tempo', AppColors.secondary),
        const SizedBox(width: 10),
        _summaryCard(Icons.local_fire_department, '$_totalCalories kcal', 'Calorias', AppColors.warning),
      ],
    );
  }

  Widget _summaryCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Filtro por Data', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Spacer(),
                if (_selectedDate != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedDate = null),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpar', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            CalendarDatePicker(
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyChart() {
    final now = DateTime.now();
    final Map<String, int> weekCount = {};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'][day.weekday % 7];
      weekCount[key] = 0;
    }

    for (final s in _sessions) {
      final dateStr = s['date'] ?? s['createdAt'];
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr.toString());
      if (date == null) continue;
      final diff = now.difference(date).inDays;
      if (diff < 7) {
        final key = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'][date.weekday % 7];
        weekCount[key] = (weekCount[key] ?? 0) + 1;
      }
    }

    final maxCount = weekCount.values.fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequência Semanal', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weekCount.entries.map((entry) {
                  final fraction = maxCount > 0 ? entry.value / maxCount : 0.0;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.value}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: fraction > 0 ? (fraction * 80 + 8) : 8,
                          decoration: BoxDecoration(
                            color: entry.value > 0 ? AppColors.primary : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(entry.key, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    if (_filteredSessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.directions_run, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                _selectedDate != null
                    ? 'Nenhuma sessão nesta data'
                    : 'Nenhuma sessão de cardio registrada',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedDate != null
              ? 'Sessões do dia (${_filteredSessions.length})'
              : 'Todas as sessões (${_filteredSessions.length})',
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        ..._filteredSessions.map((session) => _buildSessionTile(session)),
      ],
    );
  }

  Widget _buildSessionTile(Map<String, dynamic> session) {
    final type = session['type'] ?? session['activity'] ?? 'Cardio';
    final date = session['date'] ?? session['createdAt'];
    final duration = (session['duration'] ?? 0) as int;
    final distance = (session['distance'] ?? 0).toDouble();
    final calories = (session['calories'] ?? 0) as int;
    final avgHr = session['avgHeartRate'] ?? session['avgHR'];
    final id = session['id']?.toString() ?? '';

    return GestureDetector(
      onTap: id.isNotEmpty ? () => context.push('/cardio/$id') : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_typeIcon(type.toString()), color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text(
                          '${_formatDate(date)} ${_formatTime(date)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (avgHr != null)
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: AppColors.error, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$avgHr bpm',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _sessionStat(Icons.timer, _formatDuration(duration), 'Duração'),
                  _sessionStat(Icons.straighten, '${distance.toStringAsFixed(1)} km', 'Distância'),
                  _sessionStat(Icons.local_fire_department, '$calories kcal', 'Calorias'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sessionStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'corrida':
      case 'running':
        return Icons.directions_run;
      case 'cycling':
      case 'ciclismo':
        return Icons.directions_bike;
      case 'swimming':
      case 'natação':
        return Icons.pool;
      case 'rowing':
      case 'remo':
        return Icons.rowing;
      case 'walking':
      case 'caminhada':
        return Icons.directions_walk;
      default:
        return Icons.fitness_center;
    }
  }
}

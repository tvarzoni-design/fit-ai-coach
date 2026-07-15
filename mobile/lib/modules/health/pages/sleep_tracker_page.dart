import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  List<dynamic> _sleepLogs = [];
  bool _isLoading = true;
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _quality = 3;
  double _averageHours = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/health/sleep');
      if (mounted) {
        setState(() {
          _sleepLogs = response.data ?? [];
          _isLoading = false;
          _calculateAverage();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sleepLogs = _getMockSleepLogs();
          _isLoading = false;
          _calculateAverage();
        });
      }
    }
  }

  List<dynamic> _getMockSleepLogs() {
    return [
      {'date': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(), 'bedtime': '23:15', 'wakeTime': '07:10', 'hours': 7.9, 'quality': 4},
      {'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(), 'bedtime': '00:30', 'wakeTime': '06:45', 'hours': 6.3, 'quality': 2},
      {'date': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(), 'bedtime': '22:45', 'wakeTime': '07:00', 'hours': 8.3, 'quality': 5},
      {'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(), 'bedtime': '23:30', 'wakeTime': '06:30', 'hours': 7.0, 'quality': 3},
      {'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(), 'bedtime': '23:00', 'wakeTime': '07:15', 'hours': 8.3, 'quality': 4},
      {'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), 'bedtime': '22:30', 'wakeTime': '06:45', 'hours': 8.3, 'quality': 5},
      {'date': DateTime.now().toIso8601String(), 'bedtime': '23:45', 'wakeTime': '07:00', 'hours': 7.3, 'quality': 3},
    ];
  }

  void _calculateAverage() {
    if (_sleepLogs.isEmpty) return;
    double total = 0;
    for (final log in _sleepLogs) {
      total += (log['hours'] as num).toDouble();
    }
    _averageHours = total / _sleepLogs.length;
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteColor: WidgetStateColor.resolveWith((states) => AppColors.surfaceLight),
              dayPeriodColor: WidgetStateColor.resolveWith((states) => AppColors.surfaceLight),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  Future<void> _logSleep() async {
    final bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    double hours = (wakeMinutes - bedMinutes) / 60.0;
    if (hours < 0) hours += 24;

    final log = {
      'date': DateTime.now().toIso8601String(),
      'bedtime': '${_bedtime.hour.toString().padLeft(2, '0')}:${_bedtime.minute.toString().padLeft(2, '0')}',
      'wakeTime': '${_wakeTime.hour.toString().padLeft(2, '0')}:${_wakeTime.minute.toString().padLeft(2, '0')}',
      'hours': double.parse(hours.toStringAsFixed(1)),
      'quality': _quality,
    };

    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/health/sleep', data: log);
    } catch (_) {}

    setState(() {
      _sleepLogs.add(log);
      _calculateAverage();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sono registrado com sucesso!')),
      );
    }
  }

  String _getDayLabel(int daysAgo) {
    if (daysAgo == 0) return 'Hoje';
    if (daysAgo == 1) return 'Ontem';
    return _getWeekday(DateTime.now().subtract(Duration(days: daysAgo)));
  }

  String _getWeekday(DateTime date) {
    const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return days[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rastreador de Sono')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogForm(),
                    const SizedBox(height: 16),
                    _buildAverageCard(),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(),
                    const SizedBox(height: 16),
                    _buildSleepTips(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLogForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registrar Sono', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTimeButton('Hora de Dormir', _bedtime, () => _selectTime(context, true), Icons.bedtime),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeButton('Hora de Acordar', _wakeTime, () => _selectTime(context, false), Icons.alarm),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Qualidade do Sono', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _quality = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _quality ? Icons.star : Icons.star_border,
                      color: index < _quality ? AppColors.warning : AppColors.textMuted,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logSleep,
                icon: const Icon(Icons.save),
                label: const Text('Registrar Sono'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, TimeOfDay time, VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAverageStat('Média', '${_averageHours.toStringAsFixed(1)}h', AppColors.primary),
            _buildAverageStat('Último', '${_sleepLogs.isNotEmpty ? _sleepLogs.last['hours'] : 0}h', AppColors.info),
            _buildAverageStat('Melhor', _getBestSleep(), AppColors.success),
          ],
        ),
      ),
    );
  }

  String _getBestSleep() {
    if (_sleepLogs.isEmpty) return '0h';
    double best = 0;
    for (final log in _sleepLogs) {
      if ((log['hours'] as num).toDouble() > best) {
        best = (log['hours'] as num).toDouble();
      }
    }
    return '${best.toStringAsFixed(1)}h';
  }

  Widget _buildAverageStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Últimos 7 Dias', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final logsIndex = _sleepLogs.length - 7 + index;
                  final hours = logsIndex >= 0 && logsIndex < _sleepLogs.length
                      ? (_sleepLogs[logsIndex]['hours'] as num).toDouble()
                      : 0.0;
                  final maxHours = 10.0;
                  final barHeight = (hours / maxHours) * 100;
                  final color = hours >= 7.5
                      ? AppColors.success
                      : hours >= 6
                          ? AppColors.warning
                          : AppColors.error;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${hours.toStringAsFixed(1)}',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: barHeight.clamp(4.0, 100.0),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getDayLabel(6 - index),
                            style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTips() {
    final tips = [
      {'icon': Icons.phone_android, 'title': 'Evite telas antes de dormir', 'description': 'A luz azul atrapalha a produção de melatonina'},
      {'icon': Icons.coffee, 'title': 'Evite cafeína após 14h', 'description': 'A cafeína tem meia-vida de 5-6 horas'},
      {'icon': Icons.thermostat, 'title': 'Mantenha o quarto fresco', 'description': 'Temperatura ideal entre 18-22°C'},
      {'icon': Icons.schedule, 'title': 'Mantenha horário regular', 'description': 'Dormir e acordar nos mesmos horários ajuda o ciclo circadiano'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            Text('Dicas de Sono', style: TextStyle(color: AppColors.warning, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(tip['icon'] as IconData, color: AppColors.warning, size: 20),
                ),
                title: Text(tip['title'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(tip['description'] as String, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            )),
      ],
    );
  }
}

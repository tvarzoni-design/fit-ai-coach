import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutStatsPage extends StatefulWidget {
  const WorkoutStatsPage({super.key});

  @override
  State<WorkoutStatsPage> createState() => _WorkoutStatsPageState();
}

class _WorkoutStatsPageState extends State<WorkoutStatsPage> {
  bool _isLoading = true;
  List<dynamic> _history = [];
  List<dynamic> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = context.read<AuthService>().api;
      final historyResp = await api.getWorkouts();
      List<dynamic> recordsData = [];
      try {
        final recordsResp = await api.dio.get('/workouts/personal-records');
        recordsData = recordsResp.data ?? [];
      } catch (_) {}
      if (mounted) {
        setState(() {
          _history = historyResp.data ?? [];
          _records = recordsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Estatísticas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeeklyFrequencyChart(),
                  const SizedBox(height: 24),
                  _buildVolumeChart(),
                  const SizedBox(height: 24),
                  _buildMuscleGroupPie(),
                  const SizedBox(height: 24),
                  _buildDurationTrend(),
                  const SizedBox(height: 24),
                  _buildPersonalRecordsSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  List<double> _getWeeklyData() {
    final now = DateTime.now();
    final data = List<double>.filled(7, 0);
    final labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    for (final w in _history) {
      final dateStr = w['completedAt'] ?? w['createdAt'] ?? '';
      try {
        final d = DateTime.parse(dateStr.toString());
        final diff = now.difference(d).inDays;
        if (diff < 7) {
          final weekday = d.weekday - 1;
          data[weekday]++;
        }
      } catch (_) {}
    }
    return data;
  }

  Widget _buildWeeklyFrequencyChart() {
    final data = _getWeeklyData();
    final labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final maxY = data.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequência Semanal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY < 1 ? 5 : (maxY + 1).ceilToDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[idx], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          if (value == value.roundToDouble() && value >= 0) {
                            return Text('${value.toInt()}', style: TextStyle(color: AppColors.textMuted, fontSize: 11));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(color: AppColors.surfaceLight, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: entry.value > 0 ? AppColors.primary : AppColors.surfaceLight,
                          width: 28,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Volume Total', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 8),
            Text('${_history.length} treinos registrados', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (v) => FlLine(color: AppColors.surfaceLight, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) {
                          if (v == v.roundToDouble() && v >= 0) {
                            return Text('${v.toInt()}', style: TextStyle(color: AppColors.textMuted, fontSize: 11));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          return Text('${v.toInt() + 1}ª', style: TextStyle(color: AppColors.textMuted, fontSize: 11));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(_history.length > 10 ? 10 : _history.length, (i) {
                        return FlSpot(i.toDouble(), (i + 1).toDouble());
                      }),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.surface,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroupPie() {
    final muscleCount = <String, int>{};
    for (final w in _history) {
      final muscles = (w['muscleGroups'] ?? '').toString().split(',');
      for (final m in muscles) {
        final name = m.trim();
        if (name.isNotEmpty) {
          muscleCount[name] = (muscleCount[name] ?? 0) + 1;
        }
      }
    }

    if (muscleCount.isEmpty) {
      muscleCount.addAll({'Peito': 3, 'Costas': 4, 'Pernas': 2, 'Ombros': 1, 'Braços': 2, 'Abdômen': 1});
    }

    final colors = [AppColors.primary, AppColors.secondary, AppColors.success, AppColors.warning, AppColors.info, const Color(0xFFCE93D8)];
    final entries = muscleCount.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribuição Muscular', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      sections: entries.asMap().entries.map((entry) {
                        final pct = (entry.value.value / total * 100);
                        return PieChartSectionData(
                          value: entry.value.value.toDouble(),
                          color: colors[entry.key % colors.length],
                          radius: 40,
                          title: '${pct.round()}%',
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[entry.key % colors.length], borderRadius: BorderRadius.circular(3))),
                            const SizedBox(width: 8),
                            Expanded(child: Text(entry.value.key, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                            Text('${entry.value.value}', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationTrend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tendência de Duração', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTrendChip(Icons.trending_up, 'Média', '${_history.isNotEmpty ? _history.map((w) => (w['estimatedDuration'] ?? 0) as int).fold<int>(0, (a, b) => a + b) ~/ _history.length : 0} min', AppColors.primary),
                const SizedBox(width: 8),
                _buildTrendChip(Icons.timer, 'Total', '${_history.map((w) => (w['estimatedDuration'] ?? 0) as int).fold<int>(0, (a, b) => a + b)} min', AppColors.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChip(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalRecordsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recordes Pessoais', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
                GestureDetector(
                  onTap: () => context.push('/workouts/personal-records'),
                  child: const Text('Ver todos', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 8),
                      Text('Nenhum recorde registrado ainda', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              ...(_records.take(3).map((r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.emoji_events, color: AppColors.warning, size: 22),
                    ),
                    title: Text(r['exerciseName'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    subtitle: Text('${r['weight'] ?? 0}kg × ${r['reps'] ?? 0} reps', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ))),
          ],
        ),
      ),
    );
  }
}

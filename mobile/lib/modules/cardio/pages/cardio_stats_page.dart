import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CardioStatsPage extends StatefulWidget {
  const CardioStatsPage({super.key});

  @override
  State<CardioStatsPage> createState() => _CardioStatsPageState();
}

class _CardioStatsPageState extends State<CardioStatsPage> {
  List<dynamic> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
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

  // --- Derived stats ---

  List<dynamic> get _recentSessions {
    final now = DateTime.now();
    return _sessions.where((s) {
      final dateStr = s['date'] ?? s['createdAt'];
      if (dateStr == null) return false;
      final date = DateTime.tryParse(dateStr.toString());
      if (date == null) return false;
      return now.difference(date).inDays < 7;
    }).toList();
  }

  double get _weeklyDistance =>
      _recentSessions.fold(0.0, (sum, s) => sum + (s['distance'] ?? 0).toDouble());

  int get _weeklyDuration =>
      _recentSessions.fold(0, (sum, s) => sum + ((s['duration'] ?? 0) as int));

  int get _weeklyCalories =>
      _recentSessions.fold(0, (sum, s) => sum + ((s['calories'] ?? 0) as int));

  int? get _fastestRun {
    int? best;
    for (final s in _sessions) {
      final duration = (s['duration'] ?? 0) as int;
      final distance = (s['distance'] ?? 0).toDouble();
      if (distance <= 0 || duration <= 0) continue;
      final pace = duration / distance;
      if (best == null || pace < best) best = duration;
    }
    return best;
  }

  double get _longestDistance {
    double best = 0;
    for (final s in _sessions) {
      final d = (s['distance'] ?? 0).toDouble();
      if (d > best) best = d;
    }
    return best;
  }

  int get _highestCalories {
    int best = 0;
    for (final s in _sessions) {
      final c = (s['calories'] ?? 0) as int;
      if (c > best) best = c;
    }
    return best;
  }

  double get _avgHeartRate {
    final withHr = _sessions.where((s) => (s['avgHeartRate'] ?? s['avgHR']) != null).toList();
    if (withHr.isEmpty) return 0;
    final sum = withHr.fold(0.0, (acc, s) => acc + ((s['avgHeartRate'] ?? s['avgHR']) as num).toDouble());
    return sum / withHr.length;
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}min';
    return '$m min';
  }

  List<FlSpot> _distanceOverTime() {
    final now = DateTime.now();
    final List<FlSpot> spots = [];
    for (int i = 13; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      double total = 0;
      for (final s in _sessions) {
        final dateStr = s['date'] ?? s['createdAt'];
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr.toString());
        if (date == null) continue;
        if (date.year == day.year && date.month == day.month && date.day == day.day) {
          total += (s['distance'] ?? 0).toDouble();
        }
      }
      spots.add(FlSpot((13 - i).toDouble(), total));
    }
    return spots;
  }

  List<FlSpot> _calorieOverTime() {
    final now = DateTime.now();
    final List<FlSpot> spots = [];
    for (int i = 13; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      double total = 0;
      for (final s in _sessions) {
        final dateStr = s['date'] ?? s['createdAt'];
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr.toString());
        if (date == null) continue;
        if (date.year == day.year && date.month == day.month && date.day == day.day) {
          total += ((s['calories'] ?? 0) as int).toDouble();
        }
      }
      spots.add(FlSpot((13 - i).toDouble(), total));
    }
    return spots;
  }

  List<FlSpot> _heartRateTrend() {
    final now = DateTime.now();
    final List<FlSpot> spots = [];
    for (int i = 13; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      double sum = 0;
      int count = 0;
      for (final s in _sessions) {
        final dateStr = s['date'] ?? s['createdAt'];
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr.toString());
        if (date == null) continue;
        if (date.year == day.year && date.month == day.month && date.day == day.day) {
          final hr = s['avgHeartRate'] ?? s['avgHR'];
          if (hr != null) {
            sum += (hr as num).toDouble();
            count++;
          }
        }
      }
      spots.add(FlSpot((13 - i).toDouble(), count > 0 ? sum / count : 0));
    }
    return spots;
  }

  Map<String, double> get _zoneDistribution {
    int fatBurn = 0, cardio = 0, peak = 0, other = 0;
    for (final s in _sessions) {
      final zones = s['heartRateZones'];
      if (zones is Map) {
        fatBurn += ((zones['fatBurn'] ?? zones['zone2'] ?? 0) as num).toInt();
        cardio += ((zones['cardio'] ?? zones['zone3'] ?? 0) as num).toInt();
        peak += ((zones['peak'] ?? zones['zone4'] ?? 0) as num).toInt();
      } else {
        final hr = (s['avgHeartRate'] ?? s['avgHR']) as num?;
        if (hr != null) {
          if (hr < 130) fatBurn++;
          else if (hr < 160) cardio++;
          else peak++;
          continue;
        }
        other++;
      }
    }
    final total = fatBurn + cardio + peak + other;
    if (total == 0) return {'Queima de Gordura': 0, 'Cardio': 0, 'Pico': 0, 'Outro': 0};
    return {
      'Queima de Gordura': fatBurn / total * 100,
      'Cardio': cardio / total * 100,
      'Pico': peak / total * 100,
      'Outro': other / total * 100,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas de Cardio'),
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
                  _buildWeeklySummary(),
                  const SizedBox(height: 16),
                  _buildLineChartCard(
                    'Distância ao Longo do Tempo',
                    Icons.straighten,
                    _distanceOverTime(),
                    AppColors.primary,
                    'km',
                  ),
                  const SizedBox(height: 16),
                  _buildLineChartCard(
                    'Calorias Queimadas',
                    Icons.local_fire_department,
                    _calorieOverTime(),
                    AppColors.warning,
                    'kcal',
                  ),
                  const SizedBox(height: 16),
                  _buildLineChartCard(
                    'Tendência de FC Média',
                    Icons.favorite,
                    _heartRateTrend(),
                    AppColors.error,
                    'bpm',
                  ),
                  const SizedBox(height: 16),
                  _buildBestRecords(),
                  const SizedBox(height: 16),
                  _buildZoneDistribution(),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeklySummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_week, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Resumo da Semana', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _weekStat(Icons.straighten, '${_weeklyDistance.toStringAsFixed(1)} km', 'Distância', AppColors.primary),
                _weekStat(Icons.timer, _formatDuration(_weeklyDuration), 'Tempo', AppColors.secondary),
                _weekStat(Icons.local_fire_department, '$_weeklyCalories kcal', 'Calorias', AppColors.warning),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _weekStat(Icons.favorite, '${_avgHeartRate.round()} bpm', 'FC Média', AppColors.error),
                _weekStat(Icons.repeat, '${_recentSessions.length}', 'Sessões', AppColors.info),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(String title, IconData icon, List<FlSpot> spots, Color color, String unit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: spots.every((s) => s.y == 0)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 36, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          const Text('Sem dados para exibir', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _maxY(spots) / 4 > 0 ? _maxY(spots) / 4 : 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: AppColors.surfaceLight,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: color,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                                radius: 3,
                                color: color,
                                strokeColor: AppColors.surface,
                                strokeWidth: 2,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: color.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (spots) => spots.map((s) {
                              return LineTooltipItem(
                                '${s.y.toStringAsFixed(1)} $unit',
                                TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _maxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    double max = 0;
    for (final s in spots) {
      if (s.y > max) max = s.y;
    }
    return max > 0 ? max : 10;
  }

  Widget _buildBestRecords() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                const Text('Melhores Recordes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            _recordRow(Icons.speed, 'Corrida mais rápida', _fastestRun != null ? _formatDuration(_fastestRun!) : '--', AppColors.success),
            const Divider(color: AppColors.surfaceLight, height: 24),
            _recordRow(Icons.straighten, 'Maior distância', _longestDistance > 0 ? '${_longestDistance.toStringAsFixed(2)} km' : '--', AppColors.primary),
            const Divider(color: AppColors.surfaceLight, height: 24),
            _recordRow(Icons.local_fire_department, 'Maior queima de calorias', _highestCalories > 0 ? '$_highestCalories kcal' : '--', AppColors.warning),
            const Divider(color: AppColors.surfaceLight, height: 24),
            _recordRow(Icons.favorite, 'FC média mais alta', _avgHeartRate > 0 ? '${_avgHeartRate.round()} bpm' : '--', AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _recordRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      ],
    );
  }

  Widget _buildZoneDistribution() {
    final zones = _zoneDistribution;
    final colors = {
      'Queima de Gordura': AppColors.success,
      'Cardio': AppColors.warning,
      'Pico': AppColors.error,
      'Outro': AppColors.textMuted,
    };

    final hasData = zones.values.any((v) => v > 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                const Text('Distribuição de Zonas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 20),
            if (!hasData)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.pie_chart_outline, size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 8),
                    const Text('Sem dados de zonas disponíveis', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              )
            else ...[
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 36,
                    sections: zones.entries.map((entry) {
                      final color = colors[entry.key] ?? AppColors.textMuted;
                      return PieChartSectionData(
                        value: entry.value,
                        color: color,
                        radius: 30,
                        title: entry.value > 5 ? '${entry.value.round()}%' : '',
                        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...zones.entries.map((entry) {
                final color = colors[entry.key] ?? AppColors.textMuted;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(entry.key, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

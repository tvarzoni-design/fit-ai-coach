import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class StrengthProgressPage extends StatefulWidget {
  const StrengthProgressPage({super.key});

  @override
  State<StrengthProgressPage> createState() => _StrengthProgressPageState();
}

class _StrengthProgressPageState extends State<StrengthProgressPage> {
  String _selectedExercise = 'Supino Reto';
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _oneRepMaxHistory = [];
  List<Map<String, dynamic>> _volumeHistory = [];
  bool _isLoading = true;

  final List<String> _defaultExercises = [
    'Supino Reto',
    'Agachamento',
    'Levantamento Terra',
    'Desenvolvimento',
    'Puxada Frontal',
    'Remada Curvada',
    'Leg Press',
    'Cadeira Extensora',
    'Mesa Flexora',
    'Elevação Lateral',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getMeasurements();
      if (mounted) {
        final data = response.data ?? {};
        _exercises = (data['exercises'] as List?)
                ?.map<Map<String, dynamic>>((e) => {
                      'name': e['name'] ?? e['exerciseName'] ?? '',
                    })
                .toList() ??
            [];
        if (_exercises.isEmpty) {
          _exercises = _defaultExercises.map((e) => {'name': e}).toList();
        }
        _generateMockData();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _exercises = _defaultExercises.map((e) => {'name': e}).toList();
        _generateMockData();
        setState(() => _isLoading = false);
      }
    }
  }

  void _generateMockData() {
    final now = DateTime.now();
    final baseOneRepMax = _getBaseMax(_selectedExercise);
    final baseVolume = _getBaseVolume(_selectedExercise);

    _oneRepMaxHistory = List.generate(12, (i) {
      final date = now.subtract(Duration(days: (11 - i) * 7));
      final value = baseOneRepMax + (i * 2.5) + (i % 3) * 1.5;
      return {
        'date': '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        'value': double.parse(value.toStringAsFixed(1)),
      };
    });

    _volumeHistory = List.generate(12, (i) {
      final date = now.subtract(Duration(days: (11 - i) * 7));
      final value = baseVolume + (i * 500) + (i % 4) * 200;
      return {
        'date': '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        'value': double.parse(value.toStringAsFixed(0)),
      };
    });
  }

  double _getBaseMax(String exercise) {
    switch (exercise) {
      case 'Supino Reto':
        return 80;
      case 'Agachamento':
        return 100;
      case 'Levantamento Terra':
        return 120;
      case 'Desenvolvimento':
        return 45;
      case 'Puxada Frontal':
        return 60;
      case 'Remada Curvada':
        return 65;
      case 'Leg Press':
        return 160;
      case 'Cadeira Extensora':
        return 50;
      case 'Mesa Flexora':
        return 45;
      case 'Elevação Lateral':
        return 14;
      default:
        return 60;
    }
  }

  double _getBaseVolume(String exercise) {
    switch (exercise) {
      case 'Supino Reto':
        return 4800;
      case 'Agachamento':
        return 6000;
      case 'Levantamento Terra':
        return 5400;
      case 'Desenvolvimento':
        return 2700;
      case 'Puxada Frontal':
        return 3600;
      case 'Remada Curvada':
        return 3900;
      case 'Leg Press':
        return 9600;
      case 'Cadeira Extensora':
        return 3000;
      case 'Mesa Flexora':
        return 2700;
      case 'Elevação Lateral':
        return 840;
      default:
        return 3600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Progresso de Força'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExerciseSelector(),
                    const SizedBox(height: 16),
                    _buildProgressSummary(),
                    const SizedBox(height: 24),
                    Text(
                      '1RM Estimado',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOneRepMaxChart(),
                    const SizedBox(height: 24),
                    Text(
                      'Carga de Volume',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVolumeChart(),
                    const SizedBox(height: 24),
                    Text(
                      'Comparação com Período Anterior',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildExerciseSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedExercise,
          isExpanded: true,
          dropdownColor: AppColors.surfaceLight,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
          items: _exercises
              .map((e) => DropdownMenuItem(
                    value: e['name'] as String,
                    child: Text(e['name'] as String),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedExercise = value;
                _generateMockData();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    final currentMax = _oneRepMaxHistory.isNotEmpty
        ? _oneRepMaxHistory.last['value'] as double
        : 0.0;
    final firstMax = _oneRepMaxHistory.isNotEmpty
        ? _oneRepMaxHistory.first['value'] as double
        : 0.0;
    final progress = firstMax > 0 ? ((currentMax - firstMax) / firstMax * 100) : 0.0;

    final currentVolume = _volumeHistory.isNotEmpty
        ? _volumeHistory.last['value'] as double
        : 0.0;
    final firstVolume = _volumeHistory.isNotEmpty
        ? _volumeHistory.first['value'] as double
        : 0.0;
    final volumeProgress = firstVolume > 0 ? ((currentVolume - firstVolume) / firstVolume * 100) : 0.0;

    return Row(
      children: [
        _buildSummaryCard(
          '1RM Atual',
          '${currentMax.toStringAsFixed(1)} kg',
          Icons.fitness_center,
          AppColors.primary,
          progress,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          'Volume Semanal',
          '${(currentVolume / 1000).toStringAsFixed(1)}k kg',
          Icons.show_chart,
          AppColors.success,
          volumeProgress,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color, double progress) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  progress >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: progress >= 0 ? AppColors.success : AppColors.error,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${progress >= 0 ? '+' : ''}${progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: progress >= 0 ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOneRepMaxChart() {
    if (_oneRepMaxHistory.isEmpty) {
      return _buildEmptyChart('Sem dados de 1RM');
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _oneRepMaxHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), _oneRepMaxHistory[i]['value'] as double));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.2).clamp(2.0, 15.0);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) > 0 ? (maxY - minY) / 4 : 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.surfaceLight,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(0)}kg',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: _oneRepMaxHistory.length > 6 ? (_oneRepMaxHistory.length / 4).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= _oneRepMaxHistory.length) return const SizedBox.shrink();
                  final date = _oneRepMaxHistory[idx]['date'] as String;
                  final parts = date.split('/');
                  if (parts.length >= 2) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${parts[0]}/${parts[1]}',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.primary,
                  strokeWidth: 1.5,
                  strokeColor: AppColors.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItems: (spots) => spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} kg',
                  TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeChart() {
    if (_volumeHistory.isEmpty) {
      return _buildEmptyChart('Sem dados de volume');
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _volumeHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), _volumeHistory[i]['value'] as double));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.2).clamp(100.0, 1000.0);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) > 0 ? (maxY - minY) / 4 : 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.surfaceLight,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (value >= 1000) {
                    return Text(
                      '${(value / 1000).toStringAsFixed(1)}k',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                    );
                  }
                  return Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: _volumeHistory.length > 6 ? (_volumeHistory.length / 4).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= _volumeHistory.length) return const SizedBox.shrink();
                  final date = _volumeHistory[idx]['date'] as String;
                  final parts = date.split('/');
                  if (parts.length >= 2) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${parts[0]}/${parts[1]}',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: spots.map((spot) {
            return BarChartGroupData(
              x: spot.x.toInt(),
              barRods: [
                BarChartRodData(
                  toY: spot.y,
                  color: AppColors.success,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY + padding,
                    color: AppColors.surfaceLight,
                  ),
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)} kg',
                  TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    final currentMax = _oneRepMaxHistory.isNotEmpty
        ? _oneRepMaxHistory.last['value'] as double
        : 0.0;
    final sixWeeksAgo = _oneRepMaxHistory.length > 6
        ? _oneRepMaxHistory[_oneRepMaxHistory.length - 7]['value'] as double
        : (_oneRepMaxHistory.isNotEmpty ? _oneRepMaxHistory.first['value'] as double : 0.0);
    final diff = currentMax - sixWeeksAgo;
    final percentage = sixWeeksAgo > 0 ? (diff / sixWeeksAgo * 100) : 0.0;

    final currentVol = _volumeHistory.isNotEmpty ? _volumeHistory.last['value'] as double : 0.0;
    final oldVol = _volumeHistory.length > 6
        ? _volumeHistory[_volumeHistory.length - 7]['value'] as double
        : (_volumeHistory.isNotEmpty ? _volumeHistory.first['value'] as double : 0.0);
    final volDiff = currentVol - oldVol;
    final volPercentage = oldVol > 0 ? (volDiff / oldVol * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Últimas 6 semanas',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildComparisonItem(
                '1RM',
                '${sixWeeksAgo.toStringAsFixed(1)} kg',
                '${currentMax.toStringAsFixed(1)} kg',
                diff,
                percentage,
                AppColors.primary,
              ),
              const SizedBox(width: 16),
              _buildComparisonItem(
                'Volume',
                '${(oldVol / 1000).toStringAsFixed(1)}k',
                '${(currentVol / 1000).toStringAsFixed(1)}k',
                volDiff,
                volPercentage,
                AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(
    String label,
    String oldValue,
    String newValue,
    double diff,
    double percentage,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  oldValue,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 12),
                const SizedBox(width: 6),
                Text(
                  newValue,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (percentage >= 0 ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: percentage >= 0 ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: AppColors.textMuted)),
      ),
    );
  }
}

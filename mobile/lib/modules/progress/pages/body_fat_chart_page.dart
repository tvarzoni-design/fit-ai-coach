import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class BodyFatChartPage extends StatefulWidget {
  const BodyFatChartPage({super.key});

  @override
  State<BodyFatChartPage> createState() => _BodyFatChartPageState();
}

class _BodyFatChartPageState extends State<BodyFatChartPage> {
  List<Map<String, dynamic>> _measurements = [];
  bool _isLoading = true;
  double _currentBodyFat = 0;
  double _goalBodyFat = 15.0;

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
        _currentBodyFat = (data['bodyFat'] ?? 18.5).toDouble();
        final history = (data['history'] as List?) ?? [];
        _measurements = history
            .where((m) => m['type'] == 'gordura_corporal')
            .map<Map<String, dynamic>>((m) => {
                  'date': m['date'] ?? m['createdAt'] ?? '',
                  'value': (m['value'] ?? 0).toDouble(),
                })
            .toList();
        if (_measurements.isEmpty) {
          _measurements = _generateMockData();
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _measurements = _generateMockData();
          _currentBodyFat = 18.5;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _generateMockData() {
    final now = DateTime.now();
    return List.generate(16, (i) {
      final date = now.subtract(Duration(days: (15 - i) * 7));
      final value = 22.0 - (i * 0.25) + (i % 3) * 0.3;
      return {
        'date': '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        'value': double.parse(value.toStringAsFixed(1)),
      };
    });
  }

  String _getCategory(double value) {
    if (value < 6) return 'Atleta';
    if (value < 14) return 'Fitness';
    if (value < 18) return 'Aceitável';
    if (value < 25) return 'Médio';
    if (value < 32) return 'Acima do Médio';
    return 'Obesidade';
  }

  Color _getCategoryColor(double value) {
    if (value < 6) return AppColors.info;
    if (value < 14) return AppColors.success;
    if (value < 18) return AppColors.primary;
    if (value < 25) return AppColors.warning;
    return AppColors.error;
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
        title: const Text('Gordura Corporal'),
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
                    _buildCurrentCard(),
                    const SizedBox(height: 16),
                    _buildGoalCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Evolução',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChart(),
                    const SizedBox(height: 24),
                    Text(
                      'Categorias de Gordura Corporal',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoriesOverlay(),
                    const SizedBox(height: 24),
                    Text(
                      'Registros',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMeasurementsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentCard() {
    final category = _getCategory(_currentBodyFat);
    final color = _getCategoryColor(_currentBodyFat);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.pie_chart, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gordura Atual', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentBodyFat.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    final diff = _currentBodyFat - _goalBodyFat;
    final percentage = _goalBodyFat > 0 ? (diff / _goalBodyFat * 100).abs() : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meta',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '${_goalBodyFat.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (_currentBodyFat / 40).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Positioned(
                left: (_goalBodyFat / 40).clamp(0.0, 1.0) * (MediaQuery.of(context).size.width - 128) - 1,
                top: -4,
                child: Container(
                  width: 2,
                  height: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                diff > 0 ? 'Faltam ${diff.toStringAsFixed(1)}%' : 'Meta atingida!',
                style: TextStyle(
                  color: diff > 0 ? AppColors.warning : AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}% restante',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_measurements.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Sem dados suficientes',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _measurements.length; i++) {
      spots.add(FlSpot(i.toDouble(), _measurements[i]['value'] as double));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.2).clamp(1.0, 5.0);

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY - padding,
                maxY: maxY + padding,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: _goalBodyFat,
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10,
                        ),
                        labelResolver: (line) => 'Meta: ${line.y.toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
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
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toStringAsFixed(0)}%',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: _measurements.length > 6 ? (_measurements.length / 4).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _measurements.length) return const SizedBox.shrink();
                        final date = _measurements[idx]['date'] as String;
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
                    color: AppColors.warning,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.warning,
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
                          AppColors.warning.withValues(alpha: 0.25),
                          AppColors.warning.withValues(alpha: 0.0),
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
                        '${spot.y.toStringAsFixed(1)}%',
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesOverlay() {
    final categories = [
      {'label': 'Atleta', 'range': '3-6%', 'color': AppColors.info, 'min': 3.0, 'max': 6.0},
      {'label': 'Fitness', 'range': '7-13%', 'color': AppColors.success, 'min': 7.0, 'max': 13.0},
      {'label': 'Aceitável', 'range': '14-17%', 'color': AppColors.primary, 'min': 14.0, 'max': 17.0},
      {'label': 'Médio', 'range': '18-24%', 'color': AppColors.warning, 'min': 18.0, 'max': 24.0},
      {'label': 'Obesidade', 'range': '25%+', 'color': AppColors.error, 'min': 25.0, 'max': 40.0},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: categories.map((cat) {
          final isActive = _currentBodyFat >= (cat['min'] as double) &&
              _currentBodyFat <= (cat['max'] as double);
          final color = cat['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(color: color.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cat['label'] as String,
                    style: TextStyle(
                      color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  cat['range'] as String,
                  style: TextStyle(
                    color: isActive ? color : AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, color: color, size: 16),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMeasurementsList() {
    final reversed = List<Map<String, dynamic>>.from(_measurements.reversed);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversed.length,
      itemBuilder: (context, index) {
        final entry = reversed[index];
        final value = entry['value'] as double;
        final date = entry['date'] as String;
        final color = _getCategoryColor(value);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pie_chart, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      '${value.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getCategory(value),
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

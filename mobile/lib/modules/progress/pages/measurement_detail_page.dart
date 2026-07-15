import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class MeasurementDetailPage extends StatefulWidget {
  final String measurementType;

  const MeasurementDetailPage({super.key, required this.measurementType});

  @override
  State<MeasurementDetailPage> createState() => _MeasurementDetailPageState();
}

class _MeasurementDetailPageState extends State<MeasurementDetailPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  String get _title {
    switch (widget.measurementType) {
      case 'peso':
        return 'Peso';
      case 'gordura_corporal':
        return 'Gordura Corporal';
      case 'massa_muscular':
        return 'Massa Muscular';
      case 'peito':
        return 'Peito';
      case 'cintura':
        return 'Cintura';
      case 'quadril':
        return 'Quadril';
      case 'braco':
        return 'Braço';
      case 'coxa':
        return 'Coxa';
      default:
        return 'Medição';
    }
  }

  String get _unit {
    switch (widget.measurementType) {
      case 'peso':
        return 'kg';
      case 'gordura_corporal':
        return '%';
      case 'massa_muscular':
        return 'kg';
      default:
        return 'cm';
    }
  }

  IconData get _icon {
    switch (widget.measurementType) {
      case 'peso':
        return Icons.monitor_weight;
      case 'gordura_corporal':
        return Icons.pie_chart;
      case 'massa_muscular':
        return Icons.fitness_center;
      default:
        return Icons.straighten;
    }
  }

  Color get _color {
    switch (widget.measurementType) {
      case 'peso':
        return AppColors.primary;
      case 'gordura_corporal':
        return AppColors.warning;
      case 'massa_muscular':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getMeasurements();
      if (mounted) {
        final data = response.data ?? {};
        final measurements = (data['history'] as List?) ?? [];
        _history = measurements
            .where((m) => m['type'] == widget.measurementType || m['name'] == widget.measurementType)
            .map<Map<String, dynamic>>((m) => {
                  'date': m['date'] ?? m['createdAt'] ?? '',
                  'value': (m['value'] ?? 0).toDouble(),
                })
            .toList();
        if (_history.isEmpty) {
          _history = _generateMockHistory();
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _history = _generateMockHistory();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _generateMockHistory() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final date = now.subtract(Duration(days: (11 - i) * 7));
      final baseValue = widget.measurementType == 'peso'
          ? 80.0
          : widget.measurementType == 'gordura_corporal'
              ? 20.0
              : widget.measurementType == 'massa_muscular'
                  ? 35.0
                  : 90.0;
      final variation = (i * 0.3) + (DateTime.now().millisecond % 10) * 0.1;
      return {
        'date': '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        'value': baseValue - variation,
      };
    });
  }

  double get _average {
    if (_history.isEmpty) return 0;
    return _history.map<double>((m) => m['value'] as double).reduce((a, b) => a + b) / _history.length;
  }

  double get _min {
    if (_history.isEmpty) return 0;
    return _history.map<double>((m) => m['value'] as double).reduce((a, b) => a < b ? a : b);
  }

  double get _max {
    if (_history.isEmpty) return 0;
    return _history.map<double>((m) => m['value'] as double).reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddMeasurementSheet(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    Text(
                      'Histórico',
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
                      'Registros',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildHistoryList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddMeasurementSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final currentValue = _history.isNotEmpty ? _history.last['value'] : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: _color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentValue.toStringAsFixed(1)} $_unit',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_history.length >= 2)
            _buildTrendIndicator(),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final current = _history.last['value'] as double;
    final previous = _history[_history.length - 2]['value'] as double;
    final diff = current - previous;
    final isUp = diff > 0;
    final isWeight = widget.measurementType == 'peso' || widget.measurementType == 'gordura_corporal';
    final isPositive = isWeight ? !isUp : isUp;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? AppColors.success : AppColors.error,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            '${diff.abs().toStringAsFixed(1)} $_unit',
            style: TextStyle(
              color: isPositive ? AppColors.success : AppColors.error,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Média', '${_average.toStringAsFixed(1)} $_unit', AppColors.info),
        const SizedBox(width: 12),
        _buildStatCard('Mínimo', '${_min.toStringAsFixed(1)} $_unit', AppColors.success),
        const SizedBox(width: 12),
        _buildStatCard('Máximo', '${_max.toStringAsFixed(1)} $_unit', AppColors.warning),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_history.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Sem dados suficientes para gráfico',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _history.length; i++) {
      spots.add(FlSpot(i.toDouble(), _history[i]['value'] as double));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;

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
                  value.toStringAsFixed(0),
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: _history.length > 6 ? (_history.length / 4).ceilToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= _history.length) return const SizedBox.shrink();
                  final date = _history[idx]['date'] as String;
                  final parts = date.split('/');
                  if (parts.length >= 2) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${parts[0]}/${parts[1]}',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10),
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
              color: _color,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3,
                  color: _color,
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
                    _color.withValues(alpha: 0.3),
                    _color.withValues(alpha: 0.0),
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
                  '${spot.y.toStringAsFixed(1)} $_unit',
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

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Nenhuma medição registrada',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final reversedIndex = _history.length - 1 - index;
        final entry = _history[reversedIndex];
        final value = entry['value'] as double;
        final date = entry['date'] as String;

        double? prevValue;
        if (reversedIndex < _history.length - 1) {
          prevValue = _history[reversedIndex + 1]['value'] as double;
        }

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
                  color: _color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${value.toStringAsFixed(1)} $_unit',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (prevValue != null)
                Text(
                  '${value >= prevValue ? '+' : ''}${(value - prevValue).toStringAsFixed(1)}',
                  style: TextStyle(
                    color: (widget.measurementType == 'peso' || widget.measurementType == 'gordura_corporal')
                        ? (value < prevValue ? AppColors.success : AppColors.error)
                        : (value > prevValue ? AppColors.success : AppColors.error),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMeasurementSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nova Medição - $_title',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Valor ($_unit)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final value = double.tryParse(controller.text);
                  if (value == null) return;
                  try {
                    final api = context.read<AuthService>().api;
                    await api.addMeasurement({
                      'type': widget.measurementType,
                      'value': value,
                      'date': DateTime.now().toIso8601String(),
                    });
                  } catch (_) {}
                  if (mounted) {
                    Navigator.pop(ctx);
                    _loadHistory();
                  }
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

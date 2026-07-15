import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CalorieChartPage extends StatefulWidget {
  const CalorieChartPage({super.key});

  @override
  State<CalorieChartPage> createState() => _CalorieChartPageState();
}

class _CalorieChartPageState extends State<CalorieChartPage> {
  bool _isWeekly = true;
  bool _isLoading = true;

  final int _tdee = 2500;
  final List<Map<String, dynamic>> _dailyData = [];
  final List<Map<String, dynamic>> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _setupMockData();
    setState(() => _isLoading = false);
  }

  void _setupMockData() {
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      _dailyData.add({
        'label': DateFormat('EEE', 'pt_BR').format(d).substring(0, 3),
        'consumed': 1800 + (i * 50) + (i % 3 * 100),
        'burned': 2100 + (i * 30) - (i % 2 * 50),
        'calories': 2000 + (i * 40),
      });
    }
    for (int i = 3; i >= 0; i--) {
      final m = now.subtract(Duration(days: now.weekday - 1)).subtract(Duration(days: 7 * i));
      final start = m;
      final end = m.add(const Duration(days: 6));
      _weeklyData.add({
        'label': '${start.day}/${start.month}',
        'consumed': 13000 + (i * 500) + (i * 200),
        'burned': 14700 + (i * 300),
        'avgCalories': 1900 + (i * 80),
      });
    }
  }

  List<Map<String, dynamic>> get _currentData => _isWeekly ? _weeklyData : _dailyData;

  int get _avgConsumed {
    if (_currentData.isEmpty) return 0;
    return (_currentData.fold<int>(0, (s, d) => s + (d['consumed'] as int)) / _currentData.length).round();
  }

  int get _avgBurned {
    if (_currentData.isEmpty) return 0;
    return (_currentData.fold<int>(0, (s, d) => s + (d['burned'] as int)) / _currentData.length).round();
  }

  int get _deficit => _avgConsumed - _avgBurned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos de Calorias'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTdeeDisplay(),
                  const SizedBox(height: 20),
                  _buildToggle(),
                  const SizedBox(height: 16),
                  _buildLineChart(),
                  const SizedBox(height: 20),
                  _buildDeficitIndicator(),
                  const SizedBox(height: 24),
                  _buildPieChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildTdeeDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.2), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_fire_department, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TDEE - Gasto Energético Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 4),
              Text('$_tdee kcal/dia', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
              Text('Baseado no seu nível de atividade', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isWeekly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isWeekly ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('Diário', style: TextStyle(
                    color: !_isWeekly ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isWeekly = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isWeekly ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text('Semanal', style: TextStyle(
                    color: _isWeekly ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final maxY = _currentData.fold<double>(0, (max, d) => [max, (d['consumed'] as num).toDouble(), (d['burned'] as num).toDouble()].reduce((a, b) => a > b ? a : b));
    final paddedMax = (maxY * 1.2).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_isWeekly ? 'Média Calórica Semanal' : 'Calorias Diárias'}', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildLegendDot(AppColors.success, 'Consumido'),
              const SizedBox(width: 16),
              _buildLegendDot(AppColors.error, 'Queimado'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (_currentData.length - 1).toDouble(),
                minY: 0,
                maxY: paddedMax,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final label = spot.barIndex == 0 ? 'Consumido' : 'Queimado';
                        return LineTooltipItem(
                          '$label\n${spot.y.toInt()} kcal',
                          TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text('${value.toInt()}', style: TextStyle(color: AppColors.textMuted, fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _currentData.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(_currentData[idx]['label'], style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.surfaceLight,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _currentData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['consumed'] as num).toDouble())).toList(),
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 3,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: AppColors.success, strokeWidth: 0)),
                    belowBarData: BarAreaData(show: true, color: AppColors.success.withValues(alpha: 0.1)),
                  ),
                  LineChartBarData(
                    spots: _currentData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['burned'] as num).toDouble())).toList(),
                    isCurved: true,
                    color: AppColors.error,
                    barWidth: 3,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: AppColors.error, strokeWidth: 0)),
                    belowBarData: BarAreaData(show: true, color: AppColors.error.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildDeficitIndicator() {
    final isDeficit = _deficit < 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDeficit ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDeficit ? AppColors.success.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDeficit ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDeficit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDeficit ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDeficit ? 'Déficit Calórico' : 'Superávit Calórico',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Média de ${_deficit.abs()} kcal/dia',
                  style: TextStyle(color: isDeficit ? AppColors.success : AppColors.warning, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          Icon(isDeficit ? Icons.check_circle : Icons.info, color: isDeficit ? AppColors.success : AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final protein = 120;
    final carbs = 200;
    final fat = 55;
    final total = protein + carbs + fat;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribuição de Macros', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          value: protein.toDouble(),
                          title: '${(protein / total * 100).round()}%',
                          color: AppColors.secondary,
                          radius: 30,
                          titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        PieChartSectionData(
                          value: carbs.toDouble(),
                          title: '${(carbs / total * 100).round()}%',
                          color: AppColors.primary,
                          radius: 30,
                          titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        PieChartSectionData(
                          value: fat.toDouble(),
                          title: '${(fat / total * 100).round()}%',
                          color: AppColors.warning,
                          radius: 30,
                          titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPieLegend(AppColors.secondary, 'Proteínas', '${protein}g'),
                    const SizedBox(height: 12),
                    _buildPieLegend(AppColors.primary, 'Carboidratos', '${carbs}g'),
                    const SizedBox(height: 12),
                    _buildPieLegend(AppColors.warning, 'Gorduras', '${fat}g'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieLegend(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 8),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

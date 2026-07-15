import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WaterHistoryPage extends StatefulWidget {
  const WaterHistoryPage({super.key});

  @override
  State<WaterHistoryPage> createState() => _WaterHistoryPageState();
}

class _WaterHistoryPageState extends State<WaterHistoryPage> {
  int _currentGlasses = 6;
  final int _targetGlasses = 8;
  final int _mlPerGlass = 250;

  List<Map<String, dynamic>> _weeklyData = [];
  List<Map<String, dynamic>> _logEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      api.getNutritionGoals().then((response) {
        if (mounted) {
          setState(() {
            _currentGlasses = response.data['waterGlasses'] ?? 6;
            _isLoading = false;
          });
        }
      });
    } catch (_) {
      _setupMockData();
    }
  }

  void _setupMockData() {
    final now = DateTime.now();
    _weeklyData = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return {
        'day': DateFormat('EEE', 'pt_BR').format(d).substring(0, 3),
        'glasses': (4 + (i * 0.7)).round().clamp(0, 12),
        'ml': ((4 + (i * 0.7)).round() * _mlPerGlass).clamp(0, 12 * _mlPerGlass),
      };
    });

    _logEntries = List.generate(10, (i) {
      final t = DateTime(now.year, now.month, now.day, 7 + (i ~/ 2), (i % 2) * 30);
      return {
        'time': DateFormat('HH:mm').format(t),
        'ml': i % 2 == 0 ? 250 : 500,
        'note': i % 3 == 0 ? 'Pós-treino' : (i % 3 == 1 ? 'Café da manhã' : ''),
      };
    });

    setState(() => _isLoading = false);
  }

  int get _totalMl => _currentGlasses * _mlPerGlass;
  int get _targetMl => _targetGlasses * _mlPerGlass;
  double get _progress => _currentGlasses / _targetGlasses;

  int get _averageDaily {
    if (_weeklyData.isEmpty) return 0;
    final total = _weeklyData.fold<int>(0, (sum, d) => sum + (d['glasses'] as int));
    return (total / _weeklyData.length).round() * _mlPerGlass;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Água'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProgressRing(),
                  const SizedBox(height: 20),
                  _buildQuickAdd(),
                  const SizedBox(height: 20),
                  _buildWeeklyChart(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildLogList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressRing() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.info.withValues(alpha: 0.15), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Meta Diária', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('$_currentGlasses / $_targetGlasses copos', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: _progress.clamp(0.0, 1.0),
                    strokeWidth: 14,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progress >= 1.0 ? AppColors.success : AppColors.info,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _progress >= 1.0 ? Icons.check_circle : Icons.water_drop,
                      color: _progress >= 1.0 ? AppColors.success : AppColors.info,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text('$_totalMl', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('ml', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          if (_progress >= 1.0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  Text('Meta atingida!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAdd() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adicionar Rápido', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAddButton(
                  '250ml',
                  Icons.water_drop,
                  AppColors.info,
                  () => _addWater(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAddButton(
                  '500ml',
                  Icons.water_drop,
                  AppColors.primary,
                  () => _addWater(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text('+$label', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _addWater(int glasses) {
    setState(() {
      _currentGlasses = (_currentGlasses + glasses).clamp(0, 20);
      _logEntries.insert(0, {
        'time': DateFormat('HH:mm').format(DateTime.now()),
        'ml': glasses * _mlPerGlass,
        'note': '',
      });
      if (_logEntries.length > 50) _logEntries.removeLast();
    });

    try {
      final api = context.read<AuthService>().api;
      api.updateNutritionGoals({'waterGlasses': _currentGlasses});
    } catch (_) {}
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Consumo Semanal', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Meta diária: $_targetMl ml', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 12,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()} copos',
                        TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text('${value.toInt()}', style: TextStyle(color: AppColors.textMuted, fontSize: 10));
                      },
                      interval: 4,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _weeklyData.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _weeklyData[idx]['day'],
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.surfaceLight,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_weeklyData.length, (i) {
                  final isToday = i == _weeklyData.length - 1;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: (_weeklyData[i]['glasses'] as int).toDouble(),
                        color: isToday ? AppColors.info : AppColors.info.withValues(alpha: 0.5),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Média Diária', '${_averageDaily}ml', Icons.trending_up, AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Total Semana', '${_weeklyData.fold<int>(0, (s, d) => s + (d['ml'] as int))}ml', Icons.summarize, AppColors.primary)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Registros', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => setState(() => _logEntries.clear()),
              child: const Text('Limpar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_logEntries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Nenhum registro hoje', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
          )
        else
          ..._logEntries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.water_drop, color: AppColors.info, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry['ml']}ml', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      if ((entry['note'] ?? '').isNotEmpty)
                        Text(entry['note'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Text(entry['time'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          )),
      ],
    );
  }
}

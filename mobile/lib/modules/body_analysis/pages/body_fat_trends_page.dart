import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class BodyFatTrendsPage extends StatefulWidget {
  const BodyFatTrendsPage({super.key});

  @override
  State<BodyFatTrendsPage> createState() => _BodyFatTrendsPageState();
}

class _BodyFatTrendsPageState extends State<BodyFatTrendsPage> {
  Map<String, dynamic>? _trendsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  Future<void> _loadTrends() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/body-analysis/body-fat-trends');
      if (mounted) setState(() { _trendsData = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _trendsData = {
            'currentBodyFat': 18.5,
            'goalBodyFat': 15.0,
            'measurements': [
              {'date': '2025-01-15', 'value': 22.0},
              {'date': '2025-02-15', 'value': 21.0},
              {'date': '2025-03-15', 'value': 20.2},
              {'date': '2025-04-15', 'value': 19.5},
              {'date': '2025-05-15', 'value': 19.0},
              {'date': '2025-06-15', 'value': 18.5},
            ],
            'zones': [
              {'name': 'Atletismo', 'range': '6-13%', 'color': '#2196F3'},
              {'name': 'Fitness', 'range': '14-17%', 'color': '#4CAF50'},
              {'name': 'Aceitável', 'range': '18-24%', 'color': '#FFC107'},
              {'name': 'Obesidade', 'range': '25%+', 'color': '#F44336'},
            ],
            'measurementDates': [
              '2025-01-15',
              '2025-02-15',
              '2025-03-15',
              '2025-04-15',
              '2025-05-15',
              '2025-06-15',
            ],
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tendências de Gordura Corporal')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentBF = _trendsData!['currentBodyFat'] ?? 0;
    final goalBF = _trendsData!['goalBodyFat'] ?? 0;
    final measurements = List<Map<String, dynamic>>.from(_trendsData!['measurements'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tendências de Gordura Corporal'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTrends,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentStatus(currentBF, goalBF),
              const SizedBox(height: 20),
              _buildTrendChart(measurements, goalBF),
              const SizedBox(height: 20),
              _buildZonesSection(),
              const SizedBox(height: 20),
              _buildGoalComparison(currentBF, goalBF),
              const SizedBox(height: 20),
              _buildMeasurementDatesList(measurements),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(double currentBF, double goalBF) {
    final zone = _getZoneName(currentBF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '${currentBF.toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Gordura Corporal Atual',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              zone,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<Map<String, dynamic>> measurements, double goalBF) {
    if (measurements.isEmpty) return const SizedBox.shrink();

    final values = measurements.map((m) => (m['value'] as num).toDouble()).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolução', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: Size.infinite,
                painter: _BodyFatChartPainter(
                  values: values,
                  minVal: range > 0 ? minVal - range * 0.1 : minVal - 1,
                  maxVal: range > 0 ? maxVal + range * 0.1 : maxVal + 1,
                  goalValue: goalBF,
                  lineColor: AppColors.primary,
                  fillColor: AppColors.primary.withValues(alpha: 0.1),
                  goalColor: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${measurements.first['date']}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
                Text(
                  '${measurements.last['date']}',
                  style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(width: 12, height: 2, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Atual', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(width: 12),
                Container(width: 12, height: 2, color: AppColors.success),
                const SizedBox(width: 4),
                Text('Meta', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonesSection() {
    final zones = List<Map<String, dynamic>>.from(_trendsData!['zones'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zonas de Gordura Corporal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...zones.map((zone) {
              final color = _parseColor(zone['color'] ?? '#999999');
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(zone['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    ),
                    Text(zone['range'] ?? '', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalComparison(double currentBF, double goalBF) {
    final diff = currentBF - goalBF;
    final progress = diff > 0 ? 1 - (diff / (currentBF * 0.5)) : 1.0;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text('Comparação com Meta', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('Atual', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Text(
                      '${currentBF.toStringAsFixed(1)}%',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward, color: AppColors.textMuted),
                Column(
                  children: [
                    Text('Meta', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Text(
                      '${goalBF.toStringAsFixed(1)}%',
                      style: TextStyle(color: AppColors.success, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: clampedProgress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  diff > 0 ? AppColors.warning : AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              diff > 0
                  ? 'Faltam ${diff.toStringAsFixed(1)}% para atingir sua meta'
                  : 'Parabéns! Você atingiu sua meta!',
              style: TextStyle(
                color: diff > 0 ? AppColors.warning : AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementDatesList(List<Map<String, dynamic>> measurements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datas de Medição',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...measurements.reversed.map((m) {
          final date = DateTime.tryParse(m['date'] ?? '');
          final dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : m['date'];

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(dateStr, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ),
                Text(
                  '${(m['value'] as num?)?.toStringAsFixed(1) ?? '0.0'}%',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getZoneName(double bf) {
    if (bf <= 13) return 'Atletismo';
    if (bf <= 17) return 'Fitness';
    if (bf <= 24) return 'Aceitável';
    return 'Obesidade';
  }

  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class _BodyFatChartPainter extends CustomPainter {
  final List<double> values;
  final double minVal;
  final double maxVal;
  final double goalValue;
  final Color lineColor;
  final Color fillColor;
  final Color goalColor;

  _BodyFatChartPainter({
    required this.values,
    required this.minVal,
    required this.maxVal,
    required this.goalValue,
    required this.lineColor,
    required this.fillColor,
    required this.goalColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final goalPaint = Paint()
      ..color = goalColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final goalY = size.height - ((goalValue - minVal) / (maxVal - minVal)) * size.height;
    canvas.drawLine(Offset(0, goalY), Offset(size.width, goalY), goalPaint);

    final dashPaint = Paint()
      ..color = goalColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, goalY - 2), Offset(x + 4, goalY - 2), dashPaint);
    }

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minVal) / (maxVal - minVal)) * size.height;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, size.height);
    for (final p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paint);

    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = lineColor);
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

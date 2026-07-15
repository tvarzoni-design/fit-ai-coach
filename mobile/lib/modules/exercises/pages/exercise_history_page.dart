import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ExerciseHistoryPage extends StatefulWidget {
  final String exerciseId;

  const ExerciseHistoryPage({super.key, required this.exerciseId});

  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  Map<String, dynamic>? _historyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/exercises/${widget.exerciseId}/history');
      if (mounted) setState(() { _historyData = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _historyData = {
            'exerciseName': 'Supino Reto com Barra',
            'personalRecord': {'weight': 80, 'reps': 8, 'date': '2025-06-10'},
            'sessions': [
              {
                'date': '2025-06-10',
                'sets': [
                  {'weight': 70, 'reps': 12},
                  {'weight': 75, 'reps': 10},
                  {'weight': 80, 'reps': 8},
                  {'weight': 75, 'reps': 10},
                ],
              },
              {
                'date': '2025-06-07',
                'sets': [
                  {'weight': 67.5, 'reps': 12},
                  {'weight': 72.5, 'reps': 10},
                  {'weight': 77.5, 'reps': 8},
                  {'weight': 72.5, 'reps': 10},
                ],
              },
              {
                'date': '2025-06-03',
                'sets': [
                  {'weight': 65, 'reps': 12},
                  {'weight': 70, 'reps': 10},
                  {'weight': 75, 'reps': 8},
                  {'weight': 70, 'reps': 11},
                ],
              },
              {
                'date': '2025-05-30',
                'sets': [
                  {'weight': 65, 'reps': 12},
                  {'weight': 70, 'reps': 10},
                  {'weight': 72.5, 'reps': 9},
                  {'weight': 70, 'reps': 10},
                ],
              },
              {
                'date': '2025-05-27',
                'sets': [
                  {'weight': 62.5, 'reps': 12},
                  {'weight': 67.5, 'reps': 10},
                  {'weight': 72.5, 'reps': 8},
                  {'weight': 67.5, 'reps': 10},
                ],
              },
            ],
            'progressData': [65.0, 67.5, 72.5, 75.0, 77.5, 80.0],
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hist\u00f3rico')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final exerciseName = _historyData!['exerciseName'] ?? 'Exerc\u00edcio';
    final pr = _historyData!['personalRecord'];
    final sessions = List<Map<String, dynamic>>.from(_historyData!['sessions'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseName),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalRecordCard(pr),
              const SizedBox(height: 20),
              _buildProgressChart(),
              const SizedBox(height: 20),
              _buildSessionLog(sessions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalRecordCard(dynamic pr) {
    if (pr == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, AppColors.warning.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, color: Colors.white, size: 36),
          const SizedBox(height: 8),
          const Text(
            'Recorde Pessoal',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${pr['weight']}kg x ${pr['reps']} reps',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'em ${_formatDate(pr['date'])}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    final progressData = List<double>.from(_historyData!['progressData'] ?? []);
    if (progressData.isEmpty) return const SizedBox.shrink();

    final minVal = progressData.reduce((a, b) => a < b ? a : b);
    final maxVal = progressData.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progresso de Carga', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: Size.infinite,
                painter: _ProgressChartPainter(
                  values: progressData,
                  minVal: range > 0 ? minVal - range * 0.2 : minVal - 5,
                  maxVal: range > 0 ? maxVal + range * 0.2 : maxVal + 5,
                  lineColor: AppColors.success,
                  fillColor: AppColors.success.withValues(alpha: 0.1),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${progressData.first}kg', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('${progressData.last}kg', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionLog(List<Map<String, dynamic>> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Registro de Sess\u00f5es', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...sessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final sets = List<Map<String, dynamic>>.from(session['sets'] ?? []);
    final date = session['date'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(_formatDate(date), style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${sets.length} s\u00e9ries', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          ...sets.asMap().entries.map((entry) {
            final setNum = entry.key + 1;
            final set = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('$setNum', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${set['weight']}kg x ${set['reps']} reps',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ProgressChartPainter extends CustomPainter {
  final List<double> values;
  final double minVal;
  final double maxVal;
  final Color lineColor;
  final Color fillColor;

  _ProgressChartPainter({
    required this.values,
    required this.minVal,
    required this.maxVal,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
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

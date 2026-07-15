import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CardioGoalsPage extends StatefulWidget {
  const CardioGoalsPage({super.key});

  @override
  State<CardioGoalsPage> createState() => _CardioGoalsPageState();
}

class _CardioGoalsPageState extends State<CardioGoalsPage> {
  bool _isLoading = true;
  Map<String, dynamic> _goals = {};
  Map<String, dynamic> _progress = {};

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final api = context.read<AuthService>().api;
      final goalsResp = await api.dio.get('/cardio/goals');
      final progressResp = await api.dio.get('/cardio/progress');
      if (mounted) {
        setState(() {
          _goals = goalsResp.data ?? {};
          _progress = progressResp.data ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _goals = _getMockGoals();
          _progress = _getMockProgress();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getMockGoals() {
    return {
      'weeklyDistance': 15.0,
      'weeklyCalories': 2000,
      'sessionFrequency': 4,
      'weeklyDuration': 180,
    };
  }

  Map<String, dynamic> _getMockProgress() {
    return {
      'weeklyDistance': 11.5,
      'weeklyCalories': 1450,
      'sessionCount': 3,
      'weeklyDuration': 145,
    };
  }

  void _showEditGoalsModal() {
    final distanceCtrl = TextEditingController(text: '${_goals['weeklyDistance'] ?? 15}');
    final caloriesCtrl = TextEditingController(text: '${_goals['weeklyCalories'] ?? 2000}');
    final frequencyCtrl = TextEditingController(text: '${_goals['sessionFrequency'] ?? 4}');
    final durationCtrl = TextEditingController(text: '${_goals['weeklyDuration'] ?? 180}');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Editar Metas de Cardio', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: distanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Distância Semanal (km)'),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calorias Semanais (kcal)'),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: frequencyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Frequência (sessões/semana)'),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duração Semanal (min)'),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _goals['weeklyDistance'] = double.tryParse(distanceCtrl.text) ?? _goals['weeklyDistance'];
                    _goals['weeklyCalories'] = int.tryParse(caloriesCtrl.text) ?? _goals['weeklyCalories'];
                    _goals['sessionFrequency'] = int.tryParse(frequencyCtrl.text) ?? _goals['sessionFrequency'];
                    _goals['weeklyDuration'] = int.tryParse(durationCtrl.text) ?? _goals['weeklyDuration'];
                  });
                  Navigator.pop(context);
                },
                child: const Text('Salvar Metas'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Metas de Cardio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _showEditGoalsModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGoals,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProgressRings(),
                    const SizedBox(height: 20),
                    _buildGoalDetails(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProgressRings() {
    final distancePct = ((_progress['weeklyDistance'] ?? 0) / (_goals['weeklyDistance'] ?? 1)).clamp(0.0, 1.0);
    final caloriesPct = ((_progress['weeklyCalories'] ?? 0) / (_goals['weeklyCalories'] ?? 1)).clamp(0.0, 1.0);
    final frequencyPct = ((_progress['sessionCount'] ?? 0) / (_goals['sessionFrequency'] ?? 1)).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Progresso Semanal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              width: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildRing(220, 12, distancePct, AppColors.primary, Alignment.center),
                  _buildRing(170, 12, caloriesPct, AppColors.warning, Alignment.center),
                  _buildRing(120, 12, frequencyPct, AppColors.success, Alignment.center),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${((distancePct + caloriesPct + frequencyPct) / 3 * 100).round()}%',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        Text('Geral', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRingLegend('Distância', '${(_progress['weeklyDistance'] ?? 0).toStringAsFixed(1)}', 'km', AppColors.primary, distancePct),
                _buildRingLegend('Calorias', '${_progress['weeklyCalories'] ?? 0}', 'kcal', AppColors.warning, caloriesPct),
                _buildRingLegend('Sessões', '${_progress['sessionCount'] ?? 0}', 'vezes', AppColors.success, frequencyPct),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRing(double size, double strokeWidth, double pct, Color color, Alignment alignment) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: pct,
          color: color,
          strokeWidth: strokeWidth,
          backgroundColor: AppColors.surfaceLight,
        ),
      ),
    );
  }

  Widget _buildRingLegend(String label, String value, String unit, Color color, double pct) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              TextSpan(text: ' $unit', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
        Text('${(pct * 100).round()}%', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildGoalDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalhes das Metas', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 16),
            _buildGoalDetailRow(
              Icons.straighten,
              'Distância Semanal',
              '${(_progress['weeklyDistance'] ?? 0).toStringAsFixed(1)} / ${_goals['weeklyDistance'] ?? 15} km',
              ((_progress['weeklyDistance'] ?? 0) / (_goals['weeklyDistance'] ?? 1)).clamp(0.0, 1.0),
              AppColors.primary,
            ),
            const SizedBox(height: 14),
            _buildGoalDetailRow(
              Icons.local_fire_department,
              'Calorias Semanais',
              '${_progress['weeklyCalories'] ?? 0} / ${_goals['weeklyCalories'] ?? 2000} kcal',
              ((_progress['weeklyCalories'] ?? 0) / (_goals['weeklyCalories'] ?? 1)).clamp(0.0, 1.0),
              AppColors.warning,
            ),
            const SizedBox(height: 14),
            _buildGoalDetailRow(
              Icons.repeat,
              'Frequência',
              '${_progress['sessionCount'] ?? 0} / ${_goals['sessionFrequency'] ?? 4} sessões',
              ((_progress['sessionCount'] ?? 0) / (_goals['sessionFrequency'] ?? 1)).clamp(0.0, 1.0),
              AppColors.success,
            ),
            const SizedBox(height: 14),
            _buildGoalDetailRow(
              Icons.timer,
              'Duração Semanal',
              '${_progress['weeklyDuration'] ?? 0} / ${_goals['weeklyDuration'] ?? 180} min',
              ((_progress['weeklyDuration'] ?? 0) / (_goals['weeklyDuration'] ?? 1)).clamp(0.0, 1.0),
              AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalDetailRow(IconData icon, String label, String value, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159265 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

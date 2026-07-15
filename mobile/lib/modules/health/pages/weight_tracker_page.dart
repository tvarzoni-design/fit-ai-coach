import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WeightTrackerPage extends StatefulWidget {
  const WeightTrackerPage({super.key});

  @override
  State<WeightTrackerPage> createState() => _WeightTrackerPageState();
}

class _WeightTrackerPageState extends State<WeightTrackerPage> {
  double _currentWeight = 78.5;
  double _goalWeight = 75.0;
  double _startWeight = 82.0;
  List<Map<String, dynamic>> _history = [];
  List<double> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/health/weight');
      if (mounted) {
        setState(() {
          _currentWeight = (response.data['currentWeight'] ?? 78.5).toDouble();
          _goalWeight = (response.data['goalWeight'] ?? 75.0).toDouble();
          _startWeight = (response.data['startWeight'] ?? 82.0).toDouble();
          _history = List<Map<String, dynamic>>.from(response.data['history'] ?? []);
          _chartData = List<double>.from((response.data['chartData'] ?? []).map((e) => (e as num).toDouble()));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _chartData = [82.0, 81.5, 81.0, 80.2, 79.8, 79.5, 79.0, 78.5];
          _history = [
            {'date': '14/07/2026', 'weight': 78.5},
            {'date': '07/07/2026', 'weight': 79.0},
            {'date': '30/06/2026', 'weight': 79.5},
            {'date': '23/06/2026', 'weight': 79.8},
            {'date': '16/06/2026', 'weight': 80.2},
          ];
          _isLoading = false;
        });
      }
    }
  }

  void _addWeight() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Registrar Peso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso (kg)'), autofocus: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final w = double.tryParse(controller.text);
                  if (w != null && w > 0) {
                    setState(() {
                      _currentWeight = w;
                      _chartData.add(w);
                      _history.insert(0, {'date': '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}', 'weight': w});
                    });
                    Navigator.pop(ctx);
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

  double _bmi() => _currentWeight / pow(1.75, 2);

  String _bmiLabel() {
    final b = _bmi();
    if (b < 18.5) return 'Abaixo do peso';
    if (b < 25) return 'Peso normal';
    if (b < 30) return 'Sobrepeso';
    return 'Obesidade';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peso'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addWeight),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentWeight(),
                    const SizedBox(height: 16),
                    _buildChart(),
                    const SizedBox(height: 16),
                    _buildBmiCard(),
                    const SizedBox(height: 16),
                    _buildHistory(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentWeight() {
    final change = _chartData.length >= 2 ? _chartData.last - _chartData[_chartData.length - 2] : 0.0;
    final isDown = change < 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peso Atual', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${_currentWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(isDown ? Icons.arrow_downward : Icons.arrow_upward, color: isDown ? AppColors.success : AppColors.error, size: 16),
                    Text('${change.abs().toStringAsFixed(1)} kg', style: TextStyle(color: isDown ? AppColors.success : AppColors.error, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                Text('Meta', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text('${_goalWeight.toStringAsFixed(1)} kg', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_chartData.isEmpty) return const SizedBox();
    final minVal = _chartData.reduce(min);
    final maxVal = _chartData.reduce(max);
    final range = (maxVal - minVal).clamp(0.5, double.infinity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Evolução', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _WeightChartPainter(
                  data: _chartData,
                  minVal: minVal - 1,
                  range: range + 2,
                  goalWeight: _goalWeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiCard() {
    final bmi = _bmi();
    final color = bmi < 25 ? AppColors.success : AppColors.warning;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(bmi.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        title: const Text('IMC'),
        subtitle: Text(_bmiLabel()),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(bmi.toStringAsFixed(1), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Histórico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._history.map((h) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.monitor_weight, color: AppColors.textMuted),
                title: Text('${(h['weight'] as double).toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: Text(h['date'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            )),
      ],
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> data;
  final double minVal;
  final double range;
  final double goalWeight;

  _WeightChartPainter({required this.data, required this.minVal, required this.range, required this.goalWeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final paint = Paint()..color = AppColors.primary..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final goalPaint = Paint()..color = AppColors.secondary..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final dotPaint = Paint()..color = AppColors.primary;
    final path = Path();
    final dx = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    canvas.drawPath(path, paint);

    final goalY = size.height - ((goalWeight - minVal) / range) * size.height;
    final goalPath = Path()..moveTo(0, goalY)..lineTo(size.width, goalY);
    canvas.drawPath(goalPath, goalPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

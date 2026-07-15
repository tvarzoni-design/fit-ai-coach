import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class StepsCounterPage extends StatefulWidget {
  const StepsCounterPage({super.key});

  @override
  State<StepsCounterPage> createState() => _StepsCounterPageState();
}

class _StepsCounterPageState extends State<StepsCounterPage> {
  int _currentSteps = 8542;
  int _dailyGoal = 10000;
  List<int> _weeklyData = [];
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
      final response = await api.dio.get('/health/steps');
      if (mounted) {
        setState(() {
          _currentSteps = response.data['today'] ?? 8542;
          _dailyGoal = response.data['goal'] ?? 10000;
          _weeklyData = List<int>.from(response.data['weekly'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weeklyData = [7200, 9100, 6800, 10200, 8542, 5300, 8542];
          _isLoading = false;
        });
      }
    }
  }

  double _progress() => (_currentSteps / _dailyGoal).clamp(0.0, 1.0);

  int _weeklyAvg() => _weeklyData.isEmpty ? 0 : (_weeklyData.reduce((a, b) => a + b) / _weeklyData.length).round();

  void _setGoal() {
    final controller = TextEditingController(text: '$_dailyGoal');
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
            const Text('Meta Diária de Passos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Meta')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final g = int.tryParse(controller.text);
                  if (g != null && g > 0) {
                    setState(() => _dailyGoal = g);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Salvar Meta'),
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
        title: const Text('Passos'),
        actions: [
          IconButton(icon: const Icon(Icons.flag_outlined), onPressed: _setGoal, tooltip: 'Definir meta'),
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
                  children: [
                    _buildCircularProgress(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(),
                    const SizedBox(height: 16),
                    _buildStepHistory(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCircularProgress() {
    final p = _progress();
    final pct = (p * 100).toInt();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: p,
                      strokeWidth: 16,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(p >= 1.0 ? AppColors.success : AppColors.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$_currentSteps', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                      Text('de $_dailyGoal passos', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('$pct%', style: TextStyle(color: p >= 1.0 ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            if (p >= 1.0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text('Meta atingida!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Meta', '$_dailyGoal', AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Média Semanal', '${_weeklyAvg()}', AppColors.info)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Restante', '${(_dailyGoal - _currentSteps).clamp(0, _dailyGoal)}', AppColors.warning)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final now = DateTime.now();
    final todayIdx = now.weekday - 1;
    final maxVal = _dailyGoal.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Média Semanal', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final val = i < _weeklyData.length ? _weeklyData[i].toDouble() : 0.0;
                  final barH = (val / maxVal) * 100;
                  final isToday = i == todayIdx;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${(val / 1000).toStringAsFixed(1)}k', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                          const SizedBox(height: 4),
                          Container(
                            height: barH.clamp(4.0, 100.0),
                            decoration: BoxDecoration(
                              color: isToday ? AppColors.primary : (val >= maxVal ? AppColors.success.withValues(alpha: 0.7) : AppColors.surfaceLight),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(days[i], style: TextStyle(color: isToday ? AppColors.primary : AppColors.textMuted, fontSize: 10, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHistory() {
    if (_weeklyData.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Histórico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._weeklyData.asMap().entries.map((e) {
          final day = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'][e.key];
          final met = e.value >= _dailyGoal;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(met ? Icons.check_circle : Icons.circle_outlined, color: met ? AppColors.success : AppColors.textMuted, size: 20),
              title: Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: Text('${e.value} passos', style: TextStyle(color: met ? AppColors.success : AppColors.textSecondary, fontSize: 13)),
            ),
          );
        }),
      ],
    );
  }
}

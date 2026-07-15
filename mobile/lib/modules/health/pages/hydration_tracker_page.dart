import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class HydrationTrackerPage extends StatefulWidget {
  const HydrationTrackerPage({super.key});

  @override
  State<HydrationTrackerPage> createState() => _HydrationTrackerPageState();
}

class _HydrationTrackerPageState extends State<HydrationTrackerPage> {
  int _currentIntake = 0;
  int _dailyGoal = 3000;
  List<Map<String, dynamic>> _todayLogs = [];
  List<double> _weeklyAverage = [];
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
      final response = await api.dio.get('/health/hydration');
      if (mounted) {
        final data = response.data;
        setState(() {
          _currentIntake = data['currentIntake'] ?? 0;
          _dailyGoal = data['dailyGoal'] ?? 3000;
          _todayLogs = List<Map<String, dynamic>>.from(data['logs'] ?? []);
          _weeklyAverage = List<double>.from((data['weeklyAverage'] ?? []).map((e) => (e as num).toDouble()));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentIntake = 1600;
          _dailyGoal = 3000;
          _todayLogs = [
            {'amount': 250, 'time': '07:30', 'type': 'Água'},
            {'amount': 300, 'time': '09:15', 'type': 'Água'},
            {'amount': 200, 'time': '11:00', 'type': 'Chá verde'},
            {'amount': 350, 'time': '12:30', 'type': 'Água'},
            {'amount': 250, 'time': '14:00', 'type': 'Água'},
            {'amount': 250, 'time': '16:00', 'type': 'Água'},
          ];
          _weeklyAverage = [2800, 2650, 3100, 2900, 2700, 2950, 1600];
          _isLoading = false;
        });
      }
    }
  }

  void _addWater(int amount) {
    setState(() {
      _currentIntake += amount;
      _todayLogs.add({
        'amount': amount,
        'time': '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
        'type': 'Água',
      });
    });
    _saveIntake(amount);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+${amount}ml registrado'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  Future<void> _saveIntake(int amount) async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/health/hydration', data: {'amount': amount});
    } catch (_) {}
  }

  void _showCustomAmountDialog() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Quantidade Personalizada', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade (ml)'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = int.tryParse(controller.text);
                  if (amount != null && amount > 0) {
                    Navigator.pop(context);
                    _addWater(amount);
                  }
                },
                child: const Text('Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalSetting() {
    final controller = TextEditingController(text: '$_dailyGoal');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Meta Diária de Água', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Meta (ml)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final goal = int.tryParse(controller.text);
                  if (goal != null && goal > 0) {
                    setState(() => _dailyGoal = goal);
                    Navigator.pop(context);
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
        title: const Text('Hidratação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: _showGoalSetting,
            tooltip: 'Definir meta',
          ),
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
                    _buildProgressRing(),
                    const SizedBox(height: 16),
                    _buildQuickAddButtons(),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(),
                    const SizedBox(height: 16),
                    _buildTodayLogs(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProgressRing() {
    final progress = (_currentIntake / _dailyGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    final remaining = _dailyGoal - _currentIntake;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? AppColors.success : AppColors.info,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: progress >= 1.0 ? AppColors.success : AppColors.info,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_currentIntake ml',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$percentage% da meta',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRingStat('Meta', '${_dailyGoal}ml', AppColors.info),
                _buildRingStat(
                  'Restante',
                  '${remaining > 0 ? remaining : 0}ml',
                  remaining > 0 ? AppColors.warning : AppColors.success,
                ),
                _buildRingStat('Copos', '${(_currentIntake / 250).floor()}', AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickAddButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adicionar Água', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildAddButton(200)),
                const SizedBox(width: 8),
                Expanded(child: _buildAddButton(300)),
                const SizedBox(width: 8),
                Expanded(child: _buildAddButton(500)),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _showCustomAmountDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add, color: AppColors.textSecondary, size: 24),
                          const SizedBox(height: 4),
                          Text('Personalizar', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(int amount) {
    return GestureDetector(
      onTap: () => _addWater(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.water_drop, color: AppColors.info, size: 24),
            const SizedBox(height: 4),
            Text('+${amount}ml', style: TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Média Semanal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = index < _weeklyAverage.length ? _weeklyAverage[index] : 0.0;
                  final maxVal = 4000.0;
                  final barHeight = (value / maxVal) * 100;
                  final isToday = index == todayIndex;
                  final hitGoal = value >= _dailyGoal;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${(value / 1000).toStringAsFixed(1)}L',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 9),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: barHeight.clamp(4.0, 100.0),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.info
                                  : hitGoal
                                      ? AppColors.success.withValues(alpha: 0.7)
                                      : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            days[index],
                            style: TextStyle(
                              color: isToday ? AppColors.info : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
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

  Widget _buildTodayLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Registros de Hoje', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_todayLogs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('Nenhum registro ainda', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
          )
        else
          ..._todayLogs.reversed.map((log) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.water_drop, color: AppColors.info, size: 20),
                  ),
                  title: Text('${log['amount']}ml', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(log['type'] ?? 'Água', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: Text(log['time'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
              )),
      ],
    );
  }
}

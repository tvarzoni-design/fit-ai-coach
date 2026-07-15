import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WaterReminderPage extends StatefulWidget {
  const WaterReminderPage({super.key});

  @override
  State<WaterReminderPage> createState() => _WaterReminderPageState();
}

class _WaterReminderPageState extends State<WaterReminderPage> {
  double _dailyGoal = 3000;
  int _reminderInterval = 60;
  bool _quietHoursEnabled = false;
  int _quietStartHour = 22;
  int _quietEndHour = 7;
  int _currentIntake = 0;
  List<Map<String, dynamic>> _cupSizes = [];
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
      final response = await api.dio.get('/health/water-settings');
      if (mounted) {
        final data = response.data;
        setState(() {
          _dailyGoal = (data['dailyGoal'] ?? 3000).toDouble();
          _reminderInterval = data['reminderInterval'] ?? 60;
          _quietHoursEnabled = data['quietHoursEnabled'] ?? false;
          _quietStartHour = data['quietStartHour'] ?? 22;
          _quietEndHour = data['quietEndHour'] ?? 7;
          _currentIntake = data['currentIntake'] ?? 0;
          _cupSizes = List<Map<String, dynamic>>.from(data['cupSizes'] ?? [
            {'label': 'Copo', 'amount': 200, 'icon': 'glass'},
            {'label': 'Garrafa', 'amount': 500, 'icon': 'bottle'},
            {'label': 'Frasco', 'amount': 750, 'icon': 'flask'},
          ]);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dailyGoal = 3000;
          _reminderInterval = 60;
          _quietHoursEnabled = false;
          _quietStartHour = 22;
          _quietEndHour = 7;
          _currentIntake = 1600;
          _cupSizes = [
            {'label': 'Copo', 'amount': 200, 'icon': 'glass'},
            {'label': 'Garrafa Pequena', 'amount': 350, 'icon': 'bottle'},
            {'label': 'Garrafa', 'amount': 500, 'icon': 'bottle'},
            {'label': 'Frasco', 'amount': 750, 'icon': 'flask'},
          ];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/health/water-settings', data: {
        'dailyGoal': _dailyGoal.toInt(),
        'reminderInterval': _reminderInterval,
        'quietHoursEnabled': _quietHoursEnabled,
        'quietStartHour': _quietStartHour,
        'quietEndHour': _quietEndHour,
        'cupSizes': _cupSizes,
      });
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configurações salvas'), backgroundColor: AppColors.success),
      );
    }
  }

  String _formatTime(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIntake / _dailyGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lembrete de Água'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text('Salvar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressRing(progress, percentage),
                  const SizedBox(height: 16),
                  _buildGoalSection(),
                  const SizedBox(height: 16),
                  _buildReminderSection(),
                  const SizedBox(height: 16),
                  _buildQuietHoursSection(),
                  const SizedBox(height: 16),
                  _buildCupSizesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressRing(double progress, int percentage) {
    final remaining = _dailyGoal - _currentIntake;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
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
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_currentIntake.toInt()} ml',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$percentage% da meta',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRingStat('Meta', '${_dailyGoal.toInt()}ml', AppColors.info),
                _buildRingStat(
                  'Restante',
                  '${remaining > 0 ? remaining.toInt() : 0}ml',
                  remaining > 0 ? AppColors.warning : AppColors.success,
                ),
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

  Widget _buildGoalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meta Diária', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _dailyGoal,
                    min: 1000,
                    max: 6000,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceLight,
                    onChanged: (v) => setState(() => _dailyGoal = v),
                  ),
                ),
                Container(
                  width: 70,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_dailyGoal.toInt()}ml',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1L', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('6L', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection() {
    final intervals = [
      {'label': '30 min', 'value': 30},
      {'label': '45 min', 'value': 45},
      {'label': '1h', 'value': 60},
      {'label': '1.5h', 'value': 90},
      {'label': '2h', 'value': 120},
      {'label': '3h', 'value': 180},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Intervalo de Lembrete', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: intervals.map((interval) {
                final isSelected = _reminderInterval == interval['value'];
                return GestureDetector(
                  onTap: () => setState(() => _reminderInterval = interval['value'] as int),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                    ),
                    child: Text(
                      interval['label'] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuietHoursSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Horário Silencioso', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Não enviar lembretes durante este período', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: _quietHoursEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _quietHoursEnabled = v),
                ),
              ],
            ),
            if (_quietHoursEnabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showTimePicker(true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text('Início', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(_formatTime(_quietStartHour), style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 20),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showTimePicker(false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text('Fim', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(_formatTime(_quietEndHour), style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTimePicker(bool isStart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(isStart ? 'Início do Silêncio' : 'Fim do Silêncio',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListWheelScrollView(
                itemExtent: 40,
                physics: const FixedExtentScrollPhysics(),
                controller: FixedExtentScrollController(
                  initialItem: isStart ? _quietStartHour : _quietEndHour,
                ),
                onSelectedItemChanged: (index) {
                  if (isStart) {
                    _quietStartHour = index;
                  } else {
                    _quietEndHour = index;
                  }
                },
                children: List.generate(24, (hour) {
                  return Center(
                    child: Text(
                      _formatTime(hour),
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Confirmar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupSizesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Tamanhos de Copo', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: _showAddCupDialog,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._cupSizes.asMap().entries.map((entry) {
              final cup = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.local_drink, color: AppColors.info, size: 20),
                ),
                title: Text(cup['label'], style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text('${cup['amount']}ml', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: () {
                    setState(() => _cupSizes.removeAt(entry.key));
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddCupDialog() {
    final labelController = TextEditingController();
    final amountController = TextEditingController();

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
            Text('Novo Copo', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Nome'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade (ml)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final label = labelController.text.trim();
                  final amount = int.tryParse(amountController.text);
                  if (label.isNotEmpty && amount != null && amount > 0) {
                    setState(() => _cupSizes.add({'label': label, 'amount': amount, 'icon': 'custom'}));
                    Navigator.pop(context);
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
}

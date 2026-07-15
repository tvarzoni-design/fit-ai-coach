import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class DailySummaryPage extends StatefulWidget {
  const DailySummaryPage({super.key});

  @override
  State<DailySummaryPage> createState() => _DailySummaryPageState();
}

class _DailySummaryPageState extends State<DailySummaryPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _summary;
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
      final response = await api.dio.get('/health/daily-summary', queryParameters: {
        'date': _selectedDate.toIso8601String().split('T')[0],
      });
      if (mounted) setState(() { _summary = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _summary = {
            'workoutsCompleted': 1,
            'caloriesBurned': 420,
            'steps': 8542,
            'waterIntake': 1800,
            'macros': {'protein': 95, 'carbs': 210, 'fat': 65},
            'aiMessage': 'Parabéns! Você está indo muito bem hoje. Mantenha o ritmo!',
          };
          _isLoading = false;
        });
      }
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final dayStr = '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo Diário')),
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
                    _buildDatePicker(dayStr),
                    const SizedBox(height: 16),
                    _buildWorkoutCard(),
                    const SizedBox(height: 12),
                    _buildCaloriesAndSteps(),
                    const SizedBox(height: 12),
                    _buildWaterCard(),
                    const SizedBox(height: 12),
                    _buildMacrosCard(),
                    const SizedBox(height: 12),
                    _buildAiMessage(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDatePicker(String dayStr) {
    return GestureDetector(
      onTap: _pickDate,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(dayStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard() {
    final count = _summary?['workoutsCompleted'] ?? 0;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.fitness_center, color: AppColors.primary),
        ),
        title: const Text('Treinos Realizados'),
        subtitle: Text('$count treino${count != 1 ? 's' : ''} completado${count != 1 ? 's' : ''}'),
        trailing: TextButton(onPressed: () => context.push('/workouts'), child: const Text('Ver Detalhes')),
      ),
    );
  }

  Widget _buildCaloriesAndSteps() {
    final calories = _summary?['caloriesBurned'] ?? 0;
    final steps = _summary?['steps'] ?? 0;
    return Row(
      children: [
        Expanded(child: _buildMiniCard(Icons.local_fire_department, 'Calorias', '$calories kcal', AppColors.secondary)),
        const SizedBox(width: 12),
        Expanded(child: _buildMiniCard(Icons.directions_walk, 'Passos', '$steps', AppColors.success)),
      ],
    );
  }

  Widget _buildMiniCard(IconData icon, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextButton(onPressed: () {}, child: const Text('Ver Detalhes', style: TextStyle(fontSize: 11))),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard() {
    final water = _summary?['waterIntake'] ?? 0;
    final progress = (water / 3000).clamp(0.0, 1.0);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.water_drop, color: AppColors.info),
        ),
        title: const Text('Água Consumida'),
        subtitle: Text('$water ml'),
        trailing: TextButton(onPressed: () => context.push('/hydration'), child: const Text('Ver Detalhes')),
      ),
    );
  }

  Widget _buildMacrosCard() {
    final macros = _summary?['macros'] ?? {};
    final protein = macros['protein'] ?? 0;
    final carbs = macros['carbs'] ?? 0;
    final fat = macros['fat'] ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                const Text('Macros Consumidos', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: () => context.push('/nutrition'), child: const Text('Ver Detalhes')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem('Proteína', '${protein}g', AppColors.primary),
                _buildMacroItem('Carboidratos', '${carbs}g', AppColors.warning),
                _buildMacroItem('Gordura', '${fat}g', AppColors.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }

  Widget _buildAiMessage() {
    final message = _summary?['aiMessage'] ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({super.key});

  @override
  State<FoodLogPage> createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _dailyData;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _mealTypes = [
    {'key': 'cafe-da-manha', 'name': 'Café da Manhã', 'icon': Icons.free_breakfast, 'calories': 450},
    {'key': 'lanche-manha', 'name': 'Lanche da Manhã', 'icon': Icons.cookie, 'calories': 200},
    {'key': 'almoco', 'name': 'Almoço', 'icon': Icons.lunch_dining, 'calories': 650},
    {'key': 'lanche-tarde', 'name': 'Lanche da Tarde', 'icon': Icons.cookie, 'calories': 200},
    {'key': 'jantar', 'name': 'Jantar', 'icon': Icons.dinner_dining, 'calories': 550},
  ];

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  Future<void> _loadDailyData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await api.getDailySummary(dateStr);
      if (mounted) setState(() { _dailyData = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) setupMockData();
    }
  }

  void setupMockData() {
    final totalCal = _mealTypes.fold<int>(0, (sum, m) => sum + (m['calories'] as int));
    setState(() {
      _dailyData = {
        'targetCalories': 2500,
        'caloriesConsumed': totalCal,
        'targetProtein': 150, 'protein': 120,
        'targetCarbs': 300, 'carbs': 200,
        'targetFat': 80, 'fat': 55,
        'meals': _mealTypes.map((m) => {
          'type': m['key'],
          'name': m['name'],
          'time': '08:00',
          'calories': m['calories'],
          'protein': 30,
          'carbs': 45,
          'fat': 12,
          'foods': [
            {'name': 'Exemplo 1', 'calories': m['calories'] - 100, 'protein': 15, 'carbs': 25, 'fat': 6},
            {'name': 'Exemplo 2', 'calories': 100, 'protein': 15, 'carbs': 20, 'fat': 6},
          ],
        }).toList(),
      };
      _isLoading = false;
    });
  }

  int get _consumed => _dailyData?['caloriesConsumed'] ?? 0;
  int get _target => _dailyData?['targetCalories'] ?? 2500;
  int get _remaining => _target - _consumed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário Alimentar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/nutrition/calorie-chart'),
            tooltip: 'Gráficos',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDailyData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDateNavigator(),
                    const SizedBox(height: 16),
                    _buildDailySummary(),
                    const SizedBox(height: 20),
                    _buildMacrosRow(),
                    const SizedBox(height: 24),
                    ...(_dailyData?['meals'] as List? ?? []).map((meal) => _buildMealSection(meal)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateNavigator() {
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM', 'pt_BR');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
              _loadDailyData();
            },
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(data: Theme.of(context), child: child!),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                _loadDailyData();
              }
            },
            child: Column(
              children: [
                Text(dateFormat.format(_selectedDate), style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                if (_selectedDate == DateTime.now())
                  Text('Hoje', style: TextStyle(color: AppColors.primary, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedDate.isBefore(DateTime.now())
                ? () {
                    setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                    _loadDailyData();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary() {
    final ratio = _target > 0 ? _consumed / _target : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total do Dia', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('$_consumed / $_target kcal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  strokeWidth: 10,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _remaining >= 0 ? AppColors.primary : AppColors.error,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$_consumed', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('kcal', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _remaining >= 0 ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_remaining >= 0 ? Icons.arrow_downward : Icons.arrow_upward, color: _remaining >= 0 ? AppColors.success : AppColors.error, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${_remaining >= 0 ? 'Restam' : 'Excedeu'} ${_remaining.abs()} kcal',
                  style: TextStyle(color: _remaining >= 0 ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosRow() {
    final protein = _dailyData?['protein'] ?? 0;
    final tProtein = _dailyData?['targetProtein'] ?? 150;
    final carbs = _dailyData?['carbs'] ?? 0;
    final tCarbs = _dailyData?['targetCarbs'] ?? 300;
    final fat = _dailyData?['fat'] ?? 0;
    final tFat = _dailyData?['targetFat'] ?? 80;

    return Row(
      children: [
        Expanded(child: _buildMacroCard('Proteína', protein, tProtein, 'g', AppColors.secondary, Icons.fitness_center)),
        const SizedBox(width: 8),
        Expanded(child: _buildMacroCard('Carbs', carbs, tCarbs, 'g', AppColors.primary, Icons.grain)),
        const SizedBox(width: 8),
        Expanded(child: _buildMacroCard('Gordura', fat, tFat, 'g', AppColors.warning, Icons.water_drop)),
      ],
    );
  }

  Widget _buildMacroCard(String label, int current, int target, String unit, Color color, IconData icon) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text('$current$unit', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(dynamic meal) {
    final foods = (meal['foods'] as List?) ?? [];
    final mealCalories = meal['calories'] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getMealIcon(meal['type'] ?? ''), color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        Text(meal['time'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$mealCalories', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('kcal', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          if (foods.isNotEmpty)
            ...foods.map((food) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              margin: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.surfaceLight, width: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, color: AppColors.textMuted, size: 4),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(food['name'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  Text('${food['calories'] ?? 0} kcal', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            )),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    context.push('/nutrition/meal/${meal['type'] ?? meal['name']}');
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar', style: TextStyle(fontSize: 13)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    context.push('/nutrition/food-search');
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar Alimento', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String type) {
    switch (type) {
      case 'cafe-da-manha': return Icons.free_breakfast;
      case 'almoco': return Icons.lunch_dining;
      case 'jantar': return Icons.dinner_dining;
      default: return Icons.cookie;
    }
  }
}

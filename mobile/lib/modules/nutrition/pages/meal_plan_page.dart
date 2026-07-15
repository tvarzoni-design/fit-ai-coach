import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  Map<String, dynamic>? _mealPlan;
  bool _isLoading = true;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/nutrition/meal-plan');
      if (mounted) setState(() { _mealPlan = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _mealPlan = {
            'name': 'Plano Semanal',
            'weeklyPlan': [
              {
                'day': 'Segunda',
                'meals': [
                  {'type': 'Café da Manhã', 'time': '07:00', 'name': 'Aveia com Frutas', 'calories': 350, 'protein': 12, 'carbs': 55, 'fat': 8},
                  {'type': 'Almoço', 'time': '12:30', 'name': 'Frango com Arroz Integral', 'calories': 560, 'protein': 62, 'carbs': 48, 'fat': 9},
                  {'type': 'Lanche', 'time': '15:30', 'name': 'Whey com Banana', 'calories': 230, 'protein': 26, 'carbs': 31, 'fat': 1},
                  {'type': 'Jantar', 'time': '19:00', 'name': 'Salmão com Batata Doce', 'calories': 540, 'protein': 43, 'carbs': 40, 'fat': 22},
                ],
              },
              {
                'day': 'Terça',
                'meals': [
                  {'type': 'Café da Manhã', 'time': '07:00', 'name': 'Ovos Mexidos com Pão Integral', 'calories': 420, 'protein': 28, 'carbs': 38, 'fat': 16},
                  {'type': 'Almoço', 'time': '12:30', 'name': 'Peixe com Legumes', 'calories': 480, 'protein': 45, 'carbs': 35, 'fat': 18},
                  {'type': 'Lanche', 'time': '15:30', 'name': 'Iogurte Grego com Castanhas', 'calories': 310, 'protein': 25, 'carbs': 12, 'fat': 19},
                  {'type': 'Jantar', 'time': '19:00', 'name': 'Carne com Quinoa', 'calories': 520, 'protein': 40, 'carbs': 48, 'fat': 15},
                ],
              },
              {
                'day': 'Quarta',
                'meals': [
                  {'type': 'Café da Manhã', 'time': '07:00', 'name': 'Vitamina de Proteína', 'calories': 300, 'protein': 35, 'carbs': 28, 'fat': 5},
                  {'type': 'Almoço', 'time': '12:30', 'name': 'Frango com Macarrão', 'calories': 580, 'protein': 50, 'carbs': 60, 'fat': 12},
                  {'type': 'Lanche', 'time': '15:30', 'name': 'Shake de Fruta', 'calories': 220, 'protein': 20, 'carbs': 30, 'fat': 3},
                  {'type': 'Jantar', 'time': '19:00', 'name': 'Tofu com Arroz', 'calories': 440, 'protein': 30, 'carbs': 50, 'fat': 12},
                ],
              },
              {
                'day': 'Quinta',
                'meals': [
                  {'type': 'Café da Manhã', 'time': '07:00', 'name': 'Panquecas de Aveia', 'calories': 380, 'protein': 22, 'carbs': 42, 'fat': 12},
                  {'type': 'Almoço', 'time': '12:30', 'name': 'Lentilha com Arroz', 'calories': 510, 'protein': 35, 'carbs': 65, 'fat': 8},
                  {'type': 'Lanche', 'time': '15:30', 'name': 'Pão de Proteína', 'calories': 260, 'protein': 24, 'carbs': 28, 'fat': 6},
                  {'type': 'Jantar', 'time': '19:00', 'name': 'Peito de Peru com Salada', 'calories': 420, 'protein': 38, 'carbs': 20, 'fat': 18},
                ],
              },
              {
                'day': 'Sexta',
                'meals': [
                  {'type': 'Café da Manhã', 'time': '07:00', 'name': 'Smoothie Bowl', 'calories': 340, 'protein': 18, 'carbs': 48, 'fat': 8},
                  {'type': 'Almoço', 'time': '12:30', 'name': 'Frango com Batata Doce', 'calories': 550, 'protein': 55, 'carbs': 45, 'fat': 14},
                  {'type': 'Lanche', 'time': '15:30', 'name': 'Barra de Proteína', 'calories': 200, 'protein': 22, 'carbs': 18, 'fat': 6},
                  {'type': 'Jantar', 'time': '19:00', 'name': 'Sopa de Legumes com Carne', 'calories': 460, 'protein': 35, 'carbs': 40, 'fat': 15},
                ],
              },
              {
                'day': 'Sábado',
                'meals': [
                  {'type': 'Café da Manhã', 'time': '08:00', 'name': 'Omelete com Vegetais', 'calories': 380, 'protein': 30, 'carbs': 10, 'fat': 24},
                  {'type': 'Almoço', 'time': '13:00', 'name': 'Pizza de Cauliflower', 'calories': 520, 'protein': 38, 'carbs': 42, 'fat': 20},
                  {'type': 'Lanche', 'time': '16:00', 'name': 'Frutas com Amendoim', 'calories': 280, 'protein': 10, 'carbs': 32, 'fat': 14},
                  {'type': 'Jantar', 'time': '19:30', 'name': 'Hambúrguer Caseiro', 'calories': 560, 'protein': 42, 'carbs': 30, 'fat': 28},
                ],
              },
              {
                'day': 'Domingo',
                'meals': [
                  {'type': 'Café da Manhã', 'time': '08:30', 'name': 'Açaí com Granola', 'calories': 400, 'protein': 15, 'carbs': 52, 'fat': 14},
                  {'type': 'Almoço', 'time': '13:00', 'name': 'Strogonoff de Frango', 'calories': 540, 'protein': 45, 'carbs': 35, 'fat': 22},
                  {'type': 'Lanche', 'time': '16:30', 'name': 'Mix de Nuts', 'calories': 240, 'protein': 8, 'carbs': 10, 'fat': 20},
                  {'type': 'Jantar', 'time': '19:30', 'name': 'Salada Caesar com Frango', 'calories': 420, 'protein': 38, 'carbs': 18, 'fat': 22},
                ],
              },
            ],
          };
        });
      }
    }
  }

  int _getDayTotalCalories(int dayIndex) {
    final day = _mealPlan!['weeklyPlan'][dayIndex];
    int total = 0;
    for (final meal in day['meals']) {
      total += meal['calories'] as int;
    }
    return total;
  }

  IconData _getMealIcon(String type) {
    if (type.toLowerCase().contains('café')) return Icons.free_breakfast;
    if (type.toLowerCase().contains('almoço')) return Icons.lunch_dining;
    if (type.toLowerCase().contains('lanche')) return Icons.cookie;
    if (type.toLowerCase().contains('jantar')) return Icons.dinner_dining;
    return Icons.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plano de Refeições'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gerando plano com IA...')),
              );
            },
            tooltip: 'Gerar com IA',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMealPlan,
              child: Column(
                children: [
                  _buildDaySelector(),
                  Expanded(
                    child: _buildDayMeals(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDaySelector() {
    final days = _mealPlan!['weeklyPlan'] as List;
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDay;
          final calories = _getDayTotalCalories(index);
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: Container(
              width: 64,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (days[index]['day'] as String).substring(0, 3),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$calories',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayMeals() {
    final day = _mealPlan!['weeklyPlan'][_selectedDay];
    final meals = day['meals'] as List;
    final totalCalories = _getDayTotalCalories(_selectedDay);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day['day'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${meals.length} refeições',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalCalories kcal',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...meals.map((meal) => _buildMealCard(meal)),
        ],
      ),
    );
  }

  Widget _buildMealCard(dynamic meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getMealIcon(meal['type']), color: AppColors.success, size: 22),
        ),
        title: Text(meal['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Text(meal['type'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(width: 8),
            Text(meal['time'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${meal['calories']} kcal',
            style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

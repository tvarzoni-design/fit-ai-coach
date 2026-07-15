import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class MealPrepPage extends StatefulWidget {
  const MealPrepPage({super.key});

  @override
  State<MealPrepPage> createState() => _MealPrepPageState();
}

class _MealPrepPageState extends State<MealPrepPage> {
  int _selectedDay = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _mealPlan;

  final List<String> _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
  final List<String> _fullDays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
  final List<String> _mealTypes = ['Café da Manhã', 'Lanche Manhã', 'Almoço', 'Lanche Tarde', 'Jantar', 'Ceia'];

  final Map<String, dynamic> _mockPlan = {
    'days': {
      'Seg': {
        'meals': [
          {'type': 'Café da Manhã', 'name': 'Ovos Mexidos com Aveia', 'calories': 450, 'prepTime': '15 min', 'recipe': '2 ovos + 40g aveia + banana'},
          {'type': 'Lanche Manhã', 'name': 'Shake Proteico', 'calories': 250, 'prepTime': '5 min', 'recipe': 'Whey + leite + frutas'},
          {'type': 'Almoço', 'name': 'Frango com Arroz e Salada', 'calories': 650, 'prepTime': '30 min', 'recipe': '200g peito de frango + 150g arroz + salada'},
          {'type': 'Lanche Tarde', 'name': 'Iogurte com Granola', 'calories': 200, 'prepTime': '5 min', 'recipe': '200g iogurte + 30g granola'},
          {'type': 'Jantar', 'name': 'Salmão com Legumes', 'calories': 550, 'prepTime': '25 min', 'recipe': '180g salmão + legumes grelhados'},
          {'type': 'Ceia', 'name': 'Caseína com Amendoim', 'calories': 200, 'prepTime': '5 min', 'recipe': '30g caseína + 15g amendoim'},
        ],
      },
      'Ter': {
        'meals': [
          {'type': 'Café da Manhã', 'name': 'Panquecas de Banana', 'calories': 400, 'prepTime': '20 min', 'recipe': '1 banana + 2 ovos + aveia'},
          {'type': 'Lanche Manhã', 'name': 'Frutas com Castanhas', 'calories': 200, 'prepTime': '5 min', 'recipe': 'Mix de frutas + 30g castanhas'},
          {'type': 'Almoço', 'name': 'Carne Moída com Batata', 'calories': 700, 'prepTime': '35 min', 'recipe': '200g carne moída + 150g batata doce'},
          {'type': 'Lanche Tarde', 'name': 'Barra de Proteína', 'calories': 180, 'prepTime': '1 min', 'recipe': '1 barra de proteína'},
          {'type': 'Jantar', 'name': 'Peixe com Quinoa', 'calories': 500, 'prepTime': '25 min', 'recipe': '180g peixe + 100g quinoa'},
          {'type': 'Ceia', 'name': 'Cottage com Mel', 'calories': 180, 'prepTime': '5 min', 'recipe': '150g cottage + 1 colher mel'},
        ],
      },
    },
    'totalPrepTime': '2h 30min',
    'totalGroceryItems': 24,
  };

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/nutrition/meal-plan');
      if (mounted) {
        setState(() {
          _mealPlan = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mealPlan = _mockPlan;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getMealsForDay(int dayIndex) {
    final dayKey = _days[dayIndex];
    final days = _mealPlan!['days'] as Map<String, dynamic>;
    if (days.containsKey(dayKey)) {
      return (days[dayKey]['meals'] as List).cast<Map<String, dynamic>>();
    }
    return (_mealPlan!['days']['Seg']['meals'] as List).cast<Map<String, dynamic>>();
  }

  int _getDayCalories(int dayIndex) {
    return _getMealsForDay(dayIndex).fold(0, (sum, meal) => sum + (meal['calories'] as int));
  }

  Color _mealColor(String type) {
    switch (type) {
      case 'Café da Manhã':
        return AppColors.warning;
      case 'Lanche Manhã':
        return AppColors.info;
      case 'Almoço':
        return AppColors.success;
      case 'Lanche Tarde':
        return AppColors.primary;
      case 'Jantar':
        return AppColors.secondary;
      case 'Ceia':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Meal Prep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/grocery-list'),
            tooltip: 'Lista de compras',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDaySelector(),
                _buildSummaryBar(),
                Expanded(child: _buildMealList()),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDay == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_days[index], style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      shape: BoxShape.circle,
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

  Widget _buildSummaryBar() {
    final meals = _getMealsForDay(_selectedDay);
    final totalCal = _getDayCalories(_selectedDay);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(Icons.restaurant_menu, '${meals.length}', 'Refeições'),
          _buildSummaryItem(Icons.local_fire_department, '$totalCal', 'Calorias'),
          _buildSummaryItem(Icons.timer_outlined, _mealPlan!['totalPrepTime'] ?? '2h', 'Prep Total'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildMealList() {
    final meals = _getMealsForDay(_selectedDay);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        final color = _mealColor(meal['type']);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.restaurant, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meal['type'], style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                          Text(meal['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${meal['calories']} kcal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(meal['prepTime'], style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppColors.textMuted, size: 14),
                      const SizedBox(width: 8),
                      Expanded(child: Text(meal['recipe'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.surfaceLight))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dicas de batch cooking para ${_fullDays[_selectedDay]}')),
                );
              },
              icon: const Icon(Icons.lightbulb_outline, size: 18),
              label: const Text('Dicas'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push('/grocery-list'),
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('Lista de Compras'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

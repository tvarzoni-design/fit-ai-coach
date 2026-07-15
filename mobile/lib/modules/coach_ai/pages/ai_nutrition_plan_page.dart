import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AINutritionPlanPage extends StatefulWidget {
  const AINutritionPlanPage({super.key});

  @override
  State<AINutritionPlanPage> createState() => _AINutritionPlanPageState();
}

class _AINutritionPlanPageState extends State<AINutritionPlanPage> {
  Map<String, dynamic>? _plan;
  bool _isLoading = true;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/ai/nutrition-plan');
      if (mounted) setState(() { _plan = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _plan = {
            'name': 'Plano Nutricional - Cutting',
            'status': 'active',
            'dailyCalories': 2200,
            'macros': {'protein': 180, 'carbs': 220, 'fat': 73},
            'weeklyPlan': [
              {
                'day': 'Segunda',
                'meals': [
                  {'name': 'Café da Manhã', 'time': '07:00', 'foods': [
                    {'name': 'Aveia com frutas', 'grams': 100, 'calories': 350, 'protein': 12, 'carbs': 55, 'fat': 8},
                    {'name': 'Ovos mexidos', 'grams': 150, 'calories': 220, 'protein': 20, 'carbs': 2, 'fat': 15},
                    {'name': 'Café preto', 'grams': 200, 'calories': 5, 'protein': 0, 'carbs': 1, 'fat': 0},
                  ]},
                  {'name': 'Lanche da Manhã', 'time': '10:00', 'foods': [
                    {'name': 'Whey protein', 'grams': 30, 'calories': 120, 'protein': 25, 'carbs': 3, 'fat': 1},
                    {'name': 'Banana', 'grams': 120, 'calories': 110, 'protein': 1, 'carbs': 28, 'fat': 0},
                  ]},
                  {'name': 'Almoço', 'time': '12:30', 'foods': [
                    {'name': 'Arroz integral', 'grams': 200, 'calories': 230, 'protein': 5, 'carbs': 48, 'fat': 2},
                    {'name': 'Peito de frango', 'grams': 200, 'calories': 330, 'protein': 62, 'carbs': 0, 'fat': 7},
                    {'name': 'Brócolis', 'grams': 150, 'calories': 50, 'protein': 4, 'carbs': 7, 'fat': 1},
                  ]},
                  {'name': 'Lanche da Tarde', 'time': '15:30', 'foods': [
                    {'name': 'Iogurte grego', 'grams': 200, 'calories': 130, 'protein': 20, 'carbs': 8, 'fat': 3},
                    {'name': 'Castanhas', 'grams': 30, 'calories': 195, 'protein': 5, 'carbs': 4, 'fat': 18},
                  ]},
                  {'name': 'Jantar', 'time': '19:00', 'foods': [
                    {'name': 'Salmão grelhado', 'grams': 180, 'calories': 370, 'protein': 40, 'carbs': 0, 'fat': 22},
                    {'name': 'Batata doce', 'grams': 200, 'calories': 170, 'protein': 3, 'carbs': 40, 'fat': 0},
                    {'name': 'Salada verde', 'grams': 100, 'calories': 20, 'protein': 2, 'carbs': 3, 'fat': 0},
                  ]},
                  {'name': 'Ceia', 'time': '21:30', 'foods': [
                    {'name': 'Caseína', 'grams': 30, 'calories': 115, 'protein': 24, 'carbs': 3, 'fat': 1},
                  ]},
                ],
              },
            ],
          };
        });
      }
    }
  }

  int _getDayCalories(int dayIndex) {
    final day = _plan!['weeklyPlan'][dayIndex];
    int total = 0;
    for (final meal in day['meals']) {
      for (final food in meal['foods']) {
        total += food['calories'] as int;
      }
    }
    return total;
  }

  void _showShoppingList() {
    final day = _plan!['weeklyPlan'][_selectedDay];
    final foods = <String, int>{};
    for (final meal in day['meals']) {
      for (final food in meal['foods']) {
        final name = food['name'] as String;
        foods[name] = (foods[name] ?? 0) + (food['grams'] as int);
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
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
            Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: AppColors.success),
                const SizedBox(width: 8),
                Text('Lista de Compras', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...foods.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e.key, style: TextStyle(color: AppColors.textSecondary))),
                  Text('${e.value}g', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
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
        title: const Text('Plano Nutricional IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: _showShoppingList,
            tooltip: 'Lista de compras',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPlan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlanHeader(),
                    const SizedBox(height: 16),
                    _buildMacroTargets(),
                    const SizedBox(height: 16),
                    _buildDaySelector(),
                    const SizedBox(height: 12),
                    _buildMealsList(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlanHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: AppColors.success),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _plan!['name'] ?? 'Plano Nutricional',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_plan!['dailyCalories']} kcal/dia',
                    style: TextStyle(color: AppColors.success),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Ativo', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroTargets() {
    final macros = _plan!['macros'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Metas Diárias', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroCircle('Proteína', '${macros['protein']}g', AppColors.secondary, 0.7),
                _buildMacroCircle('Carbs', '${macros['carbs']}g', AppColors.primary, 0.6),
                _buildMacroCircle('Gordura', '${macros['fat']}g', AppColors.warning, 0.4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCircle(String label, String value, Color color, double progress) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildDaySelector() {
    final days = _plan!['weeklyPlan'] as List;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDay;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(days[index]['day']),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceLight,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (_) => setState(() => _selectedDay = index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealsList() {
    final day = _plan!['weeklyPlan'][_selectedDay];
    final meals = day['meals'] as List;
    final dayCalories = _getDayCalories(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Refeições', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$dayCalories kcal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...meals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  Widget _buildMealCard(dynamic meal) {
    final foods = meal['foods'] as List;
    int mealCalories = 0;
    for (final f in foods) {
      mealCalories += f['calories'] as int;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(meal['time'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                Text('$mealCalories kcal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(meal['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...foods.map((food) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(food['name'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                  Text('${food['grams']}g', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(width: 12),
                  Text('${food['calories']} kcal', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gerando novo plano nutricional...')),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Gerar Novo Plano com IA'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/nutrition'),
            icon: const Icon(Icons.tune),
            label: const Text('Ajustar Metas'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

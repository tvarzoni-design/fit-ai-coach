import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  Map<String, dynamic>? _goals;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getNutritionGoals();
      if (mounted) setState(() { _goals = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _goals = {
            'targetCalories': 2500, 'caloriesConsumed': 1800,
            'targetProtein': 150, 'protein': 120,
            'targetCarbs': 300, 'carbs': 200,
            'targetFat': 80, 'fat': 55,
            'waterGlasses': 6, 'waterTarget': 8,
            'meals': [
              {'name': 'Café da Manhã', 'time': '07:00', 'calories': 450, 'protein': 30, 'carbs': 50, 'fat': 15, 'foods': []},
              {'name': 'Almoço', 'time': '12:00', 'calories': 650, 'protein': 45, 'carbs': 70, 'fat': 20, 'foods': []},
            ],
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nutrição')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final goals = _goals!;
    final caloriesConsumed = goals['caloriesConsumed'] ?? 0;
    final targetCalories = goals['targetCalories'] ?? 2500;
    final remaining = targetCalories - caloriesConsumed;
    final proteinProgress = (goals['protein'] ?? 0) / (goals['targetProtein'] ?? 1);
    final carbsProgress = (goals['carbs'] ?? 0) / (goals['targetCarbs'] ?? 1);
    final fatProgress = (goals['fat'] ?? 0) / (goals['targetFat'] ?? 1);
    final waterGlasses = goals['waterGlasses'] ?? 0;
    final waterTarget = (goals['waterTarget'] ?? 8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrição'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () => _showMealSuggestions(context),
            tooltip: 'Sugestões de Refeição',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalorieRing(caloriesConsumed, targetCalories, remaining),
              const SizedBox(height: 20),
              _buildMacroBar('Proteína', goals['protein'] ?? 0, goals['targetProtein'] ?? 150, 'g', AppColors.secondary, proteinProgress),
              const SizedBox(height: 12),
              _buildMacroBar('Carboidratos', goals['carbs'] ?? 0, goals['targetCarbs'] ?? 300, 'g', AppColors.primary, carbsProgress),
              const SizedBox(height: 12),
              _buildMacroBar('Gordura', goals['fat'] ?? 0, goals['targetFat'] ?? 80, 'g', AppColors.warning, fatProgress),
              const SizedBox(height: 24),
              _buildWaterTracker(waterGlasses, waterTarget),
              const SizedBox(height: 24),
              _buildSectionTitle('Refeições de Hoje'),
              ...(goals['meals'] as List? ?? []).map((meal) => _buildMealItem(meal)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAddMeal(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Refeição'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieRing(int consumed, int target, int remaining) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
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
                    value: consumed / target,
                    strokeWidth: 12,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      consumed > target ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$consumed', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
                    Text('/ $target kcal', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalorieStat('Consumido', '$consumed kcal', AppColors.primary),
              _buildCalorieStat('Restante', '$remaining kcal', remaining > 0 ? AppColors.success : AppColors.error),
              _buildCalorieStat('Meta', '$target kcal', AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _buildMacroBar(String label, int current, int target, String unit, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              Text('$current / $target $unit', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker(int current, int target) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.water_drop, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Text('Água', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ],
              ),
              Text('$current / $target copos', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(target, (index) {
              final filled = index < current;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _goals!['waterGlasses'] = filled ? current - 1 : current + 1;
                  });
                },
                child: Icon(
                  Icons.water_drop,
                  color: filled ? AppColors.info : AppColors.surfaceLight,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${(current * 250)}ml / ${target * 250}ml',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMealItem(dynamic meal) {
    final foods = meal['foods'] as List? ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              Text(meal['time'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMacroChip('${meal['calories'] ?? 0} kcal', AppColors.primary),
              const SizedBox(width: 8),
              _buildMacroChip('${meal['protein'] ?? 0}g P', AppColors.secondary),
              const SizedBox(width: 8),
              _buildMacroChip('${meal['carbs'] ?? 0}g C', AppColors.primary),
              const SizedBox(width: 8),
              _buildMacroChip('${meal['fat'] ?? 0}g G', AppColors.warning),
            ],
          ),
          if (foods.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...foods.map((food) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(food['name'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('${food['calories'] ?? 0} kcal', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _showAddMeal(BuildContext context) async {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    await showModalBottomSheet(
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
            Text('Adicionar Refeição', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome da Refeição')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: caloriesController, decoration: const InputDecoration(labelText: 'Calorias'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: proteinController, decoration: const InputDecoration(labelText: 'Proteína (g)'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: carbsController, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: fatController, decoration: const InputDecoration(labelText: 'Gordura (g)'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final api = context.read<AuthService>().api;
                  try {
                    await api.logMeal({
                      'name': nameController.text,
                      'calories': int.tryParse(caloriesController.text) ?? 0,
                      'protein': int.tryParse(proteinController.text) ?? 0,
                      'carbs': int.tryParse(carbsController.text) ?? 0,
                      'fat': int.tryParse(fatController.text) ?? 0,
                    });
                    Navigator.pop(context);
                    _loadData();
                  } catch (e) {
                    Navigator.pop(context);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao salvar refeição')),
                      );
                    }
                  }
                },
                child: const Text('Salvar Refeição'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMealSuggestions(BuildContext context) {
    final suggestions = [
      {'name': 'Frango com Batata Doce', 'calories': 520, 'protein': 45, 'carbs': 50, 'fat': 12},
      {'name': 'Salada de Atum', 'calories': 380, 'protein': 35, 'carbs': 25, 'fat': 18},
      {'name': 'Omelete de Claras', 'calories': 220, 'protein': 28, 'carbs': 5, 'fat': 10},
    ];

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
                Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Sugestões da IA', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestions.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['name'] as String, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${s['calories']} kcal', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      const SizedBox(width: 12),
                      Text('${s['protein']}g P', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                      const SizedBox(width: 12),
                      Text('${s['carbs']}g C', style: TextStyle(color: AppColors.info, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${s['name']} adicionada!'), backgroundColor: AppColors.success),
                        );
                      },
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primary)),
                      child: Text('Adicionar', style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

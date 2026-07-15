import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import 'package:provider/provider.dart';

class FoodDetailPage extends StatefulWidget {
  final String? foodName;
  const FoodDetailPage({super.key, this.foodName});
  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int _servings = 1;
  bool _isLoading = false;

  final _foodData = {
    'name': 'Frango Grelhado',
    'servingSize': '100g',
    'calories': 165,
    'protein': 31,
    'carbs': 0,
    'fat': 3.6,
    'fiber': 0,
    'sodium': 74,
    'sugar': 0,
  };

  @override
  Widget build(BuildContext context) {
    final name = widget.foodName ?? _foodData['name'];
    final calories = (_foodData['calories'] as int) * _servings;
    final protein = (_foodData['protein'] as int) * _servings;
    final carbs = (_foodData['carbs'] as int) * _servings;
    final fat = (_foodData['fat'] as double) * _servings;

    return Scaffold(
      appBar: AppBar(
        title: Text((name ?? 'Detalhe do Alimento').toString()),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text((name ?? 'Alimento').toString(), style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text('${_foodData['servingSize']} por porção', style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 20),
                  Row(children: [
                    _macroCircle('Cal', '$calories', 'kcal', AppColors.error),
                    _macroCircle('Prot', '${protein}g', '', AppColors.primary),
                    _macroCircle('Carb', '${carbs}g', '', AppColors.warning),
                    _macroCircle('Gord', '${fat.toStringAsFixed(1)}g', '', AppColors.secondary),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Porções', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                      onPressed: _servings > 1 ? () => setState(() => _servings--) : null,
                      icon: Icon(Icons.remove_circle, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(width: 24),
                    Text('$_servings', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 28)),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: () => setState(() => _servings++),
                      icon: Icon(Icons.add_circle, color: AppColors.primary, size: 36),
                    ),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Micronutrientes', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _microRow('Fibra', '${_foodData['fiber']}g'),
                  _microRow('Sódio', '${_foodData['sodium']}mg'),
                  _microRow('Açúcar', '${_foodData['sugar']}g'),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name adicionado à refeição!')));
                  context.pop();
                },
                icon: Icon(Icons.add),
                label: Text('Adicionar à Refeição'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroCircle(String label, String value, String unit, Color color) => Expanded(
    child: Column(children: [
      SizedBox(width: 60, height: 60, child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(value: 1, strokeWidth: 4, color: color.withValues(alpha: 0.2)),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
      ])),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      if (unit.isNotEmpty) Text(unit, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  );

  Widget _microRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: AppColors.textSecondary)),
      Text(value, style: TextStyle(color: AppColors.textPrimary)),
    ]),
  );
}

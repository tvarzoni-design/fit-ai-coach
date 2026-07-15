import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class MealDetailPage extends StatefulWidget {
  final String mealType;

  const MealDetailPage({super.key, required this.mealType});

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  List<Map<String, dynamic>> _foods = [];
  bool _isLoading = true;
  String? _error;

  String get _mealTitle {
    switch (widget.mealType) {
      case 'cafe-da-manha': return 'Café da Manhã';
      case 'almoco': return 'Almoço';
      case 'lanche': return 'Lanche';
      case 'jantar': return 'Jantar';
      default: return widget.mealType;
    }
  }

  IconData get _mealIcon {
    switch (widget.mealType) {
      case 'cafe-da-manha': return Icons.free_breakfast;
      case 'almoco': return Icons.lunch_dining;
      case 'lanche': return Icons.cookie;
      case 'jantar': return Icons.dinner_dining;
      default: return Icons.restaurant;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getDailySummary(DateTime.now().toIso8601String().split('T')[0]);
      final meals = response.data['meals'] as List? ?? [];
      final meal = meals.firstWhere(
        (m) => m['type'] == widget.mealType || m['name'] == _mealTitle,
        orElse: () => <String, dynamic>{},
      );
      if (mounted) {
        setState(() {
          _foods = (meal['foods'] as List? ?? []).map<Map<String, dynamic>>((f) => Map<String, dynamic>.from(f)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _foods = [
            {'id': '1', 'name': 'Pão Integral', 'calories': 120, 'protein': 6, 'carbs': 22, 'fat': 2, 'quantity': 2},
            {'id': '2', 'name': 'Ovos Mexidos', 'calories': 180, 'protein': 14, 'carbs': 2, 'fat': 13, 'quantity': 3},
          ];
          _isLoading = false;
        });
      }
    }
  }

  Map<String, double> get _totals {
    double cal = 0, prot = 0, carb = 0, fat = 0;
    for (final f in _foods) {
      final qty = (f['quantity'] as num?)?.toDouble() ?? 1;
      cal += ((f['calories'] as num?)?.toDouble() ?? 0) * qty;
      prot += ((f['protein'] as num?)?.toDouble() ?? 0) * qty;
      carb += ((f['carbs'] as num?)?.toDouble() ?? 0) * qty;
      fat += ((f['fat'] as num?)?.toDouble() ?? 0) * qty;
    }
    return {'calories': cal, 'protein': prot, 'carbs': carb, 'fat': fat};
  }

  double get _totalMacros => _totals['protein']! + _totals['carbs']! + _totals['fat']!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_mealIcon, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(_mealTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveMeal,
            tooltip: 'Salvar refeição',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFoods,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalCard(),
                    const SizedBox(height: 20),
                    _buildMacroSummaryBar(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Alimentos', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _addFood,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Adicionar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._foods.asMap().entries.map((e) => _buildFoodItem(e.key, e.value)),
                    if (_foods.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.restaurant, color: AppColors.textMuted, size: 48),
                            const SizedBox(height: 12),
                            Text('Nenhum alimento adicionado', style: TextStyle(color: AppColors.textMuted)),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _addFood,
                              icon: const Icon(Icons.search),
                              label: const Text('Buscar Alimentos'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTotalCard() {
    final totals = _totals;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.2), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('Total da Refeição', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Text('${totals['calories']!.toStringAsFixed(0)} kcal', style: TextStyle(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniMacro('Proteína', totals['protein']!, 'g', AppColors.secondary),
              _buildMiniMacro('Carboidratos', totals['carbs']!, 'g', AppColors.primary),
              _buildMiniMacro('Gorduras', totals['fat']!, 'g', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMacro(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Text('${value.toStringAsFixed(1)}$unit', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _buildMacroSummaryBar() {
    final totals = _totals;
    final total = _totalMacros;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribuição de Macros', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  Expanded(
                    flex: (totals['protein']! / total * 100).round().clamp(1, 100),
                    child: Container(color: AppColors.secondary, child: Center(child: Text('P', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                  ),
                  Expanded(
                    flex: (totals['carbs']! / total * 100).round().clamp(1, 100),
                    child: Container(color: AppColors.primary, child: Center(child: Text('C', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                  ),
                  Expanded(
                    flex: (totals['fat']! / total * 100).round().clamp(1, 100),
                    child: Container(color: AppColors.warning, child: Center(child: Text('G', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend('Proteínas', totals['protein']!.toStringAsFixed(1), AppColors.secondary),
              _buildLegend('Carboidratos', totals['carbs']!.toStringAsFixed(1), AppColors.primary),
              _buildLegend('Gorduras', totals['fat']!.toStringAsFixed(1), AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$label $value', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _buildFoodItem(int index, Map<String, dynamic> food) {
    final qty = (food['quantity'] as num?)?.toDouble() ?? 1;
    return Dismissible(
      key: Key(food['id']?.toString() ?? '$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        setState(() => _foods.removeAt(index));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('${qty.toStringAsFixed(0)} porção(ões) • ${((food['calories'] as num?)?.toDouble() ?? 0) * qty} kcal',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
              onSelected: (value) {
                if (value == 'edit') _editFood(index, food);
                if (value == 'delete') setState(() => _foods.removeAt(index));
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Editar')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: AppColors.error), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: AppColors.error))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addFood() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');

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
            Text('Adicionar Alimento', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome do Alimento', prefixIcon: Icon(Icons.restaurant))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: TextField(controller: calCtrl, decoration: const InputDecoration(labelText: 'Calorias (por porção)'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: protCtrl, decoration: const InputDecoration(labelText: 'Proteína (g)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: carbsCtrl, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: fatCtrl, decoration: const InputDecoration(labelText: 'Gordura (g)'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/nutrition/food-search', extra: (Map<String, dynamic> food) {
                        setState(() => _foods.add(food));
                      });
                    },
                    child: const Text('Buscar Alimentos'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _foods.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'name': nameCtrl.text,
                          'calories': int.tryParse(calCtrl.text) ?? 0,
                          'protein': double.tryParse(protCtrl.text) ?? 0,
                          'carbs': double.tryParse(carbsCtrl.text) ?? 0,
                          'fat': double.tryParse(fatCtrl.text) ?? 0,
                          'quantity': int.tryParse(qtyCtrl.text) ?? 1,
                        });
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Adicionar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editFood(int index, Map<String, dynamic> food) {
    final nameCtrl = TextEditingController(text: food['name']?.toString());
    final calCtrl = TextEditingController(text: (food['calories'] as num?)?.toString());
    final protCtrl = TextEditingController(text: (food['protein'] as num?)?.toString());
    final carbsCtrl = TextEditingController(text: (food['carbs'] as num?)?.toString());
    final fatCtrl = TextEditingController(text: (food['fat'] as num?)?.toString());
    final qtyCtrl = TextEditingController(text: (food['quantity'] as num?)?.toString() ?? '1');

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
            Text('Editar Alimento', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome do Alimento')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: TextField(controller: calCtrl, decoration: const InputDecoration(labelText: 'Calorias'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: protCtrl, decoration: const InputDecoration(labelText: 'Proteína (g)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: carbsCtrl, decoration: const InputDecoration(labelText: 'Carbs (g)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: fatCtrl, decoration: const InputDecoration(labelText: 'Gordura (g)'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _foods[index] = {
                      ...food,
                      'name': nameCtrl.text,
                      'calories': int.tryParse(calCtrl.text) ?? 0,
                      'protein': double.tryParse(protCtrl.text) ?? 0,
                      'carbs': double.tryParse(carbsCtrl.text) ?? 0,
                      'fat': double.tryParse(fatCtrl.text) ?? 0,
                      'quantity': int.tryParse(qtyCtrl.text) ?? 1,
                    };
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMeal() async {
    try {
      final api = context.read<AuthService>().api;
      await api.logMeal({
        'type': widget.mealType,
        'name': _mealTitle,
        'foods': _foods,
        'calories': _totals['calories']!.round(),
        'protein': _totals['protein']!.round(),
        'carbs': _totals['carbs']!.round(),
        'fat': _totals['fat']!.round(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refeição salva com sucesso!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar refeição'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

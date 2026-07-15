import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<Map<String, dynamic>> _mockFoods = [
    {'name': 'Peito de Frango Grelhado', 'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6},
    {'name': 'Arroz Branco Cozido', 'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3},
    {'name': 'Batata Doce Cozida', 'calories': 86, 'protein': 1.6, 'carbs': 20, 'fat': 0.1},
    {'name': 'Ovo Cozido', 'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11},
    {'name': 'Aveia em Flocos', 'calories': 389, 'protein': 16.9, 'carbs': 66, 'fat': 6.9},
    {'name': 'Banana Prata', 'calories': 89, 'protein': 1.1, 'carbs': 23, 'fat': 0.3},
    {'name': 'Whey Protein Isolado', 'calories': 113, 'protein': 25, 'carbs': 2, 'fat': 0.6},
    {'name': 'Azeite de Oliva Extra Virgem', 'calories': 884, 'protein': 0, 'carbs': 0, 'fat': 100},
    {'name': 'Salmão Grelhado', 'calories': 208, 'protein': 20, 'carbs': 0, 'fat': 13},
    {'name': 'Abacate', 'calories': 160, 'protein': 2, 'carbs': 8.5, 'fat': 15},
    {'name': 'Quinoa Cozida', 'calories': 120, 'protein': 4.4, 'carbs': 21, 'fat': 1.9},
    {'name': 'Iogurte Grego Natural', 'calories': 59, 'protein': 10, 'carbs': 3.6, 'fat': 0.7},
  ];

  @override
  void initState() {
    super.initState();
    _recentSearches = ['Frango', 'Arroz', 'Batata Doce', 'Ovo'];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.initState();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { _isLoading = true; _hasSearched = true; });

    if (!_recentSearches.contains(query.trim())) {
      _recentSearches.insert(0, query.trim());
      if (_recentSearches.length > 8) _recentSearches.removeLast();
    }

    try {
      final api = context.read<AuthService>().api;
      final response = await api.searchFoods(query);
      if (mounted) {
        setState(() {
          _results = (response.data['foods'] as List? ?? []).map<Map<String, dynamic>>((f) => Map<String, dynamic>.from(f)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        final q = query.toLowerCase();
        setState(() {
          _results = _mockFoods.where((f) => (f['name'] as String).toLowerCase().contains(q)).toList();
          _isLoading = false;
        });
      }
    }
  }

  void _selectFood(Map<String, dynamic> food) {
    final callback = GoRouterState.of(context).extra as Function(Map<String, dynamic>)?;
    if (callback != null) {
      callback({
        ...food,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'quantity': 1,
        'calories': food['calories'],
        'protein': food['protein'],
        'carbs': food['carbs'],
        'fat': food['fat'],
      });
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Alimentos'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar alimentos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() { _results = []; _hasSearched = false; });
                              },
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: _search,
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.qr_code_scanner, color: AppColors.primary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Escaneamento disponível em breve')),
                      );
                    },
                    tooltip: 'Escaneamento de Código de Barras',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched
                    ? _results.isEmpty
                        ? _buildNoResults()
                        : _buildResultsList()
                    : _buildInitialView(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Buscas Recentes', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => setState(() => _recentSearches.clear()),
                  child: const Text('Limpar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((s) => GestureDetector(
                onTap: () {
                  _searchController.text = s;
                  _search(s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s, style: TextStyle(color: AppColors.textSecondary)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
          Text('Alimentos Populares', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._mockFoods.take(6).map((f) => _buildPopularItem(f)),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: _showCustomFoodDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Criar Alimento Personalizado'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularItem(Map<String, dynamic> food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food['name'], style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('${food['calories']} kcal/100g', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text('${food['protein']}g P', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
          const SizedBox(width: 8),
          Text('${food['carbs']}g C', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          const SizedBox(width: 8),
          Text('${food['fat']}g G', style: TextStyle(color: AppColors.warning, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        if (index == _results.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: _showCustomFoodDialog,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Criar Alimento Personalizado'),
              ),
            ),
          );
        }
        return _buildResultItem(_results[index]);
      },
    );
  }

  Widget _buildResultItem(Map<String, dynamic> food) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectFood(food),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.restaurant, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('${food['calories']} kcal/100g', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${food['protein']}g', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('P', style: TextStyle(color: AppColors.secondary, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${food['carbs']}g', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('C', style: TextStyle(color: AppColors.primary, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${food['fat']}g', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('G', style: TextStyle(color: AppColors.warning, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.add_circle, color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: AppColors.textMuted, size: 64),
          const SizedBox(height: 16),
          Text('Nenhum alimento encontrado', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Tente outro termo de busca', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showCustomFoodDialog,
            icon: const Icon(Icons.add),
            label: const Text('Criar Alimento'),
          ),
        ],
      ),
    );
  }

  void _showCustomFoodDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

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
            Text('Criar Alimento', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome do Alimento', prefixIcon: Icon(Icons.restaurant))),
            const SizedBox(height: 12),
            TextField(controller: calCtrl, decoration: const InputDecoration(labelText: 'Calorias (por 100g)', prefixIcon: Icon(Icons.local_fire_department)), keyboardType: TextInputType.number),
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
                  final food = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameCtrl.text,
                    'calories': int.tryParse(calCtrl.text) ?? 0,
                    'protein': double.tryParse(protCtrl.text) ?? 0,
                    'carbs': double.tryParse(carbsCtrl.text) ?? 0,
                    'fat': double.tryParse(fatCtrl.text) ?? 0,
                    'quantity': 1,
                  };
                  _selectFood(food);
                  Navigator.pop(ctx);
                },
                child: const Text('Criar e Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

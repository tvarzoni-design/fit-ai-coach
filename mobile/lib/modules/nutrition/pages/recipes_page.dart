import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  List<dynamic> _recipes = [];
  bool _isLoading = true;
  String _selectedType = 'Todos';
  String _sortBy = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/nutrition/recipes');
      if (mounted) setState(() { _recipes = response.data ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _recipes = _getMockRecipes();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getMockRecipes() {
    return [
      {'id': '1', 'name': 'Frango com Batata Doce', 'type': 'Almoço', 'calories': 520, 'time': 40, 'protein': 45, 'carbs': 50, 'fat': 12, 'difficulty': 'Fácil', 'color': 'success'},
      {'id': '2', 'name': 'Salada Caesar com Frango', 'type': 'Almoço', 'calories': 380, 'time': 15, 'protein': 35, 'carbs': 20, 'fat': 18, 'difficulty': 'Fácil', 'color': 'info'},
      {'id': '3', 'name': 'Omelete de Claras', 'type': 'Lanche', 'calories': 180, 'time': 10, 'protein': 28, 'carbs': 5, 'fat': 5, 'difficulty': 'Fácil', 'color': 'warning'},
      {'id': '4', 'name': 'Salmão com Quinoa', 'type': 'Jantar', 'calories': 580, 'time': 35, 'protein': 42, 'carbs': 45, 'fat': 24, 'difficulty': 'Médio', 'color': 'secondary'},
      {'id': '5', 'name': 'Smoothie Bowl', 'type': 'Lanche', 'calories': 320, 'time': 10, 'protein': 15, 'carbs': 48, 'fat': 8, 'difficulty': 'Fácil', 'color': 'primary'},
      {'id': '6', 'name': 'Strogonoff de Frango', 'type': 'Jantar', 'calories': 540, 'time': 45, 'protein': 40, 'carbs': 35, 'fat': 22, 'difficulty': 'Médio', 'color': 'warning'},
      {'id': '7', 'name': 'Panquecas de Aveia', 'type': 'Café', 'calories': 350, 'time': 20, 'protein': 22, 'carbs': 40, 'fat': 10, 'difficulty': 'Fácil', 'color': 'info'},
      {'id': '8', 'name': 'Wrap de Peru', 'type': 'Almoço', 'calories': 420, 'time': 15, 'protein': 38, 'carbs': 35, 'fat': 14, 'difficulty': 'Fácil', 'color': 'success'},
      {'id': '9', 'name': 'Iogurte com Granola', 'type': 'Lanche', 'calories': 280, 'time': 5, 'protein': 18, 'carbs': 32, 'fat': 10, 'difficulty': 'Fácil', 'color': 'primary'},
      {'id': '10', 'name': 'Carne com Legumes', 'type': 'Jantar', 'calories': 480, 'time': 30, 'protein': 42, 'carbs': 30, 'fat': 20, 'difficulty': 'Médio', 'color': 'secondary'},
      {'id': '11', 'name': 'Tigela de Proteína', 'type': 'Lanche', 'calories': 340, 'time': 5, 'protein': 30, 'carbs': 35, 'fat': 8, 'difficulty': 'Fácil', 'color': 'warning'},
      {'id': '12', 'name': 'Risoto de Cogumelos', 'type': 'Jantar', 'calories': 560, 'time': 50, 'protein': 18, 'carbs': 65, 'fat': 22, 'difficulty': 'Difícil', 'color': 'info'},
    ];
  }

  List<dynamic> _getFilteredRecipes() {
    var filtered = _recipes;
    if (_selectedType != 'Todos') {
      filtered = filtered.where((r) => r['type'] == _selectedType).toList();
    }
    if (_sortBy == 'Calorias (menor)') {
      filtered = List.from(filtered)..sort((a, b) => a['calories'].compareTo(b['calories']));
    } else if (_sortBy == 'Tempo (menor)') {
      filtered = List.from(filtered)..sort((a, b) => a['time'].compareTo(b['time']));
    }
    return filtered;
  }

  void _showRecipeDetail(dynamic recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: AppColors.textMuted,
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recipe['name'],
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(recipe['type'], style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailStat(Icons.local_fire_department, '${recipe['calories']} kcal', AppColors.warning),
                  _buildDetailStat(Icons.timer_outlined, '${recipe['time']} min', AppColors.info),
                  _buildDetailStat(Icons.signal_cellular_alt, recipe['difficulty'], AppColors.success),
                ],
              ),
              const SizedBox(height: 20),
              Text('Macros', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMacroBar('Proteína', recipe['protein'], 'g', AppColors.secondary)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMacroBar('Carbs', recipe['carbs'], 'g', AppColors.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMacroBar('Gordura', recipe['fat'], 'g', AppColors.warning)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Ingredientes', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildIngredientItem('200g peito de frango'),
              _buildIngredientItem('150g batata doce'),
              _buildIngredientItem('1 colher de azeite'),
              _buildIngredientItem('Sal e pimenta a gosto'),
              _buildIngredientItem('Ervas finas'),
              const SizedBox(height: 24),
              Text('Modo de Preparo', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildStepItem(1, 'Tempere o frango com sal, pimenta e ervas finas.'),
              _buildStepItem(2, 'Asse a batata doce no forno a 200°C por 25 minutos.'),
              _buildStepItem(3, 'Grelhe o frango em fogo médio por 6 minutos de cada lado.'),
              _buildStepItem(4, 'Sirva o frango fatiado sobre a batata doce, regando com azeite.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${recipe['name']} adicionado ao plano!')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar ao Plano'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildMacroBar(String label, int value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text('$value$unit', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.circle, size: 6, color: AppColors.success),
          const SizedBox(width: 12),
          Text(ingredient, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$step', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description, style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = ['Todos', 'Almoço', 'Jantar', 'Lanche', 'Café'];
    final sortOptions = ['Todos', 'Calorias (menor)', 'Tempo (menor)'];
    final filtered = _getFilteredRecipes();

    return Scaffold(
      appBar: AppBar(title: const Text('Receitas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(types, sortOptions),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadRecipes,
                          child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => _buildRecipeCard(filtered[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters(List<String> types, List<String> sortOptions) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: types.length,
            itemBuilder: (context, index) {
              final isSelected = types[index] == _selectedType;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(types[index]),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceLight,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedType = types[index]),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: sortOptions.length,
            itemBuilder: (context, index) {
              final isSelected = sortOptions[index] == _sortBy;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index > 0) Icon(Icons.sort, size: 14, color: isSelected ? Colors.white : AppColors.textMuted),
                      if (index > 0) const SizedBox(width: 4),
                      Text(sortOptions[index], style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.secondary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  onSelected: (_) => setState(() => _sortBy = sortOptions[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('Nenhuma receita encontrada', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Tente trocar os filtros', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(dynamic recipe) {
    final colorMap = {
      'primary': AppColors.primary,
      'secondary': AppColors.secondary,
      'success': AppColors.success,
      'warning': AppColors.warning,
      'info': AppColors.info,
    };
    final color = colorMap[recipe['color']] ?? AppColors.primary;

    return GestureDetector(
      onTap: () => _showRecipeDetail(recipe),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: color.withValues(alpha: 0.15),
                child: Icon(
                  Icons.restaurant,
                  color: color,
                  size: 40,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['name'],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, size: 14, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text('${recipe['calories']}', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const Spacer(),
                        Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Text('${recipe['time']}min', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildMiniMacro('${recipe['protein']}P', AppColors.secondary),
                        const SizedBox(width: 4),
                        _buildMiniMacro('${recipe['carbs']}C', AppColors.primary),
                        const SizedBox(width: 4),
                        _buildMiniMacro('${recipe['fat']}G', AppColors.warning),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMacro(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}

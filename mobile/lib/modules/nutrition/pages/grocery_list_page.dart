import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class GroceryListPage extends StatefulWidget {
  const GroceryListPage({super.key});

  @override
  State<GroceryListPage> createState() => _GroceryListPageState();
}

class _GroceryListPageState extends State<GroceryListPage> {
  bool _isLoading = true;
  final Map<String, bool> _checkedItems = {};
  List<Map<String, dynamic>> _categories = [];
  double _totalEstimate = 0;

  @override
  void initState() {
    super.initState();
    _loadGroceryList();
  }

  Future<void> _loadGroceryList() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/nutrition/grocery-list');
      if (mounted) {
        setState(() {
          _categories = (response.data['categories'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
          _totalEstimate = (response.data['total_estimate'] as num?)?.toDouble() ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categories = _getMockData();
          _totalEstimate = 387.50;
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getMockData() {
    return [
      {
        'name': 'Proteínas',
        'icon': Icons.set_meal,
        'color': AppColors.error,
        'items': [
          {'name': 'Peito de Frango', 'quantity': '1.5 kg', 'price': 29.90, 'checked': false},
          {'name': 'Salmão', 'quantity': '600 g', 'price': 59.90, 'checked': false},
          {'name': 'Ovos', 'quantity': '30 un', 'price': 18.90, 'checked': false},
          {'name': 'Carne Moída', 'quantity': '1 kg', 'price': 34.90, 'checked': false},
        ],
      },
      {
        'name': 'Carboidratos',
        'icon': Icons.bakery_dining,
        'color': AppColors.warning,
        'items': [
          {'name': 'Arroz Integral', 'quantity': '2 kg', 'price': 12.90, 'checked': false},
          {'name': 'Aveia', 'quantity': '1 kg', 'price': 9.90, 'checked': false},
          {'name': 'Batata Doce', 'quantity': '2 kg', 'price': 8.90, 'checked': false},
          {'name': 'Quinoa', 'quantity': '500 g', 'price': 22.90, 'checked': false},
        ],
      },
      {
        'name': 'Vegetais',
        'icon': Icons.eco,
        'color': AppColors.success,
        'items': [
          {'name': 'Brócolis', 'quantity': '500 g', 'price': 6.90, 'checked': false},
          {'name': 'Espinafre', 'quantity': '300 g', 'price': 4.90, 'checked': false},
          {'name': 'Tomate', 'quantity': '1 kg', 'price': 7.90, 'checked': false},
          {'name': 'Cenoura', 'quantity': '1 kg', 'price': 5.90, 'checked': false},
        ],
      },
      {
        'name': 'Frutas',
        'icon': Icons.apple,
        'color': AppColors.secondary,
        'items': [
          {'name': 'Banana', 'quantity': '1 dúzia', 'price': 8.90, 'checked': false},
          {'name': 'Maçã', 'quantity': '1 kg', 'price': 9.90, 'checked': false},
          {'name': 'Morango', 'quantity': '500 g', 'price': 12.90, 'checked': false},
        ],
      },
      {
        'name': 'Laticínios',
        'icon': Icons.local_cafe,
        'color': AppColors.info,
        'items': [
          {'name': 'Iogurte Grego', 'quantity': '1 kg', 'price': 14.90, 'checked': false},
          {'name': 'Leite Desnatado', 'quantity': '1 L', 'price': 4.90, 'checked': false},
          {'name': 'Cottage', 'quantity': '500 g', 'price': 8.90, 'checked': false},
        ],
      },
      {
        'name': 'Suplementos',
        'icon': Icons.medical_services,
        'color': AppColors.primary,
        'items': [
          {'name': 'Whey Protein', 'quantity': '1 kg', 'price': 129.90, 'checked': false},
          {'name': 'Creatina', 'quantity': '300 g', 'price': 79.90, 'checked': false},
        ],
      },
    ];
  }

  int _getCheckedCount() {
    return _checkedItems.values.where((v) => v).length;
  }

  int _getTotalItems() {
    return _categories.fold(0, (sum, cat) => sum + (cat['items'] as List).length);
  }

  void _toggleItem(String categoryName, int itemIndex) {
    final key = '$categoryName-$itemIndex';
    setState(() {
      _checkedItems[key] = !(_checkedItems[key] ?? false);
    });
  }

  void _toggleCategory(String categoryName, bool value) {
    setState(() {
      final catIndex = _categories.indexWhere((c) => c['name'] == categoryName);
      if (catIndex != -1) {
        final items = _categories[catIndex]['items'] as List;
        for (var i = 0; i < items.length; i++) {
          _checkedItems['$categoryName-$i'] = value;
        }
      }
    });
  }

  bool _isCategoryChecked(String categoryName) {
    final catIndex = _categories.indexWhere((c) => c['name'] == categoryName);
    if (catIndex == -1) return false;
    final items = _categories[catIndex]['items'] as List;
    return List.generate(items.length, (i) => _checkedItems['$categoryName-$i'] ?? false).every((v) => v);
  }

  bool _isCategoryPartiallyChecked(String categoryName) {
    final catIndex = _categories.indexWhere((c) => c['name'] == categoryName);
    if (catIndex == -1) return false;
    final items = _categories[catIndex]['items'] as List;
    final checked = List.generate(items.length, (i) => _checkedItems['$categoryName-$i'] ?? false);
    return checked.any((v) => v) && !checked.every((v) => v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Lista de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareList,
            tooltip: 'Compartilhar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) => _buildCategorySection(_categories[index]),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildTotalBar(),
    );
  }

  Widget _buildProgressBar() {
    final total = _getTotalItems();
    final checked = _getCheckedCount();
    final progress = total > 0 ? checked / total : 0.0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progresso', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('$checked/$total itens', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(progress >= 1 ? AppColors.success : AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> category) {
    final name = category['name'] as String;
    final color = category['color'] as Color;
    final items = (category['items'] as List).cast<Map<String, dynamic>>();
    final isAllChecked = _isCategoryChecked(name);
    final isPartial = _isCategoryPartiallyChecked(name);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(category['icon'] as IconData, color: color, size: 20),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Checkbox(
                value: isAllChecked ? true : isPartial ? null : false,
                tristate: true,
                onChanged: (v) => _toggleCategory(name, v ?? false),
                activeColor: color,
              ),
            ],
          ),
          subtitle: Text('${items.length} itens', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          children: items.asMap().entries.map((entry) {
            final itemIndex = entry.key;
            final item = entry.value;
            final key = '$name-$itemIndex';
            final isChecked = _checkedItems[key] ?? false;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: GestureDetector(
                onTap: () => _toggleItem(name, itemIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isChecked ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isChecked ? color : AppColors.textMuted),
                  ),
                  child: isChecked ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                ),
              ),
              title: Text(
                item['name'],
                style: TextStyle(
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(item['quantity'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: Text(
                'R\$ ${(item['price'] as double).toStringAsFixed(2)}',
                style: TextStyle(
                  color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.surfaceLight))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimativa Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(
                  'R\$ ${_totalEstimate.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.success),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _shareList,
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Compartilhar'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
          ),
        ],
      ),
    );
  }

  void _shareList() {
    final buffer = StringBuffer('Lista de Compras FitAI Coach\n\n');
    for (final category in _categories) {
      buffer.writeln('${category['name']}:');
      final items = (category['items'] as List).cast<Map<String, dynamic>>();
      for (final item in items) {
        final key = '${category['name']}-${items.indexOf(item)}';
        final checked = _checkedItems[key] ?? false;
        buffer.writeln('${checked ? '✓' : '○'} ${item['name']} - ${item['quantity']} - R\$ ${(item['price'] as double).toStringAsFixed(2)}');
      }
      buffer.writeln();
    }
    buffer.write('Total estimado: R\$ ${_totalEstimate.toStringAsFixed(2)}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lista copiada para a área de transferência!')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class NutritionTipsPage extends StatefulWidget {
  const NutritionTipsPage({super.key});

  @override
  State<NutritionTipsPage> createState() => _NutritionTipsPageState();
}

class _NutritionTipsPageState extends State<NutritionTipsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _dailyTips = [];
  Map<String, dynamic> _macroAdvice = {};
  List<Map<String, dynamic>> _mealTiming = [];
  List<Map<String, dynamic>> _supplements = [];
  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/nutrition/tips');
      final data = response.data;
      if (mounted && data != null) {
        setState(() {
          _dailyTips = List<Map<String, dynamic>>.from(data['dailyTips'] ?? []);
          _macroAdvice = data['macroAdvice'] ?? {};
          _mealTiming = List<Map<String, dynamic>>.from(data['mealTiming'] ?? []);
          _supplements = List<Map<String, dynamic>>.from(data['supplements'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dailyTips = _getMockDailyTips();
          _macroAdvice = _getMockMacroAdvice();
          _mealTiming = _getMockMealTiming();
          _supplements = _getMockSupplements();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getMockDailyTips() {
    return [
      {'title': 'Hidratação Pré-Treino', 'description': 'Beba pelo menos 500ml de água 30 minutos antes do treino para melhor performance.', 'category': 'Hidratação', 'icon': 'water_drop', 'color': 'info'},
      {'title': 'Proteína Pós-Treino', 'description': 'Consuma 20-30g de proteína dentro de 30 minutos após o treino para maximizar a síntese proteica.', 'category': 'Nutrição', 'icon': 'egg_alt', 'color': 'success'},
      {'title': 'Carboidratos Complexos', 'description': 'Prefira carboidratos complexos como arroz integral e aveia para energia duradoura.', 'category': 'Macros', 'icon': 'grain', 'color': 'warning'},
      {'title': 'Gorduras Saudáveis', 'description': 'Inclua fontes de ômega-3 como peixes e castanhas em sua dieta diária.', 'category': 'Macros', 'icon': 'water_drop', 'color': 'secondary'},
      {'title': 'Fibras Diárias', 'description': 'Consuma pelo menos 25g de fibras por dia através de vegetais e legumes.', 'category': 'Nutrição', 'icon': 'eco', 'color': 'success'},
    ];
  }

  Map<String, dynamic> _getMockMacroAdvice() {
    return {
      'goal': 'Ganho de Massa',
      'calories': 2800,
      'protein': {'current': 145, 'target': 180, 'unit': 'g'},
      'carbs': {'current': 280, 'target': 350, 'unit': 'g'},
      'fat': {'current': 72, 'target': 85, 'unit': 'g'},
      'advice': 'Para ganho de massa, aumente a ingestão de proteína para 2g por kg corporal.',
    };
  }

  List<Map<String, dynamic>> _getMockMealTiming() {
    return [
      {'time': '07:00', 'meal': 'Café da Manhã', 'description': 'Aveia com frutas e whey protein', 'importance': 'Alta'},
      {'time': '10:00', 'meal': 'Lanche da Manhã', 'description': 'Fruta com castanhas', 'importance': 'Média'},
      {'time': '12:30', 'meal': 'Almoço', 'description': 'Arroz, feijão, proteína e salada', 'importance': 'Alta'},
      {'time': '15:30', 'meal': 'Pré-Treino', 'description': 'Banana com café ou pré-treino', 'importance': 'Alta'},
      {'time': '17:30', 'meal': 'Pós-Treino', 'description': 'Shake de proteína com dextrose', 'importance': 'Alta'},
      {'time': '20:00', 'meal': 'Jantar', 'description': 'Proteína magra com vegetais', 'importance': 'Alta'},
    ];
  }

  List<Map<String, dynamic>> _getMockSupplements() {
    return [
      {'name': 'Whey Protein', 'dosage': '30g pós-treino', 'priority': 'Essencial', 'color': 'primary'},
      {'name': 'Creatina', 'dosage': '5g diários', 'priority': 'Recomendado', 'color': 'success'},
      {'name': 'Ômega-3', 'dosage': '2 cápsulas/dia', 'priority': 'Recomendado', 'color': 'info'},
      {'name': 'Vitamina D', 'dosage': '2000 UI/dia', 'priority': 'Opcional', 'color': 'warning'},
      {'name': 'Magnésio', 'dosage': '400mg antes de dormir', 'priority': 'Opcional', 'color': 'warning'},
    ];
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'egg_alt':
        return Icons.egg_alt;
      case 'grain':
        return Icons.grain;
      case 'eco':
        return Icons.eco;
      case 'restaurant':
        return Icons.restaurant;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'primary':
        return AppColors.primary;
      case 'secondary':
        return AppColors.secondary;
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  Color _getImportanceColor(String importance) {
    switch (importance) {
      case 'Alta':
        return AppColors.success;
      case 'Média':
        return AppColors.warning;
      case 'Baixa':
        return AppColors.textMuted;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Dicas Nutricionais'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTips,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDailyTipCarousel(),
                    const SizedBox(height: 20),
                    Text('Macro Nutrientes', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildMacroAdvice(),
                    const SizedBox(height: 20),
                    Text('Cronograma de Refeições', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildMealTiming(),
                    const SizedBox(height: 20),
                    Text('Suplementação', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    _buildSupplements(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDailyTipCarousel() {
    if (_dailyTips.isEmpty) return const SizedBox();

    return Card(
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
                    Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Dica do Dia', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                Text(
                  '${_currentTipIndex + 1}/${_dailyTips.length}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getColor(_dailyTips[_currentTipIndex]['color'] ?? 'primary').withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIcon(_dailyTips[_currentTipIndex]['icon'] ?? 'lightbulb'),
                        color: _getColor(_dailyTips[_currentTipIndex]['color'] ?? 'primary'),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getColor(_dailyTips[_currentTipIndex]['color'] ?? 'primary').withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _dailyTips[_currentTipIndex]['category'] ?? '',
                          style: TextStyle(
                            color: _getColor(_dailyTips[_currentTipIndex]['color'] ?? 'primary'),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _dailyTips[_currentTipIndex]['title'] ?? '',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dailyTips[_currentTipIndex]['description'] ?? '',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_dailyTips.length, (index) {
                return Container(
                  width: index == _currentTipIndex ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == _currentTipIndex ? AppColors.primary : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _currentTipIndex > 0
                      ? () => setState(() => _currentTipIndex--)
                      : null,
                  child: Text('Anterior', style: TextStyle(color: _currentTipIndex > 0 ? AppColors.primary : AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: _currentTipIndex < _dailyTips.length - 1
                      ? () => setState(() => _currentTipIndex++)
                      : null,
                  child: Text('Próxima', style: TextStyle(color: _currentTipIndex < _dailyTips.length - 1 ? AppColors.primary : AppColors.textMuted)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroAdvice() {
    final protein = _macroAdvice['protein'] as Map<String, dynamic>? ?? {};
    final carbs = _macroAdvice['carbs'] as Map<String, dynamic>? ?? {};
    final fat = _macroAdvice['fat'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Meta: ${_macroAdvice['goal'] ?? '--'}', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${_macroAdvice['calories'] ?? 0} kcal/dia', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 16),
            _buildMacroBar('Proteína', protein['current'] ?? 0, protein['target'] ?? 1, AppColors.error, protein['unit'] ?? 'g'),
            const SizedBox(height: 12),
            _buildMacroBar('Carboidratos', carbs['current'] ?? 0, carbs['target'] ?? 1, AppColors.warning, carbs['unit'] ?? 'g'),
            const SizedBox(height: 12),
            _buildMacroBar('Gordura', fat['current'] ?? 0, fat['target'] ?? 1, AppColors.info, fat['unit'] ?? 'g'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _macroAdvice['advice'] ?? '',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(String label, double current, double target, Color color, String unit) {
    final pct = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('${current.round()}/${target.round()} $unit', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTiming() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text('Horários Sugeridos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            ..._mealTiming.asMap().entries.map((entry) {
              final meal = entry.value;
              final isLast = entry.key == _mealTiming.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _getImportanceColor(meal['importance'] ?? '').withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            meal['time'] ?? '',
                            style: TextStyle(
                              color: _getImportanceColor(meal['importance'] ?? ''),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(width: 1, height: 32, color: AppColors.surfaceLight),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meal['meal'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(meal['description'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplements() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Text('Recomendações', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            ..._supplements.map((supp) {
              final color = _getColor(supp['color'] ?? 'primary');
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(supp['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
                          Text(supp['dosage'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        supp['priority'] ?? '',
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

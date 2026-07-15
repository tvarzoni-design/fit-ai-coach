import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CalorieCyclePage extends StatefulWidget {
  const CalorieCyclePage({super.key});

  @override
  State<CalorieCyclePage> createState() => _CalorieCyclePageState();
}

class _CalorieCyclePageState extends State<CalorieCyclePage> {
  Map<String, dynamic>? _cycleData;
  bool _isLoading = true;
  bool _isSaving = false;

  int _highCalories = 2800;
  int _mediumCalories = 2200;
  int _lowCalories = 1800;

  int _highProtein = 180;
  int _highCarbs = 350;
  int _highFat = 70;

  int _mediumProtein = 160;
  int _mediumCarbs = 220;
  int _mediumFat = 65;

  int _lowProtein = 150;
  int _lowCarbs = 150;
  int _lowFat = 60;

  final Map<String, bool> _schedule = {
    'monday': true,
    'tuesday': false,
    'wednesday': true,
    'thursday': false,
    'friday': true,
    'saturday': false,
    'sunday': false,
  };

  @override
  void initState() {
    super.initState();
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/nutrition/calorie-cycle');
      if (mounted) {
        final data = response.data;
        setState(() {
          _cycleData = data;
          _highCalories = data?['highCalories'] ?? 2800;
          _mediumCalories = data?['mediumCalories'] ?? 2200;
          _lowCalories = data?['lowCalories'] ?? 1800;
          _highProtein = data?['highProtein'] ?? 180;
          _highCarbs = data?['highCarbs'] ?? 350;
          _highFat = data?['highFat'] ?? 70;
          _mediumProtein = data?['mediumProtein'] ?? 160;
          _mediumCarbs = data?['mediumCarbs'] ?? 220;
          _mediumFat = data?['mediumFat'] ?? 65;
          _lowProtein = data?['lowProtein'] ?? 150;
          _lowCarbs = data?['lowCarbs'] ?? 150;
          _lowFat = data?['lowFat'] ?? 60;
          if (data?['schedule'] != null) {
            _schedule.addAll(Map<String, bool>.from(data!['schedule']));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ciclo Calórico')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciclo Calórico'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveCycle,
            child: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCycleData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTDEEInfo(),
              const SizedBox(height: 20),
              _buildDayTypeSection('Alto', _highCalories, _highProtein, _highCarbs, _highFat,
                  (v) => _highCalories = v, (v) => _highProtein = v, (v) => _highCarbs = v, (v) => _highFat = v,
                  AppColors.success),
              const SizedBox(height: 16),
              _buildDayTypeSection('Médio', _mediumCalories, _mediumProtein, _mediumCarbs, _mediumFat,
                  (v) => _mediumCalories = v, (v) => _mediumProtein = v, (v) => _mediumCarbs = v, (v) => _mediumFat = v,
                  AppColors.warning),
              const SizedBox(height: 16),
              _buildDayTypeSection('Baixo', _lowCalories, _lowProtein, _lowCarbs, _lowFat,
                  (v) => _lowCalories = v, (v) => _lowProtein = v, (v) => _lowCarbs = v, (v) => _lowFat = v,
                  AppColors.info),
              const SizedBox(height: 20),
              _buildWeeklySchedule(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTDEEInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Calcular automaticamente a partir do seu TDEE. Ajuste manualmente conforme necessário.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTypeSection(
    String label,
    int calories,
    int protein,
    int carbs,
    int fat,
    Function(int) onCaloriesChanged,
    Function(int) onProteinChanged,
    Function(int) onCarbsChanged,
    Function(int) onFatChanged,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Dia $label',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const Spacer(),
                Text(
                  '$calories kcal',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMacroRow('Proteína', protein, 'g', onProteinChanged, AppColors.error),
            const SizedBox(height: 10),
            _buildMacroRow('Carboidratos', carbs, 'g', onCarbsChanged, AppColors.warning),
            const SizedBox(height: 10),
            _buildMacroRow('Gordura', fat, 'g', onFatChanged, AppColors.info),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, int value, String unit, Function(int) onChanged, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
        IconButton(
          onPressed: () {
            setState(() => onChanged(value - 5));
          },
          icon: Icon(Icons.remove_circle_outline, color: AppColors.textMuted, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            '$value$unit',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() => onChanged(value + 5));
          },
          icon: Icon(Icons.add_circle_outline, color: color, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildWeeklySchedule() {
    final days = [
      {'key': 'monday', 'label': 'Seg', 'full': 'Segunda'},
      {'key': 'tuesday', 'label': 'Ter', 'full': 'Terça'},
      {'key': 'wednesday', 'label': 'Qua', 'full': 'Quarta'},
      {'key': 'thursday', 'label': 'Qui', 'full': 'Quinta'},
      {'key': 'friday', 'label': 'Sex', 'full': 'Sexta'},
      {'key': 'saturday', 'label': 'Sáb', 'full': 'Sábado'},
      {'key': 'sunday', 'label': 'Dom', 'full': 'Domingo'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cronograma Semanal',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Toque nos dias para definir como dia de alto calorias',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) {
                final isHigh = _schedule[day['key']] ?? false;
                return GestureDetector(
                  onTap: () {
                    setState(() => _schedule[day['key'] as String] = !isHigh);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isHigh
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.surfaceLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isHigh ? AppColors.success : AppColors.surfaceLight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            day['label']!,
                            style: TextStyle(
                              color: isHigh ? AppColors.success : AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHigh ? 'Alto' : 'Normal',
                        style: TextStyle(
                          color: isHigh ? AppColors.success : AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCycle() async {
    setState(() => _isSaving = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/nutrition/calorie-cycle', data: {
        'highCalories': _highCalories,
        'mediumCalories': _mediumCalories,
        'lowCalories': _lowCalories,
        'highProtein': _highProtein,
        'highCarbs': _highCarbs,
        'highFat': _highFat,
        'mediumProtein': _mediumProtein,
        'mediumCarbs': _mediumCarbs,
        'mediumFat': _mediumFat,
        'lowProtein': _lowProtein,
        'lowCarbs': _lowCarbs,
        'lowFat': _lowFat,
        'schedule': _schedule,
      });
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Ciclo calórico salvo!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Erro ao salvar'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

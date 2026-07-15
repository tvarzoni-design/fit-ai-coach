import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class GoalsPage extends StatefulWidget {
  final Map<String, dynamic> onboardingData;
  final ValueChanged<Map<String, dynamic>> onNext;

  const GoalsPage({
    super.key,
    required this.onboardingData,
    required this.onNext,
  });

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  String? _selectedGoal;
  int _trainingDays = 3;
  final _gymNameController = TextEditingController();
  bool _hasHomeEquipment = false;
  bool _isLoading = false;

  static const _goals = [
    {'key': 'emagrecer', 'label': 'Emagrecer', 'icon': Icons.monitor_weight_outlined},
    {'key': 'hipertrofia', 'label': 'Hipertrofia', 'icon': Icons.fitness_center_outlined},
    {'key': 'definicao', 'label': 'Definição', 'icon': Icons.self_improvement_outlined},
    {'key': 'forca', 'label': 'Força', 'icon': Icons.sports_martial_arts_outlined},
    {'key': 'saude', 'label': 'Saúde', 'icon': Icons.favorite_outline},
    {'key': 'performance', 'label': 'Performance', 'icon': Icons.speed_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.onboardingData['goal'];
    _trainingDays = widget.onboardingData['trainingDays'] ?? 3;
    _gymNameController.text = widget.onboardingData['gymName'] ?? '';
    _hasHomeEquipment = widget.onboardingData['hasHomeEquipment'] ?? false;
  }

  @override
  void dispose() {
    _gymNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Qual seu objetivo?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione o que deseja alcançar',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final isSelected = goal['key'] == _selectedGoal;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGoal = goal['key'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            goal['icon'] as IconData,
                            size: 36,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            goal['label'] as String,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dias por semana',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_trainingDays dias',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceLight,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.1),
                        ),
                        child: Slider(
                          value: _trainingDays.toDouble(),
                          min: 1,
                          max: 7,
                          divisions: 6,
                          onChanged: (v) => setState(() => _trainingDays = v.round()),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text('7', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academia',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _gymNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da academia',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Equipamentos em casa',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Halteres, barras, etc.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _hasHomeEquipment,
                            onChanged: (v) => setState(() => _hasHomeEquipment = v),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _selectedGoal == null ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Próximo'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    final data = {
      ...widget.onboardingData,
      'goal': _selectedGoal,
      'trainingDays': _trainingDays,
      'gymName': _gymNameController.text.trim(),
      'hasHomeEquipment': _hasHomeEquipment,
    };
    widget.onNext(data);
  }
}

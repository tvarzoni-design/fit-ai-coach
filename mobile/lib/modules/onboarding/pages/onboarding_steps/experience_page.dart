import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ExperiencePage extends StatefulWidget {
  final Map<String, dynamic> onboardingData;
  final ValueChanged<Map<String, dynamic>> onNext;

  const ExperiencePage({
    super.key,
    required this.onboardingData,
    required this.onNext,
  });

  @override
  State<ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  String _selectedLevel = '';
  final _yearsController = TextEditingController();
  final _injuriesController = TextEditingController();
  final List<String> _selectedEquipment = [];
  bool _isLoading = false;

  static const _levels = [
    {'key': 'iniciante', 'label': 'Iniciante', 'desc': 'Menos de 6 meses treinando'},
    {'key': 'intermediario', 'label': 'Intermediário', 'desc': '6 meses a 2 anos'},
    {'key': 'avancado', 'label': 'Avançado', 'desc': 'Mais de 2 anos treinando'},
  ];

  static const _equipmentOptions = [
    'Halteres',
    'Barra e anilhas',
    'Máquinas',
    'Polia',
    'Kettlebell',
    'Elásticos',
    'Barras fixas',
    'Banco',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.onboardingData['experience'] ?? '';
    _yearsController.text = widget.onboardingData['yearsTraining']?.toString() ?? '';
    _injuriesController.text = widget.onboardingData['injuries'] ?? '';
    final saved = widget.onboardingData['equipment'];
    if (saved is List) {
      _selectedEquipment.addAll(saved.map((e) => e.toString()));
    }
  }

  @override
  void dispose() {
    _yearsController.dispose();
    _injuriesController.dispose();
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
                'Nível de experiência',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Isso define a complexidade dos treinos',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _levels.map((level) {
                  final isSelected = level['key'] == _selectedLevel;
                  return ChoiceChip(
                    label: Text(level['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    backgroundColor: AppColors.card,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                      width: isSelected ? 2 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    onSelected: (_) => setState(() => _selectedLevel = level['key']!),
                  );
                }).toList(),
              ),
              if (_selectedLevel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _levels.firstWhere((l) => l['key'] == _selectedLevel)['desc']!,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tempo treinando',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Anos treinando',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Lesões ou restrições',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _injuriesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descreva suas limitações',
                          prefixIcon: Icon(Icons.healing_outlined),
                          alignLabelWithHint: true,
                        ),
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
                        'Equipamentos disponíveis',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _equipmentOptions.map((equip) {
                          final isSelected = _selectedEquipment.contains(equip);
                          return FilterChip(
                            label: Text(equip),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withOpacity(0.15),
                            backgroundColor: AppColors.surface,
                            checkmarkColor: AppColors.primary,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            onSelected: (_) {
                              setState(() {
                                if (isSelected) {
                                  _selectedEquipment.remove(equip);
                                } else {
                                  _selectedEquipment.add(equip);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || _selectedLevel.isEmpty ? null : _handleNext,
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
      'experience': _selectedLevel,
      'yearsTraining': int.tryParse(_yearsController.text),
      'injuries': _injuriesController.text.trim(),
      'equipment': _selectedEquipment,
    };
    widget.onNext(data);
  }
}

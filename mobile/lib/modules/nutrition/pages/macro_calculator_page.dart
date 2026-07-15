import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class MacroCalculatorPage extends StatefulWidget {
  const MacroCalculatorPage({super.key});

  @override
  State<MacroCalculatorPage> createState() => _MacroCalculatorPageState();
}

class _MacroCalculatorPageState extends State<MacroCalculatorPage> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'masculino';
  String _activityLevel = 'moderado';
  String _goal = 'manter';

  double? _tdee;
  double? _protein;
  double? _carbs;
  double? _fat;

  final Map<String, String> _activityLevels = {
    'sedentario': 'Sedentário (pouco ou nenhum exercício)',
    'leve': 'Leve (1-3x/semana)',
    'moderado': 'Moderado (3-5x/semana)',
    'ativo': 'Ativo (6-7x/semana)',
    'extremamente': 'Extremamente Ativo (2x/dia)',
  };

  final Map<String, double> _activityFactors = {
    'sedentario': 1.2,
    'leve': 1.375,
    'moderado': 1.55,
    'ativo': 1.725,
    'extremamente': 1.9,
  };

  final Map<String, String> _goals = {
    'perder': 'Perder Peso (déficit)',
    'manter': 'Manter Peso',
    'ganhar': 'Ganhar Massa (superávit)',
  };

  final Map<String, double> _goalCalorieModifiers = {
    'perder': -500,
    'manter': 0,
    'ganhar': 300,
  };

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
    final age = int.tryParse(_ageCtrl.text);

    if (weight == null || height == null || age == null || weight <= 0 || height <= 0 || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente'), backgroundColor: AppColors.error),
      );
      return;
    }

    double bmr;
    if (_gender == 'masculino') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    final factor = _activityFactors[_activityLevel] ?? 1.55;
    final modifier = _goalCalorieModifiers[_goal] ?? 0;
    final tdee = (bmr * factor) + modifier;

    double protein, carbs, fat;
    if (_goal == 'perder') {
      protein = weight * 2.2;
      carbs = weight * 2.0;
      fat = weight * 0.8;
    } else if (_goal == 'ganhar') {
      protein = weight * 2.0;
      carbs = weight * 4.0;
      fat = weight * 1.0;
    } else {
      protein = weight * 1.8;
      carbs = weight * 3.0;
      fat = weight * 0.9;
    }

    setState(() {
      _tdee = tdee;
      _protein = protein;
      _carbs = carbs;
      _fat = fat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Macros'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputCard(),
            const SizedBox(height: 16),
            if (_tdee != null) ...[
              _buildResultsCard(),
              const SizedBox(height: 16),
              _buildMacroVisualBreakdown(),
              const SizedBox(height: 20),
              _buildApplyButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calculate, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text('Seus Dados', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  decoration: const InputDecoration(labelText: 'Peso (kg)', prefixIcon: Icon(Icons.monitor_weight)),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightCtrl,
                  decoration: const InputDecoration(labelText: 'Altura (cm)', prefixIcon: Icon(Icons.straighten)),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ageCtrl,
                  decoration: const InputDecoration(labelText: 'Idade', prefixIcon: Icon(Icons.cake)),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Gênero', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption('masculino', Icons.male),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption('feminino', Icons.female),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Nível de Atividade', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _activityLevel,
            items: _activityLevels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _activityLevel = v ?? 'moderado'),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.directions_run)),
            dropdownColor: AppColors.surfaceLight,
          ),
          const SizedBox(height: 16),
          Text('Objetivo', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _goal,
            items: _goals.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)))).toList(),
            onChanged: (v) => setState(() => _goal = v ?? 'manter'),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.flag)),
            dropdownColor: AppColors.surfaceLight,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calcular Macros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final selected = _gender == gender;
    return GestureDetector(
      onTap: () => setState(() => _gender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: selected ? 2 : 0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(height: 4),
            Text(gender == 'masculino' ? 'Masculino' : 'Feminino',
              style: TextStyle(color: selected ? AppColors.textPrimary : AppColors.textMuted, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
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
          Text('Seu Gasto Energético', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Text('${_tdee!.toStringAsFixed(0)}', style: TextStyle(color: AppColors.textPrimary, fontSize: 40, fontWeight: FontWeight.bold)),
          Text('kcal/dia', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 16),
          Divider(color: AppColors.surfaceLight),
          const SizedBox(height: 16),
          Text('Macros Recomendados', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroResult('Proteína', _protein!.toStringAsFixed(0), 'g', AppColors.secondary),
              _buildMacroResult('Carboidratos', _carbs!.toStringAsFixed(0), 'g', AppColors.primary),
              _buildMacroResult('Gorduras', _fat!.toStringAsFixed(0), 'g', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroResult(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22)),
              Text(unit, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildMacroVisualBreakdown() {
    final proteinCal = (_protein! * 4);
    final carbsCal = (_carbs! * 4);
    final fatCal = (_fat! * 9);
    final totalMacroCal = proteinCal + carbsCal + fatCal;

    if (totalMacroCal == 0) return const SizedBox.shrink();

    final proteinPct = (proteinCal / totalMacroCal * 100).round();
    final carbsPct = (carbsCal / totalMacroCal * 100).round();
    final fatPct = (fatCal / totalMacroCal * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribuição Visual', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 32,
              child: Row(
                children: [
                  Expanded(flex: proteinPct, child: Container(
                    color: AppColors.secondary,
                    child: Center(child: Text('${proteinPct}%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  )),
                  Expanded(flex: carbsPct, child: Container(
                    color: AppColors.primary,
                    child: Center(child: Text('${carbsPct}%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  )),
                  Expanded(flex: fatPct, child: Container(
                    color: AppColors.warning,
                    child: Center(child: Text('${fatPct}%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMacroDetailRow('Proteínas', _protein!, proteinPct, AppColors.secondary, Icons.fitness_center),
          const SizedBox(height: 8),
          _buildMacroDetailRow('Carboidratos', _carbs!, carbsPct, AppColors.primary, Icons.grain),
          const SizedBox(height: 8),
          _buildMacroDetailRow('Gorduras', _fat!, fatPct, AppColors.warning, Icons.water_drop),
          const SizedBox(height: 12),
          Divider(color: AppColors.surfaceLight),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total em calorias', style: TextStyle(color: AppColors.textSecondary)),
              Text('${totalMacroCal.toStringAsFixed(0)} kcal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDetailRow(String label, double grams, int pct, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                Text('${grams.toStringAsFixed(0)}g', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${(grams * 4).toStringAsFixed(0)} kcal', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Text('$pct%', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            final api = context.read<AuthService>().api;
            await api.updateNutritionGoals({
              'targetCalories': _tdee!.round(),
              'targetProtein': _protein!.round(),
              'targetCarbs': _carbs!.round(),
              'targetFat': _fat!.round(),
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Metas nutricionais atualizadas!'), backgroundColor: AppColors.success),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Erro ao aplicar ao plano'), backgroundColor: AppColors.error),
              );
            }
          }
        },
        icon: const Icon(Icons.check_circle),
        label: const Text('Aplicar ao Plano'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

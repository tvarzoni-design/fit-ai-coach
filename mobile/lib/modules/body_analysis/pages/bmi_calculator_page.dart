import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  double _bmi = 0;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getProfile();
      if (mounted) {
        final data = response.data ?? {};
        final weight = data['weight'] ?? data['peso'];
        final height = data['height'] ?? data['altura'];
        if (weight != null) _weightController.text = weight.toString();
        if (height != null) _heightController.text = height.toString();
        if (weight != null && height != null) _calculateBMI();
      }
    } catch (_) {}
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    if (weight != null && height != null && height > 0) {
      final heightM = height / 100;
      setState(() {
        _bmi = weight / (heightM * heightM);
        _hasCalculated = true;
      });
    } else {
      setState(() {
        _bmi = 0;
        _hasCalculated = false;
      });
    }
  }

  String get _bmiCategory {
    if (_bmi < 16) return 'Desnutrição grave';
    if (_bmi < 17) return 'Desnutrição moderada';
    if (_bmi < 18.5) return 'Abaixo do peso';
    if (_bmi < 25) return 'Peso normal';
    if (_bmi < 30) return 'Sobrepeso';
    if (_bmi < 35) return 'Obesidade grau I';
    if (_bmi < 40) return 'Obesidade grau II';
    return 'Obesidade grau III';
  }

  Color get _bmiColor {
    if (_bmi < 18.5) return AppColors.info;
    if (_bmi < 25) return AppColors.success;
    if (_bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Calculadora de IMC'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputCard(),
            const SizedBox(height: 20),
            if (_hasCalculated) ...[
              _buildResultCard(),
              const SizedBox(height: 20),
              _buildBMIGauge(),
              const SizedBox(height: 24),
              Text(
                'Tabela de Referência',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildReferenceTable(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveToProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar no Perfil'),
                ),
              ),
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
          Text(
            'Seus Dados',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateBMI(),
            decoration: InputDecoration(
              labelText: 'Peso (kg)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.monitor_weight, color: AppColors.primary),
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateBMI(),
            decoration: InputDecoration(
              labelText: 'Altura (cm)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.height, color: AppColors.primary),
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Seu IMC',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _bmi.toStringAsFixed(1),
            style: TextStyle(
              color: _bmiColor,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _bmiColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _bmiCategory,
              style: TextStyle(
                color: _bmiColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIGauge() {
    final normalizedBmi = (_bmi / 45).clamp(0.0, 1.0);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [
                    AppColors.info,
                    AppColors.success.withValues(alpha: 0.8),
                    AppColors.success,
                    AppColors.warning,
                    AppColors.error,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: (normalizedBmi * (MediaQuery.of(context).size.width - 80)) - 8,
            top: 2,
            child: Column(
              children: [
                Container(
                  width: 4,
                  height: 8,
                  color: AppColors.textPrimary,
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _bmiColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: _bmiColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceTable() {
    final ranges = [
      {'label': 'Desnutrição', 'range': '< 16.0', 'color': AppColors.info},
      {'label': 'Abaixo do peso', 'range': '16.0 - 18.5', 'color': AppColors.info},
      {'label': 'Peso normal', 'range': '18.5 - 24.9', 'color': AppColors.success},
      {'label': 'Sobrepeso', 'range': '25.0 - 29.9', 'color': AppColors.warning},
      {'label': 'Obesidade grau I', 'range': '30.0 - 34.9', 'color': AppColors.warning},
      {'label': 'Obesidade grau II', 'range': '35.0 - 39.9', 'color': AppColors.error},
      {'label': 'Obesidade grau III', 'range': '≥ 40.0', 'color': AppColors.error},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Categoria',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'IMC',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...ranges.asMap().entries.map((entry) {
            final idx = entry.key;
            final range = entry.value;
            final color = range['color'] as Color;
            final isInThisRange = _hasCalculated && _bmiCategory == range['label'];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isInThisRange ? color.withValues(alpha: 0.1) : null,
                border: Border(
                  bottom: BorderSide(
                    color: idx < ranges.length - 1 ? AppColors.surfaceLight : Colors.transparent,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          range['label'] as String,
                          style: TextStyle(
                            color: isInThisRange ? AppColors.textPrimary : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: isInThisRange ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    range['range'] as String,
                    style: TextStyle(
                      color: isInThisRange ? color : AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: isInThisRange ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isInThisRange) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check_circle, color: color, size: 16),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _saveToProfile() async {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    if (weight == null || height == null) return;

    try {
      final api = context.read<AuthService>().api;
      await api.updateProfile({
        'weight': weight,
        'height': height,
        'bmi': double.parse(_bmi.toStringAsFixed(1)),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('IMC salvo no perfil!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao salvar. Tente novamente.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}

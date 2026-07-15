import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class BodyFatCalculatorPage extends StatefulWidget {
  const BodyFatCalculatorPage({super.key});

  @override
  State<BodyFatCalculatorPage> createState() => _BodyFatCalculatorPageState();
}

class _BodyFatCalculatorPageState extends State<BodyFatCalculatorPage> {
  final _neckController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  final _heightController = TextEditingController();
  String _gender = 'masculino';
  double _bodyFat = 0;
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
        if (data['neck'] != null) _neckController.text = data['neck'].toString();
        if (data['waist'] != null) _waistController.text = data['waist'].toString();
        if (data['hip'] != null) _hipController.text = data['hip'].toString();
        if (data['height'] != null) _heightController.text = data['height'].toString();
        if (data['gender'] != null) _gender = data['gender'];
        _calculate();
      }
    } catch (_) {}
  }

  void _calculate() {
    final neck = double.tryParse(_neckController.text);
    final waist = double.tryParse(_waistController.text);
    final hip = double.tryParse(_hipController.text);
    final height = double.tryParse(_heightController.text);

    if (height == null || height <= 0) {
      setState(() {
        _bodyFat = 0;
        _hasCalculated = false;
      });
      return;
    }

    if (_gender == 'masculino') {
      if (neck == null || waist == null) {
        setState(() {
          _bodyFat = 0;
          _hasCalculated = false;
        });
        return;
      }
      // Navy method for men
      final logVal = (waist - neck) / height;
      if (logVal <= 0) {
        setState(() {
          _bodyFat = 0;
          _hasCalculated = false;
        });
        return;
      }
      final bf = 495 / (1.0324 - 0.19077 * logVal + 0.15456 * logVal * logVal) - 450;
      setState(() {
        _bodyFat = bf.clamp(2.0, 50.0);
        _hasCalculated = true;
      });
    } else {
      if (neck == null || waist == null || hip == null) {
        setState(() {
          _bodyFat = 0;
          _hasCalculated = false;
        });
        return;
      }
      // Navy method for women
      final logVal = (waist + hip - neck) / height;
      if (logVal <= 0) {
        setState(() {
          _bodyFat = 0;
          _hasCalculated = false;
        });
        return;
      }
      final bf = 495 / (1.29579 - 0.35004 * logVal + 0.22100 * logVal * logVal) - 450;
      setState(() {
        _bodyFat = bf.clamp(10.0, 50.0);
        _hasCalculated = true;
      });
    }
  }

  String get _category {
    if (_gender == 'masculino') {
      if (_bodyFat < 6) return 'Essencial';
      if (_bodyFat < 14) return 'Atleta';
      if (_bodyFat < 18) return 'Fitness';
      if (_bodyFat < 25) return 'Médio';
      return 'Obeso';
    } else {
      if (_bodyFat < 14) return 'Essencial';
      if (_bodyFat < 21) return 'Atleta';
      if (_bodyFat < 25) return 'Fitness';
      if (_bodyFat < 32) return 'Médio';
      return 'Obesa';
    }
  }

  Color get _categoryColor {
    if (_bodyFat < 14) return AppColors.info;
    if (_bodyFat < 18) return AppColors.success;
    if (_bodyFat < 25) return AppColors.primary;
    if (_bodyFat < 32) return AppColors.warning;
    return AppColors.error;
  }

  @override
  void dispose() {
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
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
        title: const Text('Calculadora de Gordura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGenderSelector(),
            const SizedBox(height: 16),
            _buildInputCard(),
            if (_hasCalculated) ...[
              const SizedBox(height: 20),
              _buildResultCard(),
              const SizedBox(height: 20),
              _buildCategoryList(),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hasCalculated ? _saveResult : null,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _gender = 'masculino';
                  _calculate();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _gender == 'masculino' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.male,
                      color: _gender == 'masculino' ? Colors.white : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Masculino',
                      style: TextStyle(
                        color: _gender == 'masculino' ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _gender = 'feminino';
                  _calculate();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _gender == 'feminino' ? AppColors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.female,
                      color: _gender == 'feminino' ? Colors.white : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Feminino',
                      style: TextStyle(
                        color: _gender == 'feminino' ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            'Medidas do Método Navy',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todas as medidas em centímetros (cm)',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculate(),
            decoration: InputDecoration(
              labelText: 'Altura (cm)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.height, color: AppColors.primary),
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _neckController,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculate(),
            decoration: InputDecoration(
              labelText: 'Pescoço (cm)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.circle, color: AppColors.primary),
              hintText: 'Medida no menor ponto',
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _waistController,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculate(),
            decoration: InputDecoration(
              labelText: 'Cintura (cm)',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.straighten, color: AppColors.primary),
              hintText: _gender == 'masculino'
                  ? 'Acima do umbigo'
                  : 'Ponto mais estreito',
            ),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          if (_gender == 'feminino') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _hipController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculate(),
              decoration: InputDecoration(
                labelText: 'Quadril (cm)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.circle_outlined, color: AppColors.secondary),
                hintText: 'Ponto mais largo',
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Gordura Corporal Estimada',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            '${_bodyFat.toStringAsFixed(1)}%',
            style: TextStyle(
              color: _categoryColor,
              fontSize: 52,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _categoryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _category,
              style: TextStyle(
                color: _categoryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _gender == 'masculino'
                ? 'Método Navy para homens'
                : 'Método Navy para mulheres',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = _gender == 'masculino'
        ? [
            {'label': 'Essencial', 'range': '2-5%', 'color': AppColors.info},
            {'label': 'Atleta', 'range': '6-13%', 'color': AppColors.success},
            {'label': 'Fitness', 'range': '14-17%', 'color': AppColors.primary},
            {'label': 'Médio', 'range': '18-24%', 'color': AppColors.warning},
            {'label': 'Obeso', 'range': '25%+', 'color': AppColors.error},
          ]
        : [
            {'label': 'Essencial', 'range': '10-13%', 'color': AppColors.info},
            {'label': 'Atleta', 'range': '14-20%', 'color': AppColors.success},
            {'label': 'Fitness', 'range': '21-24%', 'color': AppColors.primary},
            {'label': 'Médio', 'range': '25-31%', 'color': AppColors.warning},
            {'label': 'Obesa', 'range': '32%+', 'color': AppColors.error},
          ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Categorias',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...categories.map((cat) {
            final isActive = _category == cat['label'];
            final color = cat['color'] as Color;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isActive ? Border.all(color: color.withValues(alpha: 0.3)) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat['label'] as String,
                      style: TextStyle(
                        color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    cat['range'] as String,
                    style: TextStyle(
                      color: isActive ? color : AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check_circle, color: color, size: 16),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _saveResult() async {
    try {
      final api = context.read<AuthService>().api;
      await api.addMeasurement({
        'type': 'gordura_corporal',
        'value': double.parse(_bodyFat.toStringAsFixed(1)),
        'gender': _gender,
        'method': 'navy',
        'date': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gordura corporal salva!'),
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

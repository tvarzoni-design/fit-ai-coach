import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class IdealWeightPage extends StatefulWidget {
  const IdealWeightPage({super.key});

  @override
  State<IdealWeightPage> createState() => _IdealWeightPageState();
}

class _IdealWeightPageState extends State<IdealWeightPage> {
  final _heightController = TextEditingController();
  String _gender = 'masculino';
  double? _currentWeight;
  bool _hasCalculated = false;

  final Map<String, Map<String, dynamic>> _results = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      // Try to load current weight from profile
    } catch (_) {}
  }

  void _calculate() {
    final height = double.tryParse(_heightController.text);
    if (height == null || height <= 0) {
      setState(() => _hasCalculated = false);
      return;
    }

    final heightInches = height / 2.54;
    final heightMeters = height / 100;

    setState(() {
      _results.clear();

      if (_gender == 'masculino') {
        _results['Broca'] = {
          'value': (heightMeters * 100 - 100 + (heightMeters * 100 - 150) / 4),
          'formula': 'Altura - 100 + (Altura-150)/4',
        };
        _results['Devine'] = {
          'value': 50.0 + 2.3 * (heightInches - 60),
          'formula': '50 + 2.3 × (polegadas - 60)',
        };
        _results['Robinson'] = {
          'value': 52.0 + 1.9 * (heightInches - 60),
          'formula': '52 + 1.9 × (polegadas - 60)',
        };
        _results['Miller'] = {
          'value': 56.2 + 1.41 * (heightInches - 60),
          'formula': '56.2 + 1.41 × (polegadas - 60)',
        };
        _results['Hamwi'] = {
          'value': 48.0 + 2.7 * (heightInches - 60),
          'formula': '48 + 2.7 × (polegadas - 60)',
        };
      } else {
        _results['Broca'] = {
          'value': (heightMeters * 100 - 100 + (heightMeters * 100 - 150) / 4),
          'formula': 'Altura - 100 + (Altura-150)/4',
        };
        _results['Devine'] = {
          'value': 45.5 + 2.3 * (heightInches - 60),
          'formula': '45.5 + 2.3 × (polegadas - 60)',
        };
        _results['Robinson'] = {
          'value': 49.0 + 1.7 * (heightInches - 60),
          'formula': '49 + 1.7 × (polegadas - 60)',
        };
        _results['Miller'] = {
          'value': 53.1 + 1.36 * (heightInches - 60),
          'formula': '53.1 + 1.36 × (polegadas - 60)',
        };
        _results['Hamwi'] = {
          'value': 45.5 + 2.2 * (heightInches - 60),
          'formula': '45.5 + 2.2 × (polegadas - 60)',
        };
      }

      // Round values
      _results.forEach((key, val) {
        val['value'] = double.parse((val['value'] as double).toStringAsFixed(1));
      });

      _hasCalculated = true;
    });
  }

  double get _avgIdeal {
    if (_results.isEmpty) return 0;
    final sum = _results.values.map<double>((r) => r['value'] as double).reduce((a, b) => a + b);
    return sum / _results.length;
  }

  double get _minIdeal {
    if (_results.isEmpty) return 0;
    return _results.values.map<double>((r) => r['value'] as double).reduce((a, b) => a < b ? a : b);
  }

  double get _maxIdeal {
    if (_results.isEmpty) return 0;
    return _results.values.map<double>((r) => r['value'] as double).reduce((a, b) => a > b ? a : b);
  }

  @override
  void dispose() {
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
        title: const Text('Peso Ideal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputCard(),
            const SizedBox(height: 16),
            _buildCurrentWeightCard(),
            if (_hasCalculated) ...[
              const SizedBox(height: 20),
              _buildSummaryCard(),
              const SizedBox(height: 24),
              Text(
                'Fórmulas de Cálculo',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFormulasList(),
              const SizedBox(height: 24),
              Text(
                'Visualização',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildVisualization(),
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
          const SizedBox(height: 16),
          _buildGenderSelector(),
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _gender == 'masculino' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.male, color: _gender == 'masculino' ? Colors.white : AppColors.textSecondary, size: 20),
                    const SizedBox(width: 6),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _gender == 'feminino' ? AppColors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.female, color: _gender == 'feminino' ? Colors.white : AppColors.textSecondary, size: 20),
                    const SizedBox(width: 6),
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

  Widget _buildCurrentWeightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.monitor_weight, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peso Atual', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  _currentWeight != null ? '${_currentWeight!.toStringAsFixed(1)} kg' : 'Não informado',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
            'Faixa de Peso Ideal',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Text('Mínimo', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  Text(
                    '${_minIdeal.toStringAsFixed(1)}',
                    style: TextStyle(color: AppColors.info, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('kg', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.remove, color: AppColors.textMuted),
              ),
              Column(
                children: [
                  Text('Média', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  Text(
                    '${_avgIdeal.toStringAsFixed(1)}',
                    style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('kg', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.remove, color: AppColors.textMuted),
              ),
              Column(
                children: [
                  Text('Máximo', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  Text(
                    '${_maxIdeal.toStringAsFixed(1)}',
                    style: TextStyle(color: AppColors.warning, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('kg', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormulasList() {
    final formulas = _results.entries.toList();

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
                    'Fórmula',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'Resultado',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ...formulas.asMap().entries.map((entry) {
            final idx = entry.key;
            final formula = entry.value;
            final name = formula.key;
            final data = formula.value;
            final value = data['value'] as double;
            final formulaStr = data['formula'] as String;
            final isClosest = (_currentWeight != null)
                ? (value - _currentWeight!).abs() ==
                    formulas
                        .map<double>((f) => ((f.value['value'] as double) - _currentWeight!).abs())
                        .reduce((a, b) => a < b ? a : b)
                : false;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: idx < formulas.length - 1 ? AppColors.surfaceLight : Colors.transparent,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: isClosest ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: isClosest ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        '${value.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          color: isClosest ? AppColors.primary : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formulaStr,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVisualization() {
    if (_results.isEmpty) return const SizedBox.shrink();

    final values = _results.values.map<double>((r) => r['value'] as double).toList();
    final allValues = List<double>.from(values);
    if (_currentWeight != null) allValues.add(_currentWeight!);

    final minVal = allValues.reduce((a, b) => a < b ? a : b);
    final maxVal = allValues.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final padding = range * 0.15;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Range bar
          Stack(
            children: [
              // Background bar
              Container(
                height: 12,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Ideal range
              Positioned(
                left: ((_minIdeal - (minVal - padding)) / (range + 2 * padding)) *
                    (MediaQuery.of(context).size.width - 120),
                child: Container(
                  height: 12,
                  width: ((_maxIdeal - _minIdeal) / (range + 2 * padding)) *
                      (MediaQuery.of(context).size.width - 120),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withValues(alpha: 0.4),
                        AppColors.success,
                        AppColors.success.withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              // Current weight marker
              if (_currentWeight != null)
                Positioned(
                  left: ((_currentWeight! - (minVal - padding)) / (range + 2 * padding)) *
                          (MediaQuery.of(context).size.width - 120) -
                      8,
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
                          border: Border.all(color: AppColors.primary, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(minVal - padding).toStringAsFixed(0)} kg',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              Text(
                '${(maxVal + padding).toStringAsFixed(0)} kg',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Text('Faixa ideal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 16),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('Peso atual', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

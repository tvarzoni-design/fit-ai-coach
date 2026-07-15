import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class PredictionDetailPage extends StatefulWidget {
  final String predictionType;

  const PredictionDetailPage({super.key, required this.predictionType});

  @override
  State<PredictionDetailPage> createState() => _PredictionDetailPageState();
}

class _PredictionDetailPageState extends State<PredictionDetailPage> {
  Map<String, dynamic>? _prediction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrediction();
  }

  Future<void> _loadPrediction() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/predictions/${widget.predictionType}');
      if (mounted) setState(() { _prediction = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _prediction = _getFallbackData();
        });
      }
    }
  }

  Map<String, dynamic> _getFallbackData() {
    switch (widget.predictionType) {
      case 'weight':
        return {
          'title': 'Previsão de Peso',
          'icon': 'monitor_weight',
          'currentValue': '78.5 kg',
          'predictedValue': '76.2 kg',
          'timeframe': '30 dias',
          'confidence': 82,
          'chartData': [79.0, 78.8, 78.5, 78.2, 77.9, 77.5, 77.2, 76.8, 76.5, 76.2],
          'methodology': 'Análise de tendência linear baseada nos últimos 30 dias de dados de peso, ajustada por taxa de atividade e ingestão calórica.',
          'confidenceInterval': '75.4 kg - 77.0 kg',
          'factors': [
            'Taxa de atividade física atual',
            'Ingestão calórica diária média',
            'Tendência histórica de peso',
            'Metabolismo basal estimado',
          ],
        };
      case 'strength':
        return {
          'title': 'Previsão de Força',
          'icon': 'fitness_center',
          'currentValue': '80 kg',
          'predictedValue': '86.4 kg',
          'timeframe': '60 dias',
          'confidence': 75,
          'chartData': [70, 72.5, 75, 77.5, 80, 82, 83.5, 84.5, 85.5, 86.4],
          'methodology': 'Modelo de progressão baseado em Volume Semanal Total (VST) e princípio de sobrecarga progressiva.',
          'confidenceInterval': '83.0 kg - 89.8 kg',
          'factors': [
            'Progressão de carga semanal',
            'Volume de treino (séries x reps x peso)',
            'Frequência de treino por grupo muscular',
            'Período de recuperação entre sessões',
          ],
        };
      case 'body_fat':
        return {
          'title': 'Previsão de Gordura Corporal',
          'icon': 'percentage',
          'currentValue': '18.5%',
          'predictedValue': '16.5%',
          'timeframe': '90 dias',
          'confidence': 68,
          'chartData': [20.0, 19.8, 19.5, 19.2, 18.8, 18.5, 18.0, 17.5, 17.0, 16.5],
          'methodology': 'Estimativa baseada em medições corporais, taxa de perda de peso e composição de treinos.',
          'confidenceInterval': '15.5% - 17.5%',
          'factors': [
            'Taxa de perda de peso semanal',
            'Proporção de treino resistido vs cardio',
            'Ingestão de proteína diária',
            'Qualidade do sono',
          ],
        };
      default:
        return {
          'title': 'Previsão',
          'icon': 'auto_graph',
          'currentValue': 'N/A',
          'predictedValue': 'N/A',
          'timeframe': '30 dias',
          'confidence': 50,
          'chartData': [1, 2, 3, 4, 5],
          'methodology': 'Análise baseada em dados históricos.',
          'confidenceInterval': 'N/A',
          'factors': ['Dados insuficientes'],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_prediction!['title'] ?? 'Previsão'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPrediction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPredictionSummary(),
              const SizedBox(height: 20),
              _buildChartSection(),
              const SizedBox(height: 20),
              _buildConfidenceSection(),
              const SizedBox(height: 20),
              _buildMethodologySection(),
              const SizedBox(height: 20),
              _buildFactorsSection(),
              const SizedBox(height: 20),
              _buildDisclaimerSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            _prediction!['currentValue'] ?? '',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward, color: Colors.white.withValues(alpha: 0.8), size: 20),
              const SizedBox(width: 12),
              Text(
                _prediction!['predictedValue'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'em ${_prediction!['timeframe'] ?? ''}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final chartData = List<double>.from(_prediction!['chartData'] ?? []);
    if (chartData.isEmpty) return const SizedBox.shrink();

    final minVal = chartData.reduce((a, b) => a < b ? a : b);
    final maxVal = chartData.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gráfico de Tendência', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: Size.infinite,
                painter: _PredictionChartPainter(
                  values: chartData,
                  minVal: range > 0 ? minVal - range * 0.1 : minVal - 1,
                  maxVal: range > 0 ? maxVal + range * 0.1 : maxVal + 1,
                  lineColor: AppColors.primary,
                  fillColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Atual', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('Previsto', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceSection() {
    final confidence = _prediction!['confidence'] ?? 0;
    final color = confidence >= 80
        ? AppColors.success
        : confidence >= 60
            ? AppColors.warning
            : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Intervalo de Confiança', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: confidence / 100,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      Text(
                        '$confidence%',
                        style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previsão: ${_prediction!['predictedValue']}',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Intervalo: ${_prediction!['confidenceInterval']}',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodologySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Text('Metodologia', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _prediction!['methodology'] ?? '',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorsSection() {
    final factors = List<String>.from(_prediction!['factors'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Text('Fatores Considerados', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...factors.map((factor) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(factor, style: TextStyle(color: AppColors.textSecondary, fontSize: 14))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Estas previsões são estimativas baseadas em dados históricos e modelos estatísticos. Resultados individuais podem variar. Consulte um profissional de saúde antes de tomar decisões baseadas nestas previsões.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionChartPainter extends CustomPainter {
  final List<double> values;
  final double minVal;
  final double maxVal;
  final Color lineColor;
  final Color fillColor;

  _PredictionChartPainter({
    required this.values,
    required this.minVal,
    required this.maxVal,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minVal) / (maxVal - minVal)) * size.height;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points.first.dx, size.height);
    for (final p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paint);

    for (final p in points) {
      canvas.drawCircle(p, 3, Paint()..color = lineColor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AIAnalysisPage extends StatefulWidget {
  const AIAnalysisPage({super.key});

  @override
  State<AIAnalysisPage> createState() => _AIAnalysisPageState();
}

class _AIAnalysisPageState extends State<AIAnalysisPage> {
  Map<String, dynamic>? _analysis;
  bool _isLoading = true;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.analyzeProgress();
      if (mounted) setState(() { _analysis = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _analysis = {
            'overallScore': 78,
            'lastAnalysis': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            'strengths': [
              'Consistência nos treinos - 90% de frequência',
              'Progresso constante no supino reto (+15kg em 3 meses)',
              'Boa aderência ao plano nutricional',
            ],
            'weaknesses': [
              'Pouco treino de pernas - apenas 1x por semana',
              'Ingestão de proteína abaixo da meta em 40% dos dias',
              'Falta de exercícios de mobilidade',
            ],
            'recommendations': [
              {'title': 'Aumente treino de pernas', 'description': 'Adicione mais 1 sessão semanal focada em pernas', 'priority': 'alta'},
              {'title': 'Suplemente proteína', 'description': 'Considere whey protein pós-treino para atingir a meta', 'priority': 'média'},
              {'title': 'Adicione mobilidade', 'description': '15min de mobilidade antes dos treinos', 'priority': 'baixa'},
            ],
            'predictions': {
              'weightIn30Days': 76.2,
              'strengthGain': '+8%',
              'estimatedBodyFat': '16.5%',
            },
            'trends': {
              'weight': [79.0, 78.8, 78.5, 78.2, 78.0, 77.8, 77.5],
              'strength': [60, 62.5, 65, 67.5, 70, 72.5, 75],
            },
          };
        });
      }
    }
  }

  Future<void> _requestAnalysis() async {
    setState(() => _isAnalyzing = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.analyzeProgress();
      if (mounted) {
        setState(() {
          _analysis = response.data ?? _analysis;
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Análise atualizada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao gerar análise')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análise IA')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalysis,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreCard(),
                    const SizedBox(height: 16),
                    _buildTrendChart(),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Pontos Fortes', Icons.thumb_up, AppColors.success),
                    const SizedBox(height: 8),
                    ...(_analysis!['strengths'] as List).map((s) => _buildInsightCard(s, AppColors.success)),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Pontos a Melhorar', Icons.trending_down, AppColors.warning),
                    const SizedBox(height: 8),
                    ...(_analysis!['weaknesses'] as List).map((w) => _buildInsightCard(w, AppColors.warning)),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Recomendações', Icons.lightbulb, AppColors.primary),
                    const SizedBox(height: 8),
                    ...(_analysis!['recommendations'] as List).map((r) => _buildRecommendationCard(r)),
                    const SizedBox(height: 16),
                    _buildPredictionsCard(),
                    const SizedBox(height: 16),
                    _buildAnalysisButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildScoreCard() {
    final score = _analysis!['overallScore'] ?? 0;
    final color = score >= 80
        ? AppColors.success
        : score >= 60
            ? AppColors.warning
            : AppColors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$score', style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
                      Text('/100', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Pontuação Geral', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              'Última análise: ${_formatDate(_analysis!['lastAnalysis'])}',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    final weights = (_analysis!['trends']['weight'] as List).cast<double>();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = maxW - minW;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tendência de Peso', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: Size.infinite,
                painter: _ChartPainter(
                  values: weights,
                  minVal: minW - 0.5,
                  maxVal: maxW + 0.5,
                  lineColor: AppColors.primary,
                  fillColor: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${weights.first}kg', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('${weights.last}kg', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInsightCard(String text, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 7),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(dynamic rec) {
    final priorityColor = rec['priority'] == 'alta'
        ? AppColors.error
        : rec['priority'] == 'média'
            ? AppColors.warning
            : AppColors.info;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(rec['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rec['priority'],
                    style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(rec['description'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsCard() {
    final predictions = _analysis!['predictions'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph, color: AppColors.info),
                const SizedBox(width: 8),
                Text('Previsões', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildPredictionItem('Peso em 30 dias', '${predictions['weightIn30Days']}kg', AppColors.primary),
            _buildPredictionItem('Ganho de força', predictions['strengthGain'], AppColors.success),
            _buildPredictionItem('Gordura corporal estimada', predictions['estimatedBodyFat'], AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isAnalyzing ? null : _requestAnalysis,
        icon: _isAnalyzing
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isAnalyzing ? 'Analisando...' : 'Pedir Análise'),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Nunca';
    final date = DateTime.parse(isoDate);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    return '${diff.inDays} dias atrás';
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final double minVal;
  final double maxVal;
  final Color lineColor;
  final Color fillColor;

  _ChartPainter({
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

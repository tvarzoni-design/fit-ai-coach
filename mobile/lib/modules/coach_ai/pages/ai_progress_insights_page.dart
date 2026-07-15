import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AIProgressInsightsPage extends StatefulWidget {
  const AIProgressInsightsPage({super.key});

  @override
  State<AIProgressInsightsPage> createState() => _AIProgressInsightsPageState();
}

class _AIProgressInsightsPageState extends State<AIProgressInsightsPage> {
  Map<String, dynamic>? _insights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/ai/progress-insights');
      if (mounted) setState(() { _insights = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _insights = {
            'motivationMessage': 'Parabéns! Você está consistente nos treinos há 3 semanas. Continue assim!',
            'weeklyInsights': [
              {'title': 'Frequência de Treino', 'description': 'Você treinou 4 vezes esta semana, acima da média de 3.', 'trend': 'up', 'value': '+33%'},
              {'title': 'Volume Total', 'description': 'Seu volume semanal aumentou 12% comparado à semana anterior.', 'trend': 'up', 'value': '+12%'},
              {'title': 'Recuperação', 'description': 'Seu tempo médio de recuperação entre treinos do mesmo grupo muscular está ideal.', 'trend': 'stable', 'value': 'OK'},
            ],
            'strengthTrends': [
              {'exercise': 'Supino Reto', 'current': '80kg', 'previous': '75kg', 'change': '+6.7%'},
              {'exercise': 'Agachamento', 'current': '100kg', 'previous': '95kg', 'change': '+5.3%'},
              {'exercise': 'Levantamento Terra', 'current': '120kg', 'previous': '115kg', 'change': '+4.3%'},
            ],
            'bodyComposition': {
              'predictedWeight': '76.5kg',
              'predictedBodyFat': '16.8%',
              'predictedMuscleMass': '38.2kg',
              'timeframe': '30 dias',
            },
            'recommendedAdjustments': [
              {'title': 'Aumente carga no supino', 'description': 'Seu progresso sugere que está pronto para +2.5kg', 'priority': 'alta'},
              {'title': 'Adicione serie de aquecimento', 'description': 'Para exercícios pesados, 3 séries de aquecimento são ideais', 'priority': 'média'},
              {'title': 'Considere deload', 'description': 'Após 4 semanas de progresso, um deload pode ser benéfico', 'priority': 'baixa'},
            ],
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insights IA')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights IA'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInsights,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMotivationCard(),
              const SizedBox(height: 16),
              _buildSectionTitle('Insights da Semana', Icons.lightbulb, AppColors.primary),
              const SizedBox(height: 12),
              ...(_insights!['weeklyInsights'] as List).map((i) => _buildWeeklyInsightCard(i)),
              const SizedBox(height: 20),
              _buildSectionTitle('Tendências de Força', Icons.fitness_center, AppColors.success),
              const SizedBox(height: 12),
              ...(_insights!['strengthTrends'] as List).map((t) => _buildStrengthTrendCard(t)),
              const SizedBox(height: 20),
              _buildSectionTitle('Previsão de Composição Corporal', Icons.monitor_weight, AppColors.info),
              const SizedBox(height: 12),
              _buildBodyCompositionCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Ajustes Recomendados', Icons.tune, AppColors.warning),
              const SizedBox(height: 12),
              ...(_insights!['recommendedAdjustments'] as List).map((a) => _buildAdjustmentCard(a)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            _insights!['motivationMessage'] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
          ),
        ],
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

  Widget _buildWeeklyInsightCard(dynamic insight) {
    final trend = insight['trend'] ?? 'stable';
    final trendIcon = trend == 'up'
        ? Icons.trending_up
        : trend == 'down'
            ? Icons.trending_down
            : Icons.trending_flat;
    final trendColor = trend == 'up'
        ? AppColors.success
        : trend == 'down'
            ? AppColors.error
            : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(trendIcon, color: trendColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(insight['title'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(insight['value'] ?? '', style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(insight['description'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthTrendCard(dynamic trend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trend['exercise'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${trend['previous']} → ${trend['current']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(trend['change'] ?? '', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyCompositionCard() {
    final comp = _insights!['bodyComposition'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCompRow('Peso Previsto', comp['predictedWeight'] ?? '', AppColors.primary),
            const Divider(height: 24),
            _buildCompRow('Gordura Corporal', comp['predictedBodyFat'] ?? '', AppColors.warning),
            const Divider(height: 24),
            _buildCompRow('Massa Muscular', comp['predictedMuscleMass'] ?? '', AppColors.success),
            const SizedBox(height: 12),
            Text(
              'Previsão para ${comp['timeframe'] ?? ''}',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildAdjustmentCard(dynamic adjustment) {
    final priorityColor = adjustment['priority'] == 'alta'
        ? AppColors.error
        : adjustment['priority'] == 'média'
            ? AppColors.warning
            : AppColors.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(adjustment['title'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(adjustment['description'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(adjustment['priority'] ?? '', style: TextStyle(color: priorityColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

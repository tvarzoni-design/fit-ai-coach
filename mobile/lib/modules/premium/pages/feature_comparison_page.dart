import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class FeatureComparisonPage extends StatefulWidget {
  const FeatureComparisonPage({super.key});

  @override
  State<FeatureComparisonPage> createState() => _FeatureComparisonPageState();
}

class _FeatureComparisonPageState extends State<FeatureComparisonPage> {
  final _features = const [
    {'name': 'Treinos com IA', 'free': false, 'premium': true},
    {'name': 'Analytics Avançados', 'free': false, 'premium': true},
    {'name': 'Planos de Refeição Customizados', 'free': false, 'premium': true},
    {'name': 'Suporte Prioritário', 'free': false, 'premium': true},
    {'name': 'Análise Corporal com IA', 'free': false, 'premium': true},
    {'name': 'Mensagens IA Ilimitadas', 'free': false, 'premium': true},
    {'name': 'Previsões Pessoalizadas', 'free': false, 'premium': true},
    {'name': 'Treinos Básicos', 'free': true, 'premium': true},
    {'name': '10 Mensagens IA/Dia', 'free': true, 'premium': false},
    {'name': 'Nutrição Básica', 'free': true, 'premium': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparar Planos'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que está incluso?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Compare os recursos do plano gratuito e premium',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildComparisonTable(),
            const SizedBox(height: 24),
            _buildUpgradeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: AppColors.primary.withValues(alpha: 0.15),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Recurso',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Free',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Premium',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            final isLast = index == _features.length - 1;
            return _buildFeatureRow(feature, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(Map<String, dynamic> feature, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.surfaceLight.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature['name'],
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Center(
              child: feature['free']
                  ? Icon(Icons.check_circle, color: AppColors.success, size: 20)
                  : Icon(Icons.cancel, color: AppColors.textMuted, size: 20),
            ),
          ),
          Expanded(
            child: Center(
              child: feature['premium']
                  ? Icon(Icons.check_circle, color: AppColors.success, size: 20)
                  : Icon(Icons.cancel, color: AppColors.textMuted, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.workspace_premium, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'Desbloqueie Todo o Potencial',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse todos os recursos premium e acelere seus resultados',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Upgrade para Premium', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

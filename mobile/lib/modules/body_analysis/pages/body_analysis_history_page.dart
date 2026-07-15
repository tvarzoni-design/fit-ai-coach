import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class BodyAnalysisHistoryPage extends StatefulWidget {
  const BodyAnalysisHistoryPage({super.key});

  @override
  State<BodyAnalysisHistoryPage> createState() => _BodyAnalysisHistoryPageState();
}

class _BodyAnalysisHistoryPageState extends State<BodyAnalysisHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _analyses = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/body-analysis/history');
      if (mounted) {
        setState(() {
          _analyses = response.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analyses = _getMockAnalyses();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getMockAnalyses() {
    return [
      {'date': DateTime.now().subtract(const Duration(days: 0)).toIso8601String(), 'weight': 78.2, 'bodyFat': 17.8, 'muscleMass': 36.1, 'visceralFat': 8, 'bmi': 24.1},
      {'date': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(), 'weight': 79.0, 'bodyFat': 18.2, 'muscleMass': 35.8, 'visceralFat': 9, 'bmi': 24.4},
      {'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(), 'weight': 80.5, 'bodyFat': 18.8, 'muscleMass': 35.4, 'visceralFat': 9, 'bmi': 24.8},
      {'date': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(), 'weight': 82.1, 'bodyFat': 19.5, 'muscleMass': 35.0, 'visceralFat': 10, 'bmi': 25.3},
      {'date': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(), 'weight': 83.0, 'bodyFat': 20.1, 'muscleMass': 34.6, 'visceralFat': 10, 'bmi': 25.6},
      {'date': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(), 'weight': 84.2, 'bodyFat': 20.8, 'muscleMass': 34.2, 'visceralFat': 11, 'bmi': 25.9},
    ];
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '--';
    try {
      final date = DateTime.parse(isoDate);
      final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '--';
    }
  }

  Map<String, dynamic>? _getPrevious(int index) {
    if (index + 1 < _analyses.length) return _analyses[index + 1];
    return null;
  }

  String _getComparisonText(double current, double previous, {bool lowerIsBetter = false}) {
    final diff = current - previous;
    if (diff == 0) return '=';
    final sign = diff > 0 ? '+' : '';
    final isGood = lowerIsBetter ? diff < 0 : diff > 0;
    return '$sign${diff.toStringAsFixed(1)} ${isGood ? '↑' : '↓'}';
  }

  Color _getComparisonColor(double current, double previous, {bool lowerIsBetter = false}) {
    final diff = current - previous;
    if (diff == 0) return AppColors.textMuted;
    final isGood = lowerIsBetter ? diff < 0 : diff > 0;
    return isGood ? AppColors.success : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Histórico de Análise Corporal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analyses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.monitor_weight_outlined, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('Nenhuma análise registrada', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnalyses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _analyses.length,
                    itemBuilder: (context, index) => _buildAnalysisItem(index),
                  ),
                ),
    );
  }

  Widget _buildAnalysisItem(int index) {
    final analysis = _analyses[index];
    final previous = _getPrevious(index);
    final isFirst = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.primary : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: isFirst ? null : Border.all(color: AppColors.textMuted, width: 2),
                  ),
                ),
                if (index < _analyses.length - 1)
                  Expanded(child: Container(width: 1, color: AppColors.surfaceLight)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(analysis['date']?.toString()),
                            style: TextStyle(
                              color: isFirst ? AppColors.primary : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (isFirst)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Mais recente', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildMetric(
                            'Peso',
                            '${analysis['weight']} kg',
                            previous != null ? _getComparisonText(analysis['weight'].toDouble(), previous['weight'].toDouble(), lowerIsBetter: true) : null,
                            previous != null ? _getComparisonColor(analysis['weight'].toDouble(), previous['weight'].toDouble(), lowerIsBetter: true) : null,
                            AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _buildMetric(
                            'Gordura',
                            '${analysis['bodyFat']}%',
                            previous != null ? _getComparisonText(analysis['bodyFat'].toDouble(), previous['bodyFat'].toDouble(), lowerIsBetter: true) : null,
                            previous != null ? _getComparisonColor(analysis['bodyFat'].toDouble(), previous['bodyFat'].toDouble(), lowerIsBetter: true) : null,
                            AppColors.info,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMetric(
                            'Massa M.',
                            '${analysis['muscleMass']} kg',
                            previous != null ? _getComparisonText(analysis['muscleMass'].toDouble(), previous['muscleMass'].toDouble()) : null,
                            previous != null ? _getComparisonColor(analysis['muscleMass'].toDouble(), previous['muscleMass'].toDouble()) : null,
                            AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          _buildMetric(
                            'Gordura V.',
                            '${analysis['visceralFat']}',
                            previous != null ? _getComparisonText(analysis['visceralFat'].toDouble(), previous['visceralFat'].toDouble(), lowerIsBetter: true) : null,
                            previous != null ? _getComparisonColor(analysis['visceralFat'].toDouble(), previous['visceralFat'].toDouble(), lowerIsBetter: true) : null,
                            AppColors.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMetric(
                            'IMC',
                            '${analysis['bmi']}',
                            previous != null ? _getComparisonText(analysis['bmi'].toDouble(), previous['bmi'].toDouble(), lowerIsBetter: true) : null,
                            previous != null ? _getComparisonColor(analysis['bmi'].toDouble(), previous['bmi'].toDouble(), lowerIsBetter: true) : null,
                            AppColors.secondary,
                          ),
                          const Spacer(),
                          if (previous != null)
                            _buildMiniChart(analysis, previous),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, String? comparison, Color? comparisonColor, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
            if (comparison != null && comparisonColor != null) ...[
              const SizedBox(height: 2),
              Text(comparison, style: TextStyle(color: comparisonColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(dynamic current, dynamic previous) {
    final weightDiff = (current['weight'] ?? 0).toDouble() - (previous['weight'] ?? 0).toDouble();
    final bfDiff = (current['bodyFat'] ?? 0).toDouble() - (previous['bodyFat'] ?? 0).toDouble();
    final isImproving = weightDiff < 0 && bfDiff < 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isImproving ? AppColors.success.withValues(alpha: 0.12) : AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isImproving ? Icons.trending_down : Icons.trending_up,
            color: isImproving ? AppColors.success : AppColors.warning,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isImproving ? 'Melhorando' : 'Atenção',
            style: TextStyle(
              color: isImproving ? AppColors.success : AppColors.warning,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

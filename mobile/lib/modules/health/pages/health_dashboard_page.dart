import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class HealthDashboardPage extends StatefulWidget {
  const HealthDashboardPage({super.key});

  @override
  State<HealthDashboardPage> createState() => _HealthDashboardPageState();
}

class _HealthDashboardPageState extends State<HealthDashboardPage> {
  bool _isLoading = true;
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/health/metrics');
      if (mounted) {
        setState(() {
          _metrics = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _metrics = {
            'weight': {'value': 78.5, 'unit': 'kg', 'trend': 'down', 'change': -0.8},
            'bmi': {'value': 23.4, 'unit': '', 'trend': 'down', 'change': -0.3},
            'restingHeartRate': {'value': 62, 'unit': 'bpm', 'trend': 'down', 'change': -2},
            'sleepScore': {'value': 85, 'unit': '/100', 'trend': 'up', 'change': 3},
            'stressLevel': {'value': 35, 'unit': '/100', 'trend': 'down', 'change': -5},
            'hydration': {'value': 2.1, 'unit': 'L', 'trend': 'up', 'change': 0.3},
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Saúde'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadMetrics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMetricCard(
                    'Peso',
                    _metrics['weight']?['value']?.toString() ?? '--',
                    _metrics['weight']?['unit'] ?? '',
                    _metrics['weight']?['trend'],
                    _metrics['weight']?['change'],
                    Icons.monitor_weight,
                    AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    'IMC',
                    _metrics['bmi']?['value']?.toString() ?? '--',
                    _metrics['bmi']?['unit'] ?? '',
                    _metrics['bmi']?['trend'],
                    _metrics['bmi']?['change'],
                    Icons.monitor_weight,
                    AppColors.info,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    'FC em Repouso',
                    _metrics['restingHeartRate']?['value']?.toString() ?? '--',
                    _metrics['restingHeartRate']?['unit'] ?? '',
                    _metrics['restingHeartRate']?['trend'],
                    _metrics['restingHeartRate']?['change'],
                    Icons.favorite,
                    AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    'Pontuação de Sono',
                    _metrics['sleepScore']?['value']?.toString() ?? '--',
                    _metrics['sleepScore']?['unit'] ?? '',
                    _metrics['sleepScore']?['trend'],
                    _metrics['sleepScore']?['change'],
                    Icons.bedtime,
                    AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    'Nível de Estresse',
                    _metrics['stressLevel']?['value']?.toString() ?? '--',
                    _metrics['stressLevel']?['unit'] ?? '',
                    _metrics['stressLevel']?['trend'],
                    _metrics['stressLevel']?['change'],
                    Icons.psychology,
                    AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  _buildMetricCard(
                    'Hidratação',
                    _metrics['hydration']?['value']?.toString() ?? '--',
                    _metrics['hydration']?['unit'] ?? '',
                    _metrics['hydration']?['trend'],
                    _metrics['hydration']?['change'],
                    Icons.water_drop,
                    AppColors.info,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String unit,
    String? trend,
    dynamic change,
    IconData icon,
    Color color,
  ) {
    final isUp = trend == 'up';
    final isDown = trend == 'down';
    final trendColor = isUp ? AppColors.success : isDown ? AppColors.error : AppColors.textMuted;
    final trendIcon = isUp ? Icons.trending_up : isDown ? Icons.trending_down : Icons.trending_flat;
    final changeStr = change != null ? (change > 0 ? '+${change}' : '$change') : '--';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            unit,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(trendIcon, color: trendColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  changeStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

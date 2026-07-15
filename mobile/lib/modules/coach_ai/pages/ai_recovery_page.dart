import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AiRecoveryPage extends StatefulWidget {
  const AiRecoveryPage({super.key});

  @override
  State<AiRecoveryPage> createState() => _AiRecoveryPageState();
}

class _AiRecoveryPageState extends State<AiRecoveryPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _recoveryData;

  @override
  void initState() {
    super.initState();
    _loadRecoveryData();
  }

  Future<void> _loadRecoveryData() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/ai/recovery');
      if (mounted) {
        setState(() {
          _recoveryData = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recoveryData = _getMockData();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _getMockData() {
    return {
      'score': 72,
      'sleep': {
        'title': 'Sono',
        'recommendation': 'Tente dormir 7-8 horas esta noite',
        'tips': ['Evite telas 1h antes de dormir', 'Mantenha o quarto escuro e frio', 'Evite cafeína após 14h'],
      },
      'nutrition': {
        'title': 'Nutrição',
        'recommendation': 'Foque em proteínas e antioxidantes',
        'tips': ['Coma 2g de proteína por kg corporal', 'Inclua vegetais em todas as refeições', 'Hidrate-se adequadamente'],
      },
      'active_recovery': [
        {'name': 'Caminhada Leve', 'duration': '20 min', 'intensity': 'Leve', 'icon': Icons.directions_walk},
        {'name': 'Alongamento', 'duration': '15 min', 'intensity': 'Leve', 'icon': Icons.self_improvement},
        {'name': 'Yoga Restaurativo', 'duration': '30 min', 'intensity': 'Leve', 'icon': Icons.spa},
        {'name': 'Rola de Espuma', 'duration': '10 min', 'intensity': 'Leve', 'icon': Icons.fitness_center},
      ],
      'rest_day': {'recommended': true, 'reason': 'Alta fadiga acumulada detectada'},
      'hydration': {'goal': 3.0, 'current': 1.8, 'unit': 'L'},
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Recomendações de Recuperação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadRecoveryData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recoveryData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 12),
                      Text('Erro ao carregar dados', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecoveryData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScoreCard(),
                        const SizedBox(height: 20),
                        _buildSleepCard(),
                        const SizedBox(height: 12),
                        _buildNutritionCard(),
                        const SizedBox(height: 12),
                        _buildActiveRecoverySection(),
                        const SizedBox(height: 12),
                        _buildRestDayCard(),
                        const SizedBox(height: 12),
                        _buildHydrationCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildScoreCard() {
    final score = _recoveryData!['score'] as int;
    final color = score >= 70
        ? AppColors.success
        : score >= 40
            ? AppColors.warning
            : AppColors.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text('Score de Recuperação', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$score', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
                        Text('/100', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              score >= 70 ? 'Boa recuperação! Continue assim.' : score >= 40 ? 'Recuperação moderada. Considere descansar.' : 'Recuperação baixa. Priorize o descanso.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard() {
    final sleep = _recoveryData!['sleep'] as Map<String, dynamic>;
    final tips = sleep['tips'] as List<dynamic>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bedtime_outlined, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Text(sleep['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(sleep['recommendation'], style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard() {
    final nutrition = _recoveryData!['nutrition'] as Map<String, dynamic>;
    final tips = nutrition['tips'] as List<dynamic>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                Text(nutrition['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(nutrition['recommendation'], style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRecoverySection() {
    final exercises = (_recoveryData!['active_recovery'] as List).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_run, color: AppColors.warning, size: 20),
            const SizedBox(width: 8),
            Text('Exercícios de Recuperação Ativa', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ...exercises.map((ex) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Icon(ex['icon'] as IconData, color: AppColors.warning, size: 20),
            ),
            title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${ex['duration']} • ${ex['intensity']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, size: 20),
          ),
        )),
      ],
    );
  }

  Widget _buildRestDayCard() {
    final restDay = _recoveryData!['rest_day'] as Map<String, dynamic>;
    final recommended = restDay['recommended'] as bool;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (recommended ? AppColors.warning : AppColors.success).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                recommended ? Icons.hotel : Icons.fitness_center,
                color: recommended ? AppColors.warning : AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommended ? 'Dia de Descanso Recomendado' : 'Sem necessidade de descanso',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: recommended ? AppColors.warning : AppColors.success),
                  ),
                  const SizedBox(height: 4),
                  Text(restDay['reason'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHydrationCard() {
    final hydration = _recoveryData!['hydration'] as Map<String, dynamic>;
    final goal = (hydration['goal'] as num).toDouble();
    final current = (hydration['current'] as num).toDouble();
    final progress = (current / goal).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Text('Meta de Hidratação', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text('$current / $goal L', style: TextStyle(color: AppColors.info, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(progress >= 1 ? AppColors.success : AppColors.info),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).round()}% da meta atingida', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

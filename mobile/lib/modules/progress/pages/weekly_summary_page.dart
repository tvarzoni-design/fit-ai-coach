import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WeeklySummaryPage extends StatefulWidget {
  const WeeklySummaryPage({super.key});

  @override
  State<WeeklySummaryPage> createState() => _WeeklySummaryPageState();
}

class _WeeklySummaryPageState extends State<WeeklySummaryPage> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getWeeklySummary();
      if (mounted) setState(() { _summary = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _summary = {
            'weekStart': '07/07', 'weekEnd': '13/07',
            'daysTrained': 5, 'totalDuration': 345, 'totalExercises': 42,
            'weightStart': 79.2, 'weightEnd': 78.5, 'bodyFatStart': 18.5, 'bodyFatEnd': 18.2,
            'avgCalories': 2200, 'avgProtein': 145,
            'achievements': ['Sequência de 5 dias', 'Novo recorde de supino'],
            'insights': ['Você treinou 20% mais que a semana anterior. Considere aumentar a carga nos exercícios de perna.'],
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumo Semanal')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = _summary!;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo Semanal')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(data),
              const SizedBox(height: 16),
              _buildWorkoutStats(data),
              const SizedBox(height: 16),
              _buildBodyComparison(data),
              const SizedBox(height: 16),
              _buildNutritionSummary(data),
              const SizedBox(height: 16),
              _buildAchievements(data),
              const SizedBox(height: 16),
              _buildInsights(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Seg ${data['weekStart']} - Dom ${data['weekEnd']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutStats(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Treinos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('${data['daysTrained']}', 'Dias', AppColors.primary),
                _buildStat('${data['totalDuration']}', 'Minutos', AppColors.secondary),
                _buildStat('${data['totalExercises']}', 'Exercícios', AppColors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildBodyComparison(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolução Corporal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildComparisonRow('Peso', '${data['weightStart']} kg', '${data['weightEnd']} kg'),
            const SizedBox(height: 8),
            _buildComparisonRow('Gordura', '${data['bodyFatStart']}%', '${data['bodyFatEnd']}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, String start, String end) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(color: AppColors.textSecondary))),
        Text(start, style: TextStyle(color: AppColors.textMuted)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 16, color: AppColors.primary)),
        Text(end, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNutritionSummary(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nutrição', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('${data['avgCalories']}', 'Calorias Média', AppColors.warning),
                _buildStat('${data['avgProtein']}g', 'Proteína Média', AppColors.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(Map<String, dynamic> data) {
    final achievements = (data['achievements'] as List?) ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conquistas da Semana', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (achievements.isEmpty)
              Text('Nenhuma conquista esta semana', style: TextStyle(color: AppColors.textMuted)),
            ...achievements.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(a, style: const TextStyle(fontWeight: FontWeight.w500))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(Map<String, dynamic> data) {
    final insights = (data['insights'] as List?) ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Insights IA', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (insights.isEmpty)
              Text('Sem insights disponíveis', style: TextStyle(color: AppColors.textMuted)),
            ...insights.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(i, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
            )),
          ],
        ),
      ),
    );
  }
}

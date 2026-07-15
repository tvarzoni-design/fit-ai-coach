import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class MonthlySummaryPage extends StatefulWidget {
  const MonthlySummaryPage({super.key});

  @override
  State<MonthlySummaryPage> createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
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
      final response = await api.getMonthlySummary();
      if (mounted) setState(() { _summary = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _summary = {
            'month': 'Julho 2026',
            'trainingDays': [1,3,5,6,8,10,12,13,15,17,19,20,22,24,26,27,29],
            'totalWorkouts': 17, 'totalDuration': 1240, 'caloriesBurned': 8500,
            'weightStart': 80.1, 'weightEnd': 78.5, 'bodyFatStart': 19.0, 'bodyFatEnd': 18.2,
            'topExercises': [
              {'name': 'Supino Reto', 'sessions': 12},
              {'name': 'Agachamento', 'sessions': 10},
              {'name': 'Puxada Frontal', 'sessions': 9},
            ],
            'records': ['Supino: 85kg x5', 'Agachamento: 110kg x3'],
            'lastMonthWorkouts': 14, 'lastMonthDuration': 980,
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumo Mensal')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = _summary!;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumo Mensal')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthHeader(data),
              const SizedBox(height: 16),
              _buildHeatmap(data),
              const SizedBox(height: 16),
              _buildStatsCards(data),
              const SizedBox(height: 16),
              _buildBodyTrend(data),
              const SizedBox(height: 16),
              _buildTopExercises(data),
              const SizedBox(height: 16),
              _buildRecords(data),
              const SizedBox(height: 16),
              _buildMonthComparison(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(data['month'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHeatmap(Map<String, dynamic> data) {
    final days = List<int>.from(data['trainingDays'] ?? []);
    final daysInMonth = 31;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dias de Treino', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(daysInMonth, (i) {
                final day = i + 1;
                final trained = days.contains(day);
                return Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: trained ? AppColors.primary : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text('$day', style: TextStyle(
                    fontSize: 11,
                    color: trained ? Colors.white : AppColors.textMuted,
                    fontWeight: trained ? FontWeight.bold : FontWeight.normal,
                  )),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 4),
                Text('Treinou', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(width: 12),
                Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 4),
                Text('Descanso', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> data) {
    return Row(
      children: [
        _buildMiniStatCard('${data['totalWorkouts']}', 'Treinos', AppColors.primary),
        const SizedBox(width: 8),
        _buildMiniStatCard('${data['totalDuration']}min', 'Duração', AppColors.secondary),
        const SizedBox(width: 8),
        _buildMiniStatCard('${data['caloriesBurned']}', 'Calorias', AppColors.warning),
      ],
    );
  }

  Widget _buildMiniStatCard(String value, String label, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyTrend(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolução Corporal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTrendRow('Peso', '${data['weightStart']}', '${data['weightEnd']}', 'kg'),
            const SizedBox(height: 8),
            _buildTrendRow('Gordura', '${data['bodyFatStart']}', '${data['bodyFatEnd']}', '%'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendRow(String label, String start, String end, String unit) {
    final startVal = double.tryParse(start) ?? 0;
    final endVal = double.tryParse(end) ?? 0;
    final diff = endVal - startVal;
    final improved = diff < 0;

    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: TextStyle(color: AppColors.textSecondary))),
        Text('$start$unit', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Icon(Icons.arrow_forward, size: 16, color: AppColors.textMuted),
        Text(' $end$unit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (improved ? AppColors.success : AppColors.error).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}$unit',
            style: TextStyle(
              color: improved ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600, fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopExercises(Map<String, dynamic> data) {
    final exercises = (data['topExercises'] as List?) ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exercícios Mais Frequentes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...exercises.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text('${e.key + 1}', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e.value['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${e.value['sessions']}x', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecords(Map<String, dynamic> data) {
    final records = (data['records'] as List?) ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text('Recordes Pessoais', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...records.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(r, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthComparison(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comparativo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildCompRow('Treinos', '${data['lastMonthWorkouts']}', '${data['totalWorkouts']}'),
            const SizedBox(height: 8),
            _buildCompRow('Duração', '${data['lastMonthDuration']}min', '${data['totalDuration']}min'),
          ],
        ),
      ),
    );
  }

  Widget _buildCompRow(String label, String last, String current) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(color: AppColors.textSecondary))),
        Text('Mês passado: $last', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const Spacer(),
        Text('Atual: $current', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}

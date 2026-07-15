import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import 'package:provider/provider.dart';

class BodyCompositionDetailPage extends StatefulWidget {
  const BodyCompositionDetailPage({super.key});
  @override
  State<BodyCompositionDetailPage> createState() => _BodyCompositionDetailPageState();
}

class _BodyCompositionDetailPageState extends State<BodyCompositionDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getMeasurements();
      if (mounted) setState(() { _data = {'measurements': response.data ?? []}; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _data = _getMockData(); _isLoading = false; });
    }
  }

  Map<String, dynamic> _getMockData() => {
    'current': {'weight': 82.5, 'bodyFat': 18.5, 'muscleMass': 36.2, 'bmi': 25.8},
    'goal': {'weight': 78, 'bodyFat': 15, 'muscleMass': 38, 'bmi': 24.3},
    'history': [
      {'date': '2026-07-01', 'weight': 83.2, 'bodyFat': 19.0},
      {'date': '2026-07-08', 'weight': 82.8, 'bodyFat': 18.7},
      {'date': '2026-07-15', 'weight': 82.5, 'bodyFat': 18.5},
    ],
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text('Composição Corporal')), body: Center(child: CircularProgressIndicator()));
    final current = _data?['current'] ?? _getMockData()['current'];
    final goal = _data?['goal'] ?? _getMockData()['goal'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Composição Corporal'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _metricCard('Peso', '${current['weight']}kg', Icons.monitor_weight, AppColors.primary),
              const SizedBox(width: 8),
              _metricCard('Gordura', '${current['bodyFat']}%', Icons.water_drop, AppColors.secondary),
              const SizedBox(width: 8),
              _metricCard('Músculo', '${current['muscleMass']}kg', Icons.fitness_center, AppColors.success),
              const SizedBox(width: 8),
              _metricCard('IMC', '${current['bmi']}', Icons.speed, AppColors.info),
            ]),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Meta vs Atual', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _comparisonRow('Peso', '${current['weight']}kg', '${goal['weight']}kg'),
                  _comparisonRow('Gordura Corporal', '${current['bodyFat']}%', '${goal['bodyFat']}%'),
                  _comparisonRow('Massa Muscular', '${current['muscleMass']}kg', '${goal['muscleMass']}kg'),
                  _comparisonRow('IMC', '${current['bmi']}', '${goal['bmi']}'),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Histórico', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...(_data?['history'] ?? _getMockData()['history']).map<Widget>((h) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.circle, size: 8, color: AppColors.primary),
                    title: Text('${h['weight']}kg', style: TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text('${h['date']} • ${h['bodyFat']}% gordura', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/measurement/weight'),
                icon: Icon(Icons.add),
                label: Text('Adicionar Medição'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
        ]),
      ),
    ),
  );

  Widget _comparisonRow(String label, String current, String goal) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      Row(children: [
        Text(current, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        Icon(Icons.arrow_forward, size: 14, color: AppColors.textMuted),
        Text(goal, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      ]),
    ]),
  );
}

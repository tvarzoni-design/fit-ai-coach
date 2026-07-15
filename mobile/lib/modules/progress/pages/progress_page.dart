import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  Map<String, dynamic>? _measurements;
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
      final response = await api.getMeasurements();
      if (mounted) setState(() { _measurements = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _measurements = {
            'weight': 78.5, 'bodyFat': 18.2, 'muscleMass': 35.8,
            'measurements': [
              {'name': 'Peito', 'value': 102, 'unit': 'cm'},
              {'name': 'Cintura', 'value': 82, 'unit': 'cm'},
              {'name': 'Quadril', 'value': 98, 'unit': 'cm'},
              {'name': 'Braço D', 'value': 36, 'unit': 'cm'},
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
        appBar: AppBar(title: const Text('Evolução')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = _measurements!;
    final measures = data['measurements'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolução'),
        actions: [
          IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeightCard(data),
              const SizedBox(height: 16),
              _buildMeasurementsCard(measures),
              const SizedBox(height: 16),
              _buildPhotosCard(),
              const SizedBox(height: 16),
              _buildStrengthCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightCard(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peso', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeightStat('Peso Atual', '${data['weight'] ?? '--'} kg', AppColors.primary),
                _buildWeightStat('Gordura Corporal', '${data['bodyFat'] ?? '--'}%', AppColors.info),
                _buildWeightStat('Massa Muscular', '${data['muscleMass'] ?? '--'} kg', AppColors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMeasurementsCard(List measures) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medidas Corporais', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...measures.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m['name'] ?? '', style: TextStyle(color: AppColors.textSecondary)),
                  Text('${m['value']} ${m['unit']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fotos de Evolução', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Frente', 'Lado', 'Costas'].map((label) => Column(
                children: [
                  Container(
                    width: 100, height: 120,
                    decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Evolução de Força', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildStrengthExercise('Supino Reto', '60kg', '80kg', '+33%'),
            _buildStrengthExercise('Agachamento', '70kg', '100kg', '+43%'),
            _buildStrengthExercise('Puxada Frontal', '50kg', '65kg', '+30%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthExercise(String name, String firstWeight, String lastWeight, String change) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(firstWeight, style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
          Icon(Icons.arrow_forward, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Expanded(child: Text(lastWeight, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(change, style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

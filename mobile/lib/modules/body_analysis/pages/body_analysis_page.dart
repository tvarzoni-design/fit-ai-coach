import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class BodyAnalysisPage extends StatefulWidget {
  const BodyAnalysisPage({super.key});

  @override
  State<BodyAnalysisPage> createState() => _BodyAnalysisPageState();
}

class _BodyAnalysisPageState extends State<BodyAnalysisPage> {
  Map<String, dynamic>? _data;
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
      if (mounted) setState(() { _data = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Análise Corporal')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = _data ?? {};
    final weight = data['weight'] ?? 78.5;
    final bodyFat = data['bodyFat'] ?? 18.2;
    final muscleMass = data['muscleMass'] ?? 35.8;
    final height = data['height'] ?? 175;
    final bmi = height > 0 ? (weight / ((height / 100) * (height / 100))) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise Corporal'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMetricCard('Peso', '$weight kg', Icons.monitor_weight, AppColors.primary),
                  const SizedBox(width: 12),
                  _buildMetricCard('Gordura', '$bodyFat%', Icons.pie_chart, AppColors.warning),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricCard('Massa Muscular', '$muscleMass kg', Icons.fitness_center, AppColors.success),
                  const SizedBox(width: 12),
                  _buildMetricCard('IMC', '${bmi.toStringAsFixed(1)}', Icons.height, AppColors.info),
                ],
              ),
              const SizedBox(height: 24),
              Text('Adicionar Medição', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMeasurement(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Medição'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 6), Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12))]),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showAddMeasurement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nova Medição', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Gordura Corporal (%)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(decoration: const InputDecoration(labelText: 'Massa Muscular (kg)'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final api = context.read<AuthService>().api;
                  try {
                    await api.addMeasurement({});
                    Navigator.pop(context);
                    _loadData();
                  } catch (_) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar Medição'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

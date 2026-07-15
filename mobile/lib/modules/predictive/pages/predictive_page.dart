import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class PredictivePage extends StatefulWidget {
  const PredictivePage({super.key});

  @override
  State<PredictivePage> createState() => _PredictivePageState();
}

class _PredictivePageState extends State<PredictivePage> {
  Map<String, dynamic>? _predictions;
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
      final response = await api.getPredictions();
      if (mounted) setState(() { _predictions = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Predições IA')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_predictions == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Predições IA')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('Dados insuficientes para predições', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadData, child: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predições IA'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.secondary.withValues(alpha: 0.2)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.psychology, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text('Análise Pessoalizada', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Baseada no seu histórico de treinos e evolução', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_predictions!['recommendations'] != null) ...[
                Text('Recomendações da IA', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...(_predictions!['recommendations'] as List).map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(r.toString(), style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                  ]),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';

class BodyMetricsPage extends StatefulWidget {
  final Map<String, dynamic> onboardingData;
  final VoidCallback onComplete;

  const BodyMetricsPage({
    super.key,
    required this.onboardingData,
    required this.onComplete,
  });

  @override
  State<BodyMetricsPage> createState() => _BodyMetricsPageState();
}

class _BodyMetricsPageState extends State<BodyMetricsPage> {
  final _bodyFatController = TextEditingController();
  final _neckController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bodyFatController.text = widget.onboardingData['bodyFat']?.toString() ?? '';
    _neckController.text = widget.onboardingData['neck']?.toString() ?? '';
    _waistController.text = widget.onboardingData['waist']?.toString() ?? '';
    _hipController.text = widget.onboardingData['hip']?.toString() ?? '';
  }

  @override
  void dispose() {
    _bodyFatController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.onboardingData;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Métricas corporais',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Campos opcionais para melhorar sua análise',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.error)),
                ),
                const SizedBox(height: 16),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medidas corporais',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _bodyFatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Gordura corporal % (opcional)',
                          prefixIcon: Icon(Icons.pie_chart_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _neckController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pescoço (cm)',
                          prefixIcon: Icon(Icons.circle_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _waistController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cintura (cm)',
                          prefixIcon: Icon(Icons.straighten),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quadril (cm)',
                          prefixIcon: Icon(Icons.circle_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fotos corporais',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Opcional — acompanhe sua evolução visualmente',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildPhotoSlot('Frente', Icons.accessibility_new_outlined),
                          const SizedBox(width: 12),
                          _buildPhotoSlot('Lado', Icons.person_outline),
                          const SizedBox(width: 12),
                          _buildPhotoSlot('Costas', Icons.accessibility_new_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumo',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow('Nome', data['name']?.toString() ?? '—'),
                      _buildSummaryRow('Idade', data['age'] != null ? '${data['age']} anos' : '—'),
                      _buildSummaryRow('Altura', data['height'] != null ? '${data['height']} cm' : '—'),
                      _buildSummaryRow('Peso', data['weight'] != null ? '${data['weight']} kg' : '—'),
                      _buildSummaryRow('Sexo', data['sex'] == 'M' ? 'Masculino' : 'Feminino'),
                      const Divider(height: 24, color: AppColors.surfaceLight),
                      _buildSummaryRow('Objetivo', _goalLabel(data['goal'])),
                      _buildSummaryRow('Nível', _levelLabel(data['experience'])),
                      _buildSummaryRow('Dias/semana', data['trainingDays']?.toString() ?? '—'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleFinish,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Finalizar'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(String label, IconData icon) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.surfaceLight,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _goalLabel(String? key) {
    switch (key) {
      case 'emagrecer': return 'Emagrecer';
      case 'hipertrofia': return 'Hipertrofia';
      case 'definicao': return 'Definição';
      case 'forca': return 'Força';
      case 'saude': return 'Saúde';
      case 'performance': return 'Performance';
      default: return '—';
    }
  }

  String _levelLabel(String? key) {
    switch (key) {
      case 'iniciante': return 'Iniciante';
      case 'intermediario': return 'Intermediário';
      case 'avancado': return 'Avançado';
      default: return '—';
    }
  }

  Future<void> _handleFinish() async {
    setState(() { _isLoading = true; _error = null; });

    final completeData = {
      ...widget.onboardingData,
      'bodyFat': double.tryParse(_bodyFatController.text),
      'neck': double.tryParse(_neckController.text),
      'waist': double.tryParse(_waistController.text),
      'hip': double.tryParse(_hipController.text),
    };

    try {
      final auth = context.read<AuthService>();
      await auth.api.updateProfile(completeData);
      await auth.completeOnboarding();

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      try {
        final auth = context.read<AuthService>();
        await auth.completeOnboarding();
        if (!mounted) return;
        context.go('/home');
      } catch (e2) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'Erro ao salvar. Tente novamente.';
        });
      }
    }
  }
}

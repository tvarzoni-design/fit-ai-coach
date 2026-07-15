import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class TrialPage extends StatefulWidget {
  const TrialPage({super.key});

  @override
  State<TrialPage> createState() => _TrialPageState();
}

class _TrialPageState extends State<TrialPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trial Gratuito'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 32),
            _buildNoCreditCardBadge(),
            const SizedBox(height: 24),
            Text(
              'O que você ganha no trial de 7 dias:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(Icons.fitness_center, 'Treinos ilimitados com IA personalizada'),
            _buildFeatureItem(Icons.analytics, 'Analytics avançados detalhados'),
            _buildFeatureItem(Icons.restaurant_menu, 'Planos de refeição customizados'),
            _buildFeatureItem(Icons.chat, 'Mensagens IA ilimitadas'),
            _buildFeatureItem(Icons.auto_graph, 'Previsões e insights preditivos'),
            _buildFeatureItem(Icons.support_agent, 'Suporte prioritário'),
            const SizedBox(height: 24),
            _buildTermsSection(),
            const SizedBox(height: 32),
            _buildStartTrialButton(),
            const SizedBox(height: 16),
            _buildCancelInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            '7 Dias Grátis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Experimente todos os recursos premium sem compromisso',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCreditCardBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Text(
            'Não é necessário cartão de crédito',
            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Termos do Trial',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildTermItem('Trial gratuito de 7 dias a partir da ativação'),
          _buildTermItem('Acesso completo a todos os recursos premium'),
          _buildTermItem('Cancele a qualquer momento durante o trial'),
          _buildTermItem('Após o trial, cobrança automática de R\$ 24,90/mês'),
          _buildTermItem('Um trial por usuário'),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.textMuted, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStartTrialButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _startTrial,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Começar Trial Gratuito',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildCancelInfo() {
    return Center(
      child: Text(
        'Cancele quando quiser, sem penalidade',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      ),
    );
  }

  Future<void> _startTrial() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/premium/trial/start', data: {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Trial ativado com sucesso!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Erro ao ativar trial'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

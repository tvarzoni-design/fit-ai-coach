import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  List<dynamic> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getPlans();
      if (mounted) setState(() { _plans = response.data ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _plans = [
            {'id': 'free', 'name': 'Gratuito', 'price': 0, 'period': '/mês', 'features': ['Treinos básicos', '10 mensagens IA/dia', 'Nutrição básica'], 'popular': false},
            {'id': 'monthly', 'name': 'Premium Mensal', 'price': 24.90, 'period': '/mês', 'features': ['Treinos ilimitados', '100 mensagens IA/dia', 'Nutrição avançada', 'Análise corporal IA', 'Sem anúncios'], 'popular': true},
            {'id': 'annual', 'name': 'Premium Anual', 'price': 197.88, 'period': '/ano', 'features': ['Tudo do Premium Mensal', '40% de desconto', 'Suporte prioritário', 'Conteúdo exclusivo'], 'popular': false},
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Premium')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlans,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._plans.map((plan) => _buildPlanCard(plan)),
              const SizedBox(height: 24),
              _buildFAQSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(dynamic plan) {
    final features = plan['features'] as List? ?? [];
    final isPopular = plan['popular'] == true;
    final price = (plan['price'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isPopular ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(plan['name'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold))),
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 12),
          if (price > 0)
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('R\$ ${price.toStringAsFixed(2)}', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
              Text(plan['period'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ])
          else
            Text('Gratuito', style: TextStyle(color: AppColors.success, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(f, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
            ]),
          )),
          const SizedBox(height: 16),
          if (price > 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCheckout(plan),
                child: const Text('Assinar Agora'),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: Text('Plano Atual', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {'q': 'Posso cancelar a qualquer momento?', 'a': 'Sim! Cancele quando quiser, sem multa ou taxa adicional.'},
      {'q': 'Os dados da conta são preservados?', 'a': 'Sim, seus dados ficam salvos por 30 dias após o cancelamento.'},
      {'q': 'Há trial gratuito?', 'a': 'Sim! 7 dias de trial gratuito para novos assinantes.'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Perguntas Frequentes', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...faqs.map((faq) => ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(faq['q']!, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          children: [Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(faq['a']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          )],
        )),
      ],
    );
  }

  void _showCheckout(dynamic plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Confirmar Assinatura', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('${plan['name']}', style: TextStyle(color: AppColors.textSecondary)),
            Text('R\$ ${(plan['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}${plan['period']}', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assinatura ativada!'), backgroundColor: AppColors.success)); },
                child: const Text('Começar Trial Gratuito'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

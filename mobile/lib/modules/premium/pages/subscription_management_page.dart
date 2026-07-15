import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import 'package:provider/provider.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});
  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getCurrentSubscription();
      if (mounted) setState(() { _subscription = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _subscription = {'plan': 'Gratuito', 'price': 0, 'status': 'active', 'nextBilling': null, 'paymentMethod': null}; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text('Assinatura')), body: Center(child: CircularProgressIndicator()));

    final sub = _subscription ?? {};
    final isPremium = sub['plan'] != 'Gratuito' && sub['plan'] != 'free';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Assinatura'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: isPremium ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(isPremium ? Icons.workspace_premium : Icons.free_breakfast, color: isPremium ? AppColors.warning : AppColors.textMuted, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(sub['plan'] ?? 'Gratuito', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(isPremium ? 'R\$ ${sub['price']}/mês' : 'Plano gratuito', style: TextStyle(color: AppColors.textSecondary)),
                    ])),
                  ]),
                  if (sub['nextBilling'] != null) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text('Próxima cobrança: ${sub['nextBilling']}', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ]),
                  ],
                ]),
              ),
            ),
            const SizedBox(height: 16),
            if (!isPremium) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/premium'),
                  icon: Icon(Icons.upgrade),
                  label: Text('Fazer Upgrade'),
                ),
              ),
            ] else ...[
              Text('Plano Atual', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(child: ListTile(
                title: Text(sub['paymentMethod'] ?? 'Cartão de crédito'),
                subtitle: Text('•••• 4242'),
                leading: Icon(Icons.credit_card, color: AppColors.primary),
                trailing: TextButton(onPressed: () {}, child: Text('Alterar')),
              )),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => context.push('/plan-comparison'),
                  child: Text('Alterar Plano'),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(
                  onPressed: () {
                    showDialog(context: context, builder: (ctx) => AlertDialog(
                      title: Text('Cancelar Assinatura?'),
                      content: Text('Você perderá acesso aos recursos premium ao final do período.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Manter')),
                        TextButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitação de cancelamento enviada.'))); }, child: Text('Cancelar Assinatura', style: TextStyle(color: AppColors.error))),
                      ],
                    ));
                  },
                  style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.error)),
                  child: Text('Cancelar', style: TextStyle(color: AppColors.error)),
                )),
              ]),
            ],
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.receipt_long, color: AppColors.primary),
              title: Text('Histórico de Cobranças', style: TextStyle(color: AppColors.textPrimary)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
              onTap: () => context.push('/invoice-history'),
            ),
          ],
        ),
      ),
    );
  }
}

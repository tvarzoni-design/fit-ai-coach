import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class PlanComparisonPage extends StatefulWidget {
  const PlanComparisonPage({super.key});

  @override
  State<PlanComparisonPage> createState() => _PlanComparisonPageState();
}

class _PlanComparisonPageState extends State<PlanComparisonPage> {
  bool _isLoading = true;
  String _selectedBilling = 'monthly';

  final List<Map<String, dynamic>> _features = [
    {'name': 'Treinos personalizados', 'free': true, 'premium': true, 'pro': true},
    {'name': 'Histórico de treinos', 'free': true, 'premium': true, 'pro': true},
    {'name': 'Mensagens IA/dia', 'free': '10', 'premium': '100', 'pro': 'Ilimitado'},
    {'name': 'Nutrição avançada', 'free': false, 'premium': true, 'pro': true},
    {'name': 'Análise corporal IA', 'free': false, 'premium': true, 'pro': true},
    {'name': 'Planos de treino IA', 'free': false, 'premium': true, 'pro': true},
    {'name': 'Predições de evolução', 'free': false, 'premium': false, 'pro': true},
    {'name': 'Relatórios detalhados', 'free': false, 'premium': false, 'pro': true},
    {'name': 'Suporte prioritário', 'free': false, 'premium': false, 'pro': true},
    {'name': 'Sem anúncios', 'free': false, 'premium': true, 'pro': true},
    {'name': 'Conteúdo exclusivo', 'free': false, 'premium': false, 'pro': true},
    {'name': 'Exportação de dados', 'free': true, 'premium': true, 'pro': true},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Comparar Planos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparar Planos'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.secondary.withValues(alpha: 0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.diamond, color: AppColors.primary, size: 40),
                  const SizedBox(height: 12),
                  Text('Escolha o plano ideal', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Desbloqueie todo o potencial do Fit AI Coach', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedBilling = 'monthly'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedBilling == 'monthly' ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('Mensal', style: TextStyle(
                            color: _selectedBilling == 'monthly' ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          )),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedBilling = 'annual'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedBilling == 'annual' ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Anual', style: TextStyle(
                                color: _selectedBilling == 'annual' ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              )),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(6)),
                                child: Text('-40%', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowHeight: 50,
                dataRowHeight: 52,
                columnSpacing: 8,
                headingRowColor: WidgetStateProperty.all(AppColors.surface),
                dataRowColor: WidgetStateProperty.all(Colors.transparent),
                border: TableBorder(
                  horizontalInside: BorderSide(color: AppColors.surfaceLight.withValues(alpha: 0.5), width: 1),
                ),
                columns: [
                  DataColumn(label: Text('Funcionalidade', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
                  DataColumn(label: _planHeader('Gratuito', 'Grátis', AppColors.textSecondary), numeric: false),
                  DataColumn(label: _planHeader('Premium', _selectedBilling == 'monthly' ? 'R\$ 24,90/mês' : 'R\$ 197,88/ano', AppColors.primary), numeric: false),
                  DataColumn(label: _planHeader('Pro', _selectedBilling == 'monthly' ? 'R\$ 49,90/mês' : 'R\$ 398,88/ano', AppColors.secondary), numeric: false),
                ],
                rows: _features.map((f) => DataRow(cells: [
                  DataCell(Text(f['name'], style: TextStyle(color: AppColors.textPrimary, fontSize: 11))),
                  DataCell(_featureValue(f['free'])),
                  DataCell(_featureValue(f['premium'])),
                  DataCell(_featureValue(f['pro'])),
                ])).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildPlanButton('Premium', AppColors.primary, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Redirecionando para pagamento...'), backgroundColor: AppColors.primary),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPlanButton('Pro', AppColors.secondary, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Redirecionando para pagamento...'), backgroundColor: AppColors.secondary),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _planHeader(String name, String price, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(name, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(price, style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
      ],
    );
  }

  Widget _featureValue(dynamic value) {
    if (value == true) return const Icon(Icons.check_circle, color: AppColors.success, size: 18);
    if (value == false) return Icon(Icons.close, color: AppColors.textMuted.withValues(alpha: 0.5), size: 18);
    return Text('$value', style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600));
  }

  Widget _buildPlanButton(String name, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14)),
      child: Text('Escolher $name', style: const TextStyle(fontSize: 14)),
    );
  }
}

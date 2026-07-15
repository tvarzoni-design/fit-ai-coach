import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class InvoiceHistoryPage extends StatefulWidget {
  const InvoiceHistoryPage({super.key});

  @override
  State<InvoiceHistoryPage> createState() => _InvoiceHistoryPageState();
}

class _InvoiceHistoryPageState extends State<InvoiceHistoryPage> {
  String? _statusFilter;

  final List<Map<String, dynamic>> _invoices = [
    {'date': '15/06/2024', 'amount': 24.90, 'status': 'pago', 'plan': 'Premium Mensal', 'id': 'INV-2024-001'},
    {'date': '15/05/2024', 'amount': 24.90, 'status': 'pago', 'plan': 'Premium Mensal', 'id': 'INV-2024-002'},
    {'date': '15/04/2024', 'amount': 24.90, 'status': 'pago', 'plan': 'Premium Mensal', 'id': 'INV-2024-003'},
    {'date': '15/03/2024', 'amount': 0.00, 'status': 'cancelado', 'plan': 'Trial Gratuito', 'id': 'INV-2024-000'},
    {'date': '15/02/2024', 'amount': 197.88, 'status': 'pendente', 'plan': 'Premium Anual', 'id': 'INV-2024-004'},
  ];

  List<Map<String, dynamic>> get _filteredInvoices {
    if (_statusFilter == null) return _invoices;
    return _invoices.where((i) => i['status'] == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Faturas'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pagos', 'pago'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pendentes', 'pendente'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelados', 'cancelado'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _filteredInvoices.isEmpty
                ? Center(child: Text('Nenhuma fatura encontrada', style: TextStyle(color: AppColors.textMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredInvoices.length,
                    itemBuilder: (context, index) => _buildInvoiceCard(_filteredInvoices[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: AppColors.primary.withValues(alpha: 0.3),
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    Color statusColor;
    String statusLabel;
    switch (invoice['status']) {
      case 'pago':
        statusColor = AppColors.success;
        statusLabel = 'Pago';
        break;
      case 'pendente':
        statusColor = AppColors.warning;
        statusLabel = 'Pendente';
        break;
      case 'cancelado':
        statusColor = AppColors.textMuted;
        statusLabel = 'Cancelado';
        break;
      default:
        statusColor = AppColors.textMuted;
        statusLabel = invoice['status'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice['plan'], style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(invoice['id'], style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text(invoice['date'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${(invoice['amount'] as num).toStringAsFixed(2)}',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

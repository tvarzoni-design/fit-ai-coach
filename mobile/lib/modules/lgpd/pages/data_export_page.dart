import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class DataExportPage extends StatefulWidget {
  const DataExportPage({super.key});
  @override
  State<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<DataExportPage> {
  String _format = 'json';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Dados'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.download, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Exportar Meus Dados', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
                    const SizedBox(height: 8),
                    Text('Solicite uma cópia de todos os seus dados armazenados conforme o direito de portabilidade da LGPD.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Formato', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Column(children: [
                RadioListTile<String>(
                  title: Text('JSON', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: Text('Formato estruturado', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  value: 'json', groupValue: _format,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _format = v!),
                ),
                RadioListTile<String>(
                  title: Text('CSV', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: Text('Planilha Excel/Google Sheets', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  value: 'csv', groupValue: _format,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _format = v!),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  setState(() => _isLoading = true);
                  Future.delayed(Duration(seconds: 2), () {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitação enviada! Você receberá um email quando estiver pronto.')));
                  });
                },
                child: _isLoading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Solicitar Exportação'),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dados incluídos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _item('Perfil e configurações'),
                    _item('Treinos e histórico'),
                    _item('Medidas corporais'),
                    _item('Refeições registradas'),
                    _item('Conversas com IA'),
                    _item('Conquistas e progresso'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Tempo estimado: até 48 horas. Você receberá um email com o link para download.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      Icon(Icons.check, size: 14, color: AppColors.success),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    ]),
  );
}

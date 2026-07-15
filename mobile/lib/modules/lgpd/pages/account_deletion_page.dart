import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});
  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final _confirmController = TextEditingController();
  final _feedbackController = TextEditingController();
  String _reason = '';
  bool _isLoading = false;
  bool get _canDelete => _confirmController.text == 'EXCLUIR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excluir Conta'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.error.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.warning, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text('Ação Irreversível', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  const SizedBox(height: 8),
                  Text('Ao excluir sua conta, todos os seus dados serão permanentemente removidos em até 30 dias. Esta ação não pode ser desfeita.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Text('Por que está saindo?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: _reason.isEmpty ? null : _reason,
                  hint: Text('Selecione um motivo', style: TextStyle(color: AppColors.textMuted)),
                  isExpanded: true,
                  underline: SizedBox(),
                  dropdownColor: AppColors.surface,
                  items: [
                    'Não uso mais',
                    'Encontrei alternativa melhor',
                    'App tem muitos bugs',
                    'Preocupação com privacidade',
                    'Outro',
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: AppColors.textPrimary)))).toList(),
                  onChanged: (v) => setState(() => _reason = v ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Feedback (opcional)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'O que poderíamos melhorar?',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 16),
            Text('Digite "EXCLUIR" para confirmar', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'EXCLUIR',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _canDelete ? AppColors.error : AppColors.textMuted)),
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canDelete && !_isLoading ? () {
                  setState(() => _isLoading = true);
                  Future.delayed(Duration(seconds: 2), () {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitação de exclusão enviada.')));
                    context.pop();
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  disabledBackgroundColor: AppColors.error.withValues(alpha: 0.3),
                ),
                child: _isLoading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Excluir Minha Conta'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Prazo de exclusão', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('• Sua conta será desativada imediatamente\n• Dados serão excluídos em até 30 dias\n• Você receberá confirmação por email', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

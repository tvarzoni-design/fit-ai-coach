import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Conta'),
            _buildActionTile(Icons.person, 'Editar Perfil', () => context.push('/profile/edit')),
            _buildActionTile(Icons.download, 'Exportar Dados (LGPD)', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportação iniciada!')));
            }),
            _buildActionTile(Icons.delete_forever, 'Excluir Conta', () {}, isDestructive: true),
            const SizedBox(height: 24),
            _buildSectionTitle('LGPD & Privacidade'),
            _buildActionTile(Icons.privacy_tip, 'Política de Privacidade', () {}),
            _buildActionTile(Icons.gavel, 'Consentimento de Dados', () {}),
            _buildActionTile(Icons.help, 'Fale Conosco', () {}),
            const SizedBox(height: 32),
            Center(child: Text('Fit AI Coach v1.0.0', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : AppColors.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _profileVisible = true;
  bool _showActivity = true;
  bool _showMeasurements = false;
  bool _showAchievements = true;
  bool _dataConsent = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidade'),
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
                    Text('Visibilidade do Perfil', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildToggle(
                      'Perfil público',
                      'Seu perfil fica visível para outros usuários da comunidade',
                      _profileVisible,
                      (v) => setState(() => _profileVisible = v),
                    ),
                    _buildToggle(
                      'Status de atividade',
                      'Mostrar quando você está ativo no aplicativo',
                      _showActivity,
                      (v) => setState(() => _showActivity = v),
                    ),
                    _buildToggle(
                      'Medidas corporais',
                      'Compartilhar suas medidas de progresso',
                      _showMeasurements,
                      (v) => setState(() => _showMeasurements = v),
                    ),
                    _buildToggle(
                      'Conquistas',
                      'Exibir suas conquistas e medalhas',
                      _showAchievements,
                      (v) => setState(() => _showAchievements = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gavel, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('LGPD - Consentimento de Dados', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'De acordo com a Lei Geral de Proteção de Dados (LGPD), você pode consentir ou não com o uso dos seus dados pessoais para melhorias e personalização do aplicativo.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Consentir com uso de dados', style: TextStyle(color: AppColors.textPrimary)),
                      subtitle: Text('Seus dados serão usados para personalizar sua experiência', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      value: _dataConsent,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _dataConsent = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Configurações de privacidade salvas!'), backgroundColor: AppColors.success));
                  context.pop();
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

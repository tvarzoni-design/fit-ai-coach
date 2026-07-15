import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class LgpdConsentPage extends StatefulWidget {
  const LgpdConsentPage({super.key});
  @override
  State<LgpdConsentPage> createState() => _LgpdConsentPageState();
}

class _LgpdConsentPageState extends State<LgpdConsentPage> {
  Map<String, bool> _consents = {
    'marketing': false,
    'analytics': true,
    'personalization': true,
    'third_party': false,
  };

  final _consentInfo = {
    'marketing': {'title': 'Marketing', 'desc': 'Receber emails e notificações promocionais'},
    'analytics': {'title': 'Análises', 'desc': 'Ajudar a melhorar o app com dados de uso'},
    'personalization': {'title': 'Personalização', 'desc': 'Experiências e recomendações personalizadas'},
    'third_party': {'title': 'Terceiros', 'desc': 'Compartilhar dados com parceiros'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Consentimento'),
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
                      Icon(Icons.shield, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Preferências de Privacidade', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
                    const SizedBox(height: 8),
                    Text('Controle como seus dados são utilizados conforme a LGPD.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._consents.entries.map((e) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: SwitchListTile(
                title: Text(_consentInfo[e.key]!['title']!, style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(_consentInfo[e.key]!['desc']!, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                value: e.value,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _consents[e.key] = v),
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preferências salvas!')));
                  context.pop();
                },
                child: Text('Salvar Preferências'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => context.push('/privacy-policy'),
                child: Text('Ler Política de Privacidade', style: TextStyle(color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

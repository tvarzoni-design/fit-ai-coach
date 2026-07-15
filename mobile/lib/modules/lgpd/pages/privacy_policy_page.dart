import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Última atualização: 15 de julho de 2026', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            _section('1. Coleta de Dados', 'Coletamos dados que você fornece diretamente, como nome, email, peso, altura, medidas corporais e fotos. Também coletamos dados de uso do app, como treinos realizados e funcionalidades utilizadas.'),
            _section('2. Uso dos Dados', 'Seus dados são utilizados para: personalizar sua experiência de treino, gerar análises com inteligência artificial, fornecer recomendações personalizadas e melhorar a qualidade do app.'),
            _section('3. Compartilhamento', 'Não compartilhamos seus dados pessoais com terceiros, exceto quando necessário para o funcionamento do serviço (como provedores de IA) ou quando exigido por lei.'),
            _section('4. Armazenamento', 'Seus dados são armazenados em servidores seguros com criptografia. Mantemos seus dados enquanto sua conta estiver ativa ou conforme necessário para fornecer nossos serviços.'),
            _section('5. Seus Direitos', 'Conforme a LGPD, você tem direito a: acesso aos seus dados, correção, exclusão, portabilidade e revogação de consentimento.'),
            _section('6. Segurança', 'Implementamos medidas técnicas e administrativas para proteger seus dados contra acessos não autorizados, perda ou alteração.'),
            _section('7. Contato', 'Para exercer seus direitos ou esclarecer dúvidas, entre em contato: privacidade@fitai.com.br'),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(content, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
      ],
    ),
  );
}

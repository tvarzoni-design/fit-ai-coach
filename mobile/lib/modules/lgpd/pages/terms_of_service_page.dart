import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Última atualização: 15 de julho de 2026', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 16),
            _section('1. Aceitação', 'Ao utilizar o Fit AI Coach, você concorda com estes Termos de Uso. Se não concordar, não utilize o aplicativo.'),
            _section('2. Descrição do Serviço', 'O Fit AI Coach é um aplicativo de fitness que oferece treinos personalizados, acompanhamento nutricional, análise corporal e coaching por inteligência artificial.'),
            _section('3. Responsabilidades do Usuário', 'Você é responsável por: fornecer informações verdadeiras, manter a segurança de sua conta, e utilizar o app de forma adequada. Consulte um profissional de saúde antes de iniciar qualquer programa de exercícios.'),
            _section('4. Propriedade Intelectual', 'Todo o conteúdo do app, incluindo design, código, textos e gráficos, é protegido por direitos autorais e não pode ser reproduzido sem autorização.'),
            _section('5. Isenção de Responsabilidade', 'O app não substitui orientação médica ou nutricional profissional. As análises de IA são estimativas e não devem ser consideradas diagnósticos.'),
            _section('6. Limitação de Responsabilidade', 'O Fit AI Coach não se responsabiliza por lesões ou danos decorrentes do uso das informações fornecidas pelo aplicativo.'),
            _section('7. Lei Aplicável', 'Estes termos são regidos pelas leis da República Federativa do Brasil.'),
            _section('8. Contato', 'Dúvidas sobre estes termos: contato@fitai.com.br'),
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

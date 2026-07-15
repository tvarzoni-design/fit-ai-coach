import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<Map<String, String>> _faqs = [
    {'q': 'Como criar um treino personalizado?', 'a': 'Vá até a aba Treinos, clique no botão "+" no canto superior direito e preencha as informações do seu treino, incluindo exercícios, séries e repetições.'},
    {'q': 'Como o Coach IA funciona?', 'a': 'O Coach IA utiliza inteligência artificial para criar planos de treino e nutrição personalizados baseados nos seus objetivos, nível de experiência e preferências.'},
    {'q': 'Como faço para cancelar minha assinatura?', 'a': 'Acesse Configurações > Gerenciar Assinatura e clique em "Cancelar Assinatura". Você pode cancelar a qualquer momento sem multa.'},
    {'q': 'Meus dados estão seguros?', 'a': 'Sim! Seguimos rigorosamente a LGPD para proteger seus dados. Suas informações são criptografadas e nunca compartilhadas sem seu consentimento.'},
    {'q': 'Como funciona o período de trial gratuito?', 'a': 'Novos assinantes têm 7 dias de trial gratuito do Premium. Cancele antes do período acabar para não ser cobrado.'},
    {'q': 'Como exportar meus dados?', 'a': 'Acesse sua Conta nas Configurações e clique em "Exportar meus dados". Você receberá um arquivo com todas as suas informações.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda'),
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
                    Text('Perguntas Frequentes', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._faqs.map((faq) => ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(faq['q']!, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                          child: Text(faq['a']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ),
                      ],
                    )),
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
                        Icon(Icons.headset_mic, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Fale Conosco', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Não encontrou o que procurava? Entre em contato com nossa equipe de suporte.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Enviar Email'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('Chat Online'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Fit AI Coach v1.0.0',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

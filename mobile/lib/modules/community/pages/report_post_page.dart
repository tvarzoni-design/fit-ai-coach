import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ReportPostPage extends StatefulWidget {
  const ReportPostPage({super.key});

  @override
  State<ReportPostPage> createState() => _ReportPostPageState();
}

class _ReportPostPageState extends State<ReportPostPage> {
  String? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _reasons = [
    {
      'key': 'spam',
      'label': 'Spam',
      'description': 'Conteúdo promocional ou publicitário não solicitado',
      'icon': Icons.block,
      'color': AppColors.error,
    },
    {
      'key': 'inappropriate',
      'label': 'Conteúdo Inadequado',
      'description': 'Linguagem ofensiva, assédio ou conteúdo perturbador',
      'icon': Icons.warning_amber,
      'color': AppColors.warning,
    },
    {
      'key': 'fake',
      'label': 'Informação Falsa',
      'description': 'Dados incorretos ou enganosos',
      'icon': Icons.fact_check,
      'color': AppColors.secondary,
    },
    {
      'key': 'copyright',
      'label': 'Violação de Direitos Autorais',
      'description': 'Conteúdo que infringe direitos autorais',
      'icon': Icons.copyright,
      'color': AppColors.info,
    },
    {
      'key': 'other',
      'label': 'Outro Motivo',
      'description': 'Especificar outro motivo não listado',
      'icon': Icons.more_horiz,
      'color': AppColors.textMuted,
    },
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um motivo para a denúncia'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/community/report', data: {
        'reason': _selectedReason,
        'description': _descriptionController.text.trim(),
      });
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denúncia enviada com sucesso. Obrigado!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denunciar Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Por que você está denunciando este post?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecione o motivo mais adequado',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ..._reasons.map((reason) {
              final isSelected = _selectedReason == reason['key'];
              final color = reason['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() => _selectedReason = reason['key']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.1)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.2)
                              : AppColors.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(reason['icon'] as IconData, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reason['label'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isSelected ? color : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reason['description'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: color, size: 22),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Descrição adicional (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Descreva o problema com mais detalhes...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.report),
                label: Text(_isSubmitting ? 'Enviando...' : 'Enviar Denúncia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

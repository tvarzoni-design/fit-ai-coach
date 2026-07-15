import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _lembretesTreino = true;
  bool _dicasDiarias = true;
  bool _conquistas = true;
  bool _comunidade = false;
  bool _progressoSemanal = true;
  bool _promocoes = false;
  bool _quietHours = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
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
                    Text('Tipos de Notificação', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildToggle('Lembretes de Treino', 'Receba lembretes dos seus treinos agendados', _lembretesTreino, (v) => setState(() => _lembretesTreino = v)),
                    _buildToggle('Dicas Diárias', 'Dicas personalizadas de treino e nutrição', _dicasDiarias, (v) => setState(() => _dicasDiarias = v)),
                    _buildToggle('Conquistas', 'Notificações ao desbloquear conquistas', _conquistas, (v) => setState(() => _conquistas = v)),
                    _buildToggle('Comunidade', 'Interações da comunidade e novos seguidores', _comunidade, (v) => setState(() => _comunidade = v)),
                    _buildToggle('Progresso Semanal', 'Resumo semanal do seu progresso', _progressoSemanal, (v) => setState(() => _progressoSemanal = v)),
                    _buildToggle('Promoções', 'Ofertas e novidades do Fit AI Coach', _promocoes, (v) => setState(() => _promocoes = v)),
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
                    Text('Modo Não Perturbe', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Ativar horário de silêncio', style: TextStyle(color: AppColors.textPrimary)),
                      value: _quietHours,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _quietHours = v),
                    ),
                    if (_quietHours) ...[
                      const SizedBox(height: 8),
                      _buildTimeRange(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preferências salvas!'), backgroundColor: AppColors.success));
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

  Widget _buildTimeRange() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _quietStart);
              if (picked != null) setState(() => _quietStart = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('Início', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text(_quietStart.format(context), style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('até', style: TextStyle(color: AppColors.textMuted)),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _quietEnd);
              if (picked != null) setState(() => _quietEnd = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text('Fim', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text(_quietEnd.format(context), style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

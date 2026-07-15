import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class DeloadWeekPage extends StatefulWidget {
  const DeloadWeekPage({super.key});

  @override
  State<DeloadWeekPage> createState() => _DeloadWeekPageState();
}

class _DeloadWeekPageState extends State<DeloadWeekPage> {
  bool _isLoading = false;
  bool _isScheduled = false;
  int _volumeReduction = 40;
  int _intensityReduction = 30;
  String _deloadReason = '';
  String _suggestedWeek = '';

  final List<Map<String, dynamic>> _deloadInfo = [
    {
      'icon': Icons.info_outline,
      'title': 'O que é Deload?',
      'description': 'Uma semana de treino com volume e intensidade reduzidos para permitir recuperação completa.',
      'color': AppColors.info,
    },
    {
      'icon': Icons.trending_down,
      'title': 'Por que fazer Deload?',
      'description': 'Reduz fadiga acumulada, previne lesões e melhora performance nas próximas semanas.',
      'color': AppColors.warning,
    },
    {
      'icon': Icons.calendar_today,
      'title': 'Frequência',
      'description': 'Recomendado a cada 4-6 semanas de treino intenso, ou conforme sinais do corpo.',
      'color': AppColors.success,
    },
  ];

  final List<Map<String, dynamic>> _deloadGuidelines = [
    {'label': 'Volume', 'icon': Icons.view_module, 'value': '50-60%', 'detail': 'Reduza séries em 40-50%'},
    {'label': 'Intensidade', 'icon': Icons.speed, 'value': '60-70%', 'detail': 'Mantenha carga moderada'},
    {'label': 'Frequência', 'icon': Icons.calendar_month, 'value': '3-4x', 'detail': 'Treine menos dias na semana'},
    {'label': 'Descanso', 'icon': Icons.hotel, 'value': 'Extra', 'detail': 'Adicione 1-2 dias de descanso'},
  ];

  @override
  void initState() {
    super.initState();
    _checkDeloadStatus();
  }

  Future<void> _checkDeloadStatus() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/workouts/deload/status');
      if (mounted) {
        setState(() {
          _isScheduled = response.data['is_scheduled'] ?? false;
          _deloadReason = response.data['reason'] ?? '';
          _suggestedWeek = response.data['suggested_week'] ?? '';
        });
      }
    } catch (e) {
      _suggestedWeek = 'Semana atual';
    }
  }

  Future<void> _scheduleDeload() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/workouts/deload/schedule', data: {
        'volume_reduction': _volumeReduction,
        'intensity_reduction': _intensityReduction,
      });
      if (mounted) {
        setState(() => _isScheduled = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deload week agendada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao agendar deload week')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Deload Week'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),
            Text('O que é Deload?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._deloadInfo.map((info) => _buildInfoCard(info)),
            const SizedBox(height: 24),
            Text('Diretrizes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildGuidelinesGrid(),
            const SizedBox(height: 24),
            _buildSuggestionSection(),
            const SizedBox(height: 24),
            if (!_isScheduled) ...[
              Text('Ajustar Reduções', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildReductionSliders(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _isScheduled
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.surfaceLight))),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scheduleDeload,
                  icon: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.calendar_month),
                  label: const Text('Agendar Deload Week'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_isScheduled ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isScheduled ? Icons.check_circle_outline : Icons.schedule,
                color: _isScheduled ? AppColors.success : AppColors.warning,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isScheduled ? 'Deload Agendada' : 'Nenhuma Deload Agendada',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _isScheduled ? AppColors.success : AppColors.warning, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isScheduled ? (_deloadReason.isNotEmpty ? _deloadReason : 'Sua deload está programada') : 'Considere agendar uma deload',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> info) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (info['color'] as Color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(info['icon'] as IconData, color: info['color'] as Color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(info['description'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelinesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5),
      itemCount: _deloadGuidelines.length,
      itemBuilder: (context, index) {
        final guide = _deloadGuidelines[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(guide['icon'] as IconData, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(guide['label'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(guide['value'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(guide['detail'], style: TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Sugestão IA', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Baseado no seu treino recente:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(_suggestedWeek.isNotEmpty ? 'Sugerimos deload na $_suggestedWeek' : 'Analisando seus dados de treino...',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (_deloadReason.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(_deloadReason, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReductionSliders() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Redução de Volume', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('$_volumeReduction%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _volumeReduction.toDouble(),
                  min: 20,
                  max: 60,
                  divisions: 8,
                  label: '$_volumeReduction%',
                  onChanged: (v) => setState(() => _volumeReduction = v.round()),
                ),
                Text('De ${100 - _volumeReduction}% para ${100 - _volumeReduction}% do volume normal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Redução de Intensidade', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('$_intensityReduction%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _intensityReduction.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 8,
                  label: '$_intensityReduction%',
                  onChanged: (v) => setState(() => _intensityReduction = v.round()),
                ),
                Text('De ${100 - _intensityReduction}% para ${100 - _intensityReduction}% da carga normal', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

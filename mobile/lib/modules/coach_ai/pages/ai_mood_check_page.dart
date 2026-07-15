import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AiMoodCheckPage extends StatefulWidget {
  const AiMoodCheckPage({super.key});

  @override
  State<AiMoodCheckPage> createState() => _AiMoodCheckPageState();
}

class _AiMoodCheckPageState extends State<AiMoodCheckPage> {
  int _selectedMood = -1;
  double _energyLevel = 5;
  int _sleepQuality = -1;
  int _sorenessLevel = -1;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😫', 'label': 'Terrível', 'color': AppColors.error},
    {'emoji': '😐', 'label': 'Ruim', 'color': AppColors.warning},
    {'emoji': '🙂', 'label': 'Ok', 'color': AppColors.textMuted},
    {'emoji': '😊', 'label': 'Bem', 'color': AppColors.info},
    {'emoji': '🤩', 'label': 'Incrível', 'color': AppColors.success},
  ];

  final List<Map<String, dynamic>> _sleepOptions = [
    {'label': 'Muito Ruim', 'value': 1, 'icon': Icons.sentiment_very_dissatisfied, 'color': AppColors.error},
    {'label': 'Ruim', 'value': 2, 'icon': Icons.sentiment_dissatisfied, 'color': AppColors.warning},
    {'label': 'Ok', 'value': 3, 'icon': Icons.sentiment_neutral, 'color': AppColors.textMuted},
    {'label': 'Bom', 'value': 4, 'icon': Icons.sentiment_satisfied, 'color': AppColors.info},
    {'label': 'Ótimo', 'value': 5, 'icon': Icons.sentiment_very_satisfied, 'color': AppColors.success},
  ];

  final List<Map<String, dynamic>> _sorenessOptions = [
    {'label': 'Nenhuma', 'value': 1, 'color': AppColors.success},
    {'label': 'Leve', 'value': 2, 'color': AppColors.info},
    {'label': 'Moderada', 'value': 3, 'color': AppColors.warning},
    {'label': 'Alta', 'value': 4, 'color': AppColors.error},
    {'label': 'Extrema', 'value': 5, 'color': AppColors.error},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitCheckIn() async {
    if (_selectedMood == -1 || _sleepQuality == -1 || _sorenessLevel == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/ai/mood-check', data: {
        'mood': _selectedMood,
        'energy_level': _energyLevel.round(),
        'sleep_quality': _sleepQuality,
        'soreness_level': _sorenessLevel,
        'notes': _notesController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in enviado com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar check-in')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Como você está?'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodSelector(),
            const SizedBox(height: 24),
            _buildEnergySlider(),
            const SizedBox(height: 24),
            _buildSleepQuality(),
            const SizedBox(height: 24),
            _buildSorenessLevel(),
            const SizedBox(height: 24),
            _buildNotes(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Humor', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Como você se sente hoje?', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_moods.length, (index) {
            final mood = _moods[index];
            final isSelected = _selectedMood == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? (mood['color'] as Color).withValues(alpha: 0.2) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? mood['color'] as Color : Colors.transparent, width: 2),
                ),
                child: Column(
                  children: [
                    Text(mood['emoji'], style: TextStyle(fontSize: isSelected ? 32 : 28)),
                    const SizedBox(height: 4),
                    Text(mood['label'], style: TextStyle(
                      color: isSelected ? mood['color'] as Color : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEnergySlider() {
    final color = _energyLevel <= 3
        ? AppColors.error
        : _energyLevel <= 6
            ? AppColors.warning
            : AppColors.success;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text('Nível de Energia', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('${_energyLevel.round()}/10', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _energyLevel,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setState(() => _energyLevel = v),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exausto', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('Energizado', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQuality() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bedtime_outlined, color: AppColors.info, size: 20),
            const SizedBox(width: 8),
            Text('Qualidade do Sono', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Como foi seu sono ontem?', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_sleepOptions.length, (index) {
            final option = _sleepOptions[index];
            final isSelected = _sleepQuality == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _sleepQuality = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: index < _sleepOptions.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? (option['color'] as Color).withValues(alpha: 0.2) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? option['color'] as Color : Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      Icon(option['icon'] as IconData, color: isSelected ? option['color'] as Color : AppColors.textMuted, size: 24),
                      const SizedBox(height: 4),
                      Text(option['label'], style: TextStyle(
                        color: isSelected ? option['color'] as Color : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSorenessLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.healing_outlined, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Text('Dor Muscular', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Nível de soreness hoje', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_sorenessOptions.length, (index) {
            final option = _sorenessOptions[index];
            final isSelected = _sorenessLevel == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _sorenessLevel = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: index < _sorenessOptions.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? (option['color'] as Color).withValues(alpha: 0.2) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? option['color'] as Color : Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? (option['color'] as Color).withValues(alpha: 0.3) : AppColors.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${option['value']}', style: TextStyle(
                            color: isSelected ? option['color'] as Color : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(option['label'], style: TextStyle(
                        color: isSelected ? option['color'] as Color : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notes, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Notas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Algo que queira compartilhar com o coach...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitCheckIn,
        icon: _isSubmitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send),
        label: const Text('Enviar Check-in'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }
}

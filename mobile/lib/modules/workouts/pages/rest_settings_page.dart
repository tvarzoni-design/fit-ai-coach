import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class RestSettingsPage extends StatefulWidget {
  const RestSettingsPage({super.key});

  @override
  State<RestSettingsPage> createState() => _RestSettingsPageState();
}

class _RestSettingsPageState extends State<RestSettingsPage> {
  int _defaultDuration = 90;
  bool _autoStart = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  List<Map<String, dynamic>> _presets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/workouts/rest-settings');
      if (mounted) {
        final data = response.data;
        setState(() {
          _defaultDuration = data['defaultDuration'] ?? 90;
          _autoStart = data['autoStart'] ?? true;
          _soundEnabled = data['soundEnabled'] ?? true;
          _vibrationEnabled = data['vibrationEnabled'] ?? true;
          _presets = List<Map<String, dynamic>>.from(data['presets'] ?? [
            {'label': '30s', 'seconds': 30, 'enabled': true},
            {'label': '60s', 'seconds': 60, 'enabled': true},
            {'label': '90s', 'seconds': 90, 'enabled': true},
            {'label': '120s', 'seconds': 120, 'enabled': true},
            {'label': '180s', 'seconds': 180, 'enabled': true},
          ]);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _defaultDuration = 90;
          _autoStart = true;
          _soundEnabled = true;
          _vibrationEnabled = true;
          _presets = [
            {'label': '30s', 'seconds': 30, 'enabled': true},
            {'label': '60s', 'seconds': 60, 'enabled': true},
            {'label': '90s', 'seconds': 90, 'enabled': true},
            {'label': '120s', 'seconds': 120, 'enabled': true},
            {'label': '180s', 'seconds': 180, 'enabled': true},
          ];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/workouts/rest-settings', data: {
        'defaultDuration': _defaultDuration,
        'autoStart': _autoStart,
        'soundEnabled': _soundEnabled,
        'vibrationEnabled': _vibrationEnabled,
        'presets': _presets,
      });
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configurações salvas'), backgroundColor: AppColors.success),
      );
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s > 0 ? '${m}min ${s}s' : '${m}min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Descanso'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text('Salvar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDefaultDurationSection(),
                  const SizedBox(height: 16),
                  _buildBehaviorSection(),
                  const SizedBox(height: 16),
                  _buildPresetsSection(),
                  const SizedBox(height: 16),
                  _buildSoundSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('Salvar Configurações'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDefaultDurationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Duração Padrão', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _formatDuration(_defaultDuration),
                style: TextStyle(color: AppColors.primary, fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Tempo de descanso padrão', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _defaultDuration.toDouble(),
              min: 15,
              max: 300,
              divisions: 57,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceLight,
              onChanged: (v) => setState(() => _defaultDuration = v.toInt()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('15s', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text('5min', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Comportamento', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Auto-iniciar timer', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('Inicia automaticamente ao finalizar uma série', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _autoStart,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _autoStart = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Presets Rápidos', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_presets.length, (index) {
                final preset = _presets[index];
                final isEnabled = preset['enabled'] == true;
                return GestureDetector(
                  onLongPress: () => _showEditPresetDialog(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isEnabled ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isEnabled ? AppColors.primary : AppColors.surfaceLight,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          preset['label'] ?? '',
                          style: TextStyle(
                            color: isEnabled ? AppColors.primary : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isEnabled) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() => _presets[index]['enabled'] = false);
                            },
                            child: Icon(Icons.close, size: 14, color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showAddPresetDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Adicionar', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.volume_up, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Alertas', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Som', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('Reproduzir som ao final do descanso', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _soundEnabled,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _soundEnabled = v),
            ),
            Divider(color: AppColors.surfaceLight),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Vibração', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('Vibrar ao final do descanso', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _vibrationEnabled,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _vibrationEnabled = v),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPresetDialog(int index) {
    final preset = _presets[index];
    final controller = TextEditingController(text: '${preset['seconds']}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Editar Preset'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Segundos', suffixText: 's'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _presets.removeAt(index));
            },
            child: Text('Remover', style: TextStyle(color: AppColors.error)),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final seconds = int.tryParse(controller.text) ?? preset['seconds'];
              Navigator.pop(ctx);
              setState(() {
                _presets[index] = {
                  'label': _formatDuration(seconds),
                  'seconds': seconds,
                  'enabled': true,
                };
              });
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showAddPresetDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Novo Preset'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Segundos', suffixText: 's'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final seconds = int.tryParse(controller.text);
              if (seconds != null && seconds > 0) {
                Navigator.pop(ctx);
                setState(() => _presets.add({
                      'label': _formatDuration(seconds),
                      'seconds': seconds,
                      'enabled': true,
                    }));
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

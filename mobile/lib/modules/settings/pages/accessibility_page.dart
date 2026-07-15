import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  double _fontSizeScale = 1.0;
  bool _highContrast = false;
  bool _reduceAnimations = false;
  bool _screenReaderSupport = false;
  String _colorBlindMode = 'none';
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
      final response = await api.dio.get('/settings/accessibility');
      if (mounted) {
        final data = response.data;
        setState(() {
          _fontSizeScale = (data['fontSizeScale'] ?? 1.0).toDouble();
          _highContrast = data['highContrast'] ?? false;
          _reduceAnimations = data['reduceAnimations'] ?? false;
          _screenReaderSupport = data['screenReaderSupport'] ?? false;
          _colorBlindMode = data['colorBlindMode'] ?? 'none';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fontSizeScale = 1.0;
          _highContrast = false;
          _reduceAnimations = false;
          _screenReaderSupport = false;
          _colorBlindMode = 'none';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/settings/accessibility', data: {
        'fontSizeScale': _fontSizeScale,
        'highContrast': _highContrast,
        'reduceAnimations': _reduceAnimations,
        'screenReaderSupport': _screenReaderSupport,
        'colorBlindMode': _colorBlindMode,
      });
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configurações salvas'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acessibilidade'),
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
                  _buildFontSizeSection(),
                  const SizedBox(height: 16),
                  _buildVisionSection(),
                  const SizedBox(height: 16),
                  _buildAnimationSection(),
                  const SizedBox(height: 16),
                  _buildScreenReaderSection(),
                  const SizedBox(height: 16),
                  _buildColorBlindSection(),
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

  Widget _buildFontSizeSection() {
    final previewSize = 14.0 * _fontSizeScale;
    final label = _fontSizeScale <= 0.85
        ? 'Pequeno'
        : _fontSizeScale <= 1.15
            ? 'Normal'
            : _fontSizeScale <= 1.45
                ? 'Grande'
                : 'Muito Grande';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Tamanho da Fonte', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Texto de exemplo para visualização',
              style: TextStyle(color: AppColors.textPrimary, fontSize: previewSize),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.text_decrease, color: AppColors.textMuted, size: 18),
                Expanded(
                  child: Slider(
                    value: _fontSizeScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceLight,
                    onChanged: (v) => setState(() => _fontSizeScale = double.parse(v.toStringAsFixed(2))),
                  ),
                ),
                Icon(Icons.text_increase, color: AppColors.textMuted, size: 18),
              ],
            ),
            Center(
              child: Text(label, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Visão', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Alto contraste', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('Aumenta o contraste entre cores para melhor legibilidade', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _highContrast,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _highContrast = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.animation, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Animações', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Reduzir animações', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('Remove ou simplifica animações de transição', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _reduceAnimations,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _reduceAnimations = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenReaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.record_voice_over, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Leitor de Tela', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Suporte para leitor de tela', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('Melhora a navegação com TalkBack e VoiceOver', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _screenReaderSupport,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _screenReaderSupport = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorBlindSection() {
    final modes = [
      {'label': 'Nenhum', 'value': 'none', 'desc': 'Sem correção de cores'},
      {'label': 'Protanopia', 'value': 'protanopia', 'desc': 'Deficiência em vermelho'},
      {'label': 'Deuteranopia', 'value': 'deuteranopia', 'desc': 'Deficiência em verde'},
      {'label': 'Tritanopia', 'value': 'tritanopia', 'desc': 'Deficiência em azul'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Modo Daltônico', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...modes.map((mode) {
              final isSelected = _colorBlindMode == mode['value'];
              return GestureDetector(
                onTap: () => setState(() => _colorBlindMode = mode['value']!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mode['label']!, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                            Text(mode['desc']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

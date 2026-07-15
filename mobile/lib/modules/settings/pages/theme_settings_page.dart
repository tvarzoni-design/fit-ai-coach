import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  String _selectedTheme = 'Escuro';
  Color _accentColor = AppColors.primary;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _themes = [
    {'name': 'Escuro', 'icon': Icons.dark_mode, 'value': 'dark'},
    {'name': 'Claro', 'icon': Icons.light_mode, 'value': 'light'},
    {'name': 'Sistema', 'icon': Icons.phone_android, 'value': 'system'},
  ];

  final List<Color> _accentColors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.info,
    AppColors.warning,
    const Color(0xFFE91E63),
    const Color(0xFF00BCD4),
    const Color(0xFFFF5722),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/settings/theme');
      if (mounted) {
        setState(() {
          _selectedTheme = response.data['theme'] ?? 'Escuro';
          _accentColor = Color(response.data['accentColor'] ?? AppColors.primary.toARGB32());
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _apply() async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.put('/settings/theme', data: {
        'theme': _selectedTheme,
        'accentColor': _accentColor.toARGB32(),
      });
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tema atualizado!'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aparência')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._themes.map((t) {
                    final selected = _selectedTheme == t['name'];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: RadioListTile<String>(
                        value: t['name'] as String,
                        groupValue: _selectedTheme,
                        onChanged: (v) => setState(() => _selectedTheme = v!),
                        activeColor: AppColors.primary,
                        secondary: Icon(t['icon'] as IconData, color: selected ? AppColors.primary : AppColors.textMuted),
                        title: Text(t['name'] as String, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Text('Cor de Destaque', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _accentColors.map((c) {
                          final selected = _accentColor.toARGB32() == c.toARGB32();
                          return GestureDetector(
                            onTap: () => setState(() => _accentColor = c),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: selected ? Border.all(color: Colors.white, width: 3) : null,
                              ),
                              child: selected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Pré-visualização', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildPreviewCard(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: _accentColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.fitness_center, color: _accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seu Treino', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    Text('Hoje às 18:00', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.65,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('65%', style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward, color: _accentColor, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

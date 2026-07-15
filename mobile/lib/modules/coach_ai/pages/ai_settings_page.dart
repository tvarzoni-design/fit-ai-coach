import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  String _personality = 'Motivacional';
  String _language = 'Português';
  bool _autoSuggestions = true;
  String _notificationFrequency = 'Moderado';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/coach/settings');
      if (mounted) {
        final data = response.data;
        setState(() {
          _personality = data['personality'] ?? 'Motivacional';
          _language = data['language'] ?? 'Português';
          _autoSuggestions = data['autoSuggestions'] ?? true;
          _notificationFrequency = data['notificationFrequency'] ?? 'Moderado';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetMemory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Resetar Memória da IA'),
        content: const Text('Isso apagará todo o histórico de conversas e preferências aprendidas. Deseja continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Memória da IA resetada'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Resetar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações da IA')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Personalidade'),
                  _buildPersonalitySelector(),
                  const SizedBox(height: 24),
                  _buildSection('Idioma'),
                  _buildLanguageSelector(),
                  const SizedBox(height: 24),
                  _buildSection('Comportamento'),
                  _buildAutoSuggestions(),
                  const SizedBox(height: 12),
                  _buildNotificationFrequency(),
                  const SizedBox(height: 24),
                  _buildSection('Dados'),
                  _buildResetButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPersonalitySelector() {
    final personalities = [
      {'name': 'Motivacional', 'icon': Icons.psychology, 'desc': 'Sempre positivo e encorajador'},
      {'name': 'Técnico', 'icon': Icons.science, 'desc': 'Focado em dados e performance'},
      {'name': 'Amigável', 'icon': Icons.sentiment_satisfied, 'desc': 'Casual e acolhedor'},
    ];
    return Column(
      children: personalities.map((p) {
        final selected = _personality == p['name'];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (selected ? AppColors.primary : AppColors.surfaceLight).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(p['icon'] as IconData, color: selected ? AppColors.primary : AppColors.textMuted, size: 20),
            ),
            title: Text(p['name'] as String, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.w500)),
            subtitle: Text(p['desc'] as String, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            trailing: selected ? Icon(Icons.check_circle, color: AppColors.primary) : null,
            onTap: () => setState(() => _personality = p['name'] as String),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSelector() {
    final languages = ['Português', 'English', 'Español'];
    return Card(
      child: Column(
        children: languages.map((lang) {
          final selected = _language == lang;
          return RadioListTile<String>(
            value: lang,
            groupValue: _language,
            onChanged: (v) => setState(() => _language = v!),
            title: Text(lang),
            activeColor: AppColors.primary,
            secondary: selected ? Icon(Icons.check_circle, color: AppColors.primary) : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAutoSuggestions() {
    return Card(
      child: SwitchListTile(
        title: const Text('Sugestões Automáticas'),
        subtitle: Text('A IA envia sugestões proativamente', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        value: _autoSuggestions,
        onChanged: (v) => setState(() => _autoSuggestions = v),
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNotificationFrequency() {
    final freqs = ['Leve', 'Moderado', 'Intenso'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequência de Notificações', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: freqs.map((f) {
                final selected = _notificationFrequency == f;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _notificationFrequency = f),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selected ? AppColors.primary : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(f, style: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.delete_sweep, color: AppColors.error, size: 20),
        ),
        title: const Text('Resetar Memória da IA', style: TextStyle(color: AppColors.error)),
        subtitle: Text('Apaga todo o histórico aprendido', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        onTap: _resetMemory,
      ),
    );
  }
}

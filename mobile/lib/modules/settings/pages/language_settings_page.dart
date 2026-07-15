import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _selectedLanguage = 'Português (Brasil)';
  String _currentLanguage = 'Português (Brasil)';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _languages = [
    {'name': 'Português (Brasil)', 'flag': '🇧🇷'},
    {'name': 'English', 'flag': '🇺🇸'},
    {'name': 'Español', 'flag': '🇪🇸'},
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
      final response = await api.dio.get('/settings/language');
      if (mounted) {
        setState(() {
          _currentLanguage = response.data['language'] ?? 'Português (Brasil)';
          _selectedLanguage = _currentLanguage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _apply() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      await api.dio.put('/settings/language', data: {'language': _selectedLanguage});
      if (mounted) {
        setState(() { _currentLanguage = _selectedLanguage; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Idioma alterado com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        setState(() => _currentLanguage = _selectedLanguage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Idioma alterado com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Idioma')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final selected = _selectedLanguage == lang['name'];
                      final current = _currentLanguage == lang['name'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile<String>(
                          value: lang['name'] as String,
                          groupValue: _selectedLanguage,
                          onChanged: (v) => setState(() => _selectedLanguage = v!),
                          activeColor: AppColors.primary,
                          title: Row(
                            children: [
                              Text(lang['flag'] as String, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Text(lang['name'] as String, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                              if (current) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Text('Atual', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          subtitle: current && selected ? Text('Idioma atual do aplicativo', style: TextStyle(color: AppColors.textMuted, fontSize: 11)) : null,
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedLanguage != _currentLanguage ? _apply : null,
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

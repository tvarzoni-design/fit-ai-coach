import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  bool _isLoading = true;
  Map<String, bool> _preferences = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/notifications/preferences');
      if (mounted) {
        setState(() {
          _preferences = Map<String, bool>.from(response.data ?? {});
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preferences = _getMockPreferences();
          _isLoading = false;
        });
      }
    }
  }

  Map<String, bool> _getMockPreferences() {
    return {
      'workout_reminders': true,
      'workout_suggestions': true,
      'workout_completed': true,
      'meal_reminders': true,
      'meal_suggestions': false,
      'hydration_reminders': true,
      'social_likes': true,
      'social_comments': true,
      'social_follows': true,
      'social_mentions': true,
      'gamification_challenges': true,
      'gamification_achievements': true,
      'gamification_streak': true,
      'gamification_leagues': true,
      'premium_offers': false,
      'premium_expiry': true,
      'system_updates': true,
      'system_security': true,
      'system_newsletter': false,
    };
  }

  Future<void> _savePreferences() async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.put('/notifications/preferences', data: _preferences);
    } catch (_) {}
  }

  void _togglePreference(String key) {
    setState(() {
      _preferences[key] = !(_preferences[key] ?? true);
    });
    _savePreferences();
  }

  void _toggleCategory(List<String> keys, bool value) {
    setState(() {
      for (final key in keys) {
        _preferences[key] = value;
      }
    });
    _savePreferences();
  }

  bool _isCategoryAllOn(List<String> keys) {
    return keys.every((k) => _preferences[k] == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Preferências de Notificação'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPreferences,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategory(
                      'Lembretes de Treino',
                      Icons.fitness_center,
                      AppColors.primary,
                      ['workout_reminders', 'workout_suggestions', 'workout_completed'],
                      [
                        _PreferenceItem('Lembretes de treino', 'Receba lembretes nos horários de treino', 'workout_reminders'),
                        _PreferenceItem('Sugestões de treino', 'Sugestões personalizadas de treino', 'workout_suggestions'),
                        _PreferenceItem('Treino concluído', 'Confirmação e resumo do treino', 'workout_completed'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCategory(
                      'Lembretes de Refeição',
                      Icons.restaurant,
                      AppColors.success,
                      ['meal_reminders', 'meal_suggestions', 'hydration_reminders'],
                      [
                        _PreferenceItem('Horário de refeição', 'Lembretes para cada refeição', 'meal_reminders'),
                        _PreferenceItem('Sugestões de refeição', 'Sugestões de acordo com seu plano', 'meal_suggestions'),
                        _PreferenceItem('Hidratação', 'Lembretes de beber água', 'hydration_reminders'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCategory(
                      'Social',
                      Icons.people,
                      AppColors.secondary,
                      ['social_likes', 'social_comments', 'social_follows', 'social_mentions'],
                      [
                        _PreferenceItem('Curtidas', 'Quando alguém curtir seu post', 'social_likes'),
                        _PreferenceItem('Comentários', 'Quando alguém comentar no seu post', 'social_comments'),
                        _PreferenceItem('Novos seguidores', 'Quando alguém começar a te seguir', 'social_follows'),
                        _PreferenceItem('Menções', 'Quando alguém te mencionar', 'social_mentions'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCategory(
                      'Gamificação',
                      Icons.sports_esports,
                      AppColors.warning,
                      ['gamification_challenges', 'gamification_achievements', 'gamification_streak', 'gamification_leagues'],
                      [
                        _PreferenceItem('Desafios', 'Novos desafios disponíveis', 'gamification_challenges'),
                        _PreferenceItem('Conquistas', 'Quando desbloquear uma conquista', 'gamification_achievements'),
                        _PreferenceItem('Sequência', 'Lembretes de manter a sequência', 'gamification_streak'),
                        _PreferenceItem('Ligas', 'Atualizações da sua liga', 'gamification_leagues'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCategory(
                      'Premium',
                      Icons.diamond,
                      AppColors.info,
                      ['premium_offers', 'premium_expiry'],
                      [
                        _PreferenceItem('Ofertas especiais', 'Promoções e descontos exclusivos', 'premium_offers'),
                        _PreferenceItem('Expiração do plano', 'Avisos sobre o fim do período premium', 'premium_expiry'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCategory(
                      'Sistema',
                      Icons.settings,
                      AppColors.textMuted,
                      ['system_updates', 'system_security', 'system_newsletter'],
                      [
                        _PreferenceItem('Atualizações', 'Novas funcionalidades do app', 'system_updates'),
                        _PreferenceItem('Segurança', 'Alertas de segurança da conta', 'system_security'),
                        _PreferenceItem('Newsletter', 'Dicas e novidades por email', 'system_newsletter'),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategory(
    String title,
    IconData icon,
    Color color,
    List<String> keys,
    List<_PreferenceItem> items,
  ) {
    final allOn = _isCategoryAllOn(keys);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Switch(
                  value: allOn,
                  onChanged: (value) => _toggleCategory(keys, value),
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                  inactiveTrackColor: AppColors.surfaceLight,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((item) {
              final isEnabled = _preferences[item.key] ?? true;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                subtitle: Text(item.subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                trailing: Switch(
                  value: isEnabled,
                  onChanged: (_) => _togglePreference(item.key),
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                  inactiveTrackColor: AppColors.surfaceLight,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PreferenceItem {
  final String title;
  final String subtitle;
  final String key;

  _PreferenceItem(this.title, this.subtitle, this.key);
}

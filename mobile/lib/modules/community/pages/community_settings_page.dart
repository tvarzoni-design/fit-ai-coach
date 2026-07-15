import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CommunitySettingsPage extends StatefulWidget {
  const CommunitySettingsPage({super.key});

  @override
  State<CommunitySettingsPage> createState() => _CommunitySettingsPageState();
}

class _CommunitySettingsPageState extends State<CommunitySettingsPage> {
  bool _isLoading = true;
  bool _postLikes = true;
  bool _postComments = true;
  bool _newFollowers = true;
  bool _challenges = true;
  bool _leaderboardUpdates = false;
  bool _weeklyDigest = true;
  bool _muted = false;
  bool _mutedUntil = false;
  int _muteDuration = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/community/settings');
      if (mounted) {
        final data = response.data;
        setState(() {
          _postLikes = data['postLikes'] ?? true;
          _postComments = data['postComments'] ?? true;
          _newFollowers = data['newFollowers'] ?? true;
          _challenges = data['challenges'] ?? true;
          _leaderboardUpdates = data['leaderboardUpdates'] ?? false;
          _weeklyDigest = data['weeklyDigest'] ?? true;
          _muted = data['muted'] ?? false;
          _muteDuration = data['muteDuration'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.put('/community/settings', data: {key: value});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações da Comunidade'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Notificações'),
                const SizedBox(height: 8),
                _buildToggleCard(
                  'Curtidas nos Posts',
                  'Receber notificação quando alguém curtir seu post',
                  Icons.favorite,
                  AppColors.error,
                  _postLikes,
                  (v) {
                    setState(() => _postLikes = v);
                    _saveSetting('postLikes', v);
                  },
                ),
                _buildToggleCard(
                  'Comentários',
                  'Receber notificação para novos comentários',
                  Icons.comment,
                  AppColors.info,
                  _postComments,
                  (v) {
                    setState(() => _postComments = v);
                    _saveSetting('postComments', v);
                  },
                ),
                _buildToggleCard(
                  'Novos Seguidores',
                  'Notificar quando alguém começar a seguir você',
                  Icons.person_add,
                  AppColors.success,
                  _newFollowers,
                  (v) {
                    setState(() => _newFollowers = v);
                    _saveSetting('newFollowers', v);
                  },
                ),
                _buildToggleCard(
                  'Desafios',
                  'Notificações sobre desafios e competições',
                  Icons.emoji_events,
                  AppColors.warning,
                  _challenges,
                  (v) {
                    setState(() => _challenges = v);
                    _saveSetting('challenges', v);
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Resumos'),
                const SizedBox(height: 8),
                _buildToggleCard(
                  'Atualizações do Leaderboard',
                  'Receber notificação quando sua posição mudar',
                  Icons.leaderboard,
                  AppColors.primary,
                  _leaderboardUpdates,
                  (v) {
                    setState(() => _leaderboardUpdates = v);
                    _saveSetting('leaderboardUpdates', v);
                  },
                ),
                _buildToggleCard(
                  'Resumo Semanal',
                  'Receber um resumo da sua semana na comunidade',
                  Icons.calendar_today,
                  AppColors.secondary,
                  _weeklyDigest,
                  (v) {
                    setState(() => _weeklyDigest = v);
                    _saveSetting('weeklyDigest', v);
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Silenciar'),
                const SizedBox(height: 8),
                _buildMuteOptions(),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildToggleCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuteOptions() {
    final muteOptions = [
      {'label': 'Não silenciar', 'value': 0},
      {'label': '1 hora', 'value': 1},
      {'label': '8 horas', 'value': 8},
      {'label': '24 horas', 'value': 24},
      {'label': '7 dias', 'value': 168},
      {'label': '30 dias', 'value': 720},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _muted ? Icons.notifications_off : Icons.notifications,
                  color: _muted ? AppColors.warning : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Silenciar Notificações',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _muted
                            ? 'Silenciado por ${_muteDuration >= 720 ? '${(_muteDuration / 24).round()} dias' : '$_muteDuration horas'}'
                            : 'Notificações ativas',
                        style: TextStyle(
                          fontSize: 12,
                          color: _muted ? AppColors.warning : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: muteOptions.map((option) {
                final isSelected = _muteDuration == option['value'];
                final v = option['value'] as int;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _muteDuration = v;
                      _muted = v > 0;
                    });
                    _saveSetting('muteDuration', v);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      option['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
}

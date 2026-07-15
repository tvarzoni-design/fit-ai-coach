import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ChallengeSharePage extends StatefulWidget {
  const ChallengeSharePage({super.key});

  @override
  State<ChallengeSharePage> createState() => _ChallengeSharePageState();
}

class _ChallengeSharePageState extends State<ChallengeSharePage> {
  String _shareDestination = 'feed';
  final _messageController = TextEditingController();
  bool _isSharing = false;
  Map<String, dynamic>? _challenge;
  final List<String> _selectedFriends = [];

  final List<Map<String, dynamic>> _friends = [
    {'name': 'Lucas Silva', 'avatar': 'LS', 'online': true},
    {'name': 'Maria Santos', 'avatar': 'MS', 'online': true},
    {'name': 'Pedro Costa', 'avatar': 'PC', 'online': false},
    {'name': 'Ana Oliveira', 'avatar': 'AO', 'online': true},
    {'name': 'João Pereira', 'avatar': 'JP', 'online': false},
    {'name': 'Carla Lima', 'avatar': 'CL', 'online': true},
    {'name': 'Rafael Souza', 'avatar': 'RS', 'online': false},
    {'name': 'Juliana Alves', 'avatar': 'JA', 'online': true},
  ];

  final Map<String, dynamic> _mockChallenge = {
    'name': '30 Dias de Flexões',
    'description': 'Faça 100 flexões por dia durante 30 dias',
    'difficulty': 'Intermediário',
    'participants': 247,
    'daysLeft': 18,
    'progress': 40,
    'icon': Icons.fitness_center,
    'color': AppColors.primary,
  };

  @override
  void initState() {
    super.initState();
    _loadChallengeData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadChallengeData() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/gamification/challenges/share');
      if (mounted) {
        setState(() => _challenge = response.data);
      }
    } catch (e) {
      if (mounted) setState(() => _challenge = _mockChallenge);
    }
  }

  void _toggleFriend(String name) {
    setState(() {
      if (_selectedFriends.contains(name)) {
        _selectedFriends.remove(name);
      } else {
        _selectedFriends.add(name);
      }
    });
  }

  Future<void> _shareChallenge() async {
    if (_shareDestination == 'dm' && _selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um amigo')),
      );
      return;
    }

    setState(() => _isSharing = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/community/posts', data: {
        'challenge_id': _challenge?['id'],
        'destination': _shareDestination,
        'message': _messageController.text.trim(),
        'friends': _selectedFriends,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Desafio compartilhado com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao compartilhar desafio')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Compartilhar Desafio'),
      ),
      body: _challenge == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChallengePreview(),
                  const SizedBox(height: 24),
                  _buildMessageInput(),
                  const SizedBox(height: 20),
                  _buildDestinationSelector(),
                  const SizedBox(height: 16),
                  if (_shareDestination == 'dm') ...[
                    _buildFriendSelector(),
                    const SizedBox(height: 16),
                  ],
                  _buildShareButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildChallengePreview() {
    final challenge = _challenge!;
    final color = challenge['color'] as Color? ?? AppColors.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(challenge['icon'] as IconData? ?? Icons.fitness_center, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(challenge['description'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildPreviewStat(Icons.people, '${challenge['participants']} participantes'),
                const SizedBox(width: 16),
                _buildPreviewStat(Icons.calendar_today, '${challenge['daysLeft']} dias restantes'),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progresso', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text('${challenge['progress']}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (challenge['progress'] as int) / 100,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(challenge['difficulty'], style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 14),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mensagem', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Adicione uma mensagem ao compartilhar...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compartilhar para', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _shareDestination = 'feed'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _shareDestination == 'feed' ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _shareDestination == 'feed' ? AppColors.primary : Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.public, color: _shareDestination == 'feed' ? AppColors.primary : AppColors.textMuted, size: 28),
                      const SizedBox(height: 8),
                      Text('Feed', style: TextStyle(
                        color: _shareDestination == 'feed' ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                      const SizedBox(height: 2),
                      Text('Todos veem', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _shareDestination = 'dm'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _shareDestination == 'dm' ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _shareDestination == 'dm' ? AppColors.primary : Colors.transparent),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.message_outlined, color: _shareDestination == 'dm' ? AppColors.primary : AppColors.textMuted, size: 28),
                      const SizedBox(height: 8),
                      Text('Mensagem', style: TextStyle(
                        color: _shareDestination == 'dm' ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                      const SizedBox(height: 2),
                      Text('Amigos específicos', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFriendSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Selecionar Amigos', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (_selectedFriends.isNotEmpty)
              Text('${_selectedFriends.length} selecionados', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: _friends.length,
            itemBuilder: (context, index) {
              final friend = _friends[index];
              final isSelected = _selectedFriends.contains(friend['name']);
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                        child: Text(friend['avatar'], style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )),
                      ),
                      if (friend['online'])
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, border: Border.all(color: AppColors.card, width: 2)),
                          ),
                        ),
                    ],
                  ),
                  title: Text(friend['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  ),
                  onTap: () => _toggleFriend(friend['name']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSharing ? null : _shareChallenge,
        icon: _isSharing
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.share),
        label: const Text('Compartilhar Desafio'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }
}

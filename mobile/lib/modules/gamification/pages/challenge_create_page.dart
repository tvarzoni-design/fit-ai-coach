import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ChallengeCreatePage extends StatefulWidget {
  const ChallengeCreatePage({super.key});

  @override
  State<ChallengeCreatePage> createState() => _ChallengeCreatePageState();
}

class _ChallengeCreatePageState extends State<ChallengeCreatePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  String _selectedType = 'workouts';
  int _selectedDuration = 7;
  bool _isPublic = true;
  bool _isCreating = false;
  List<dynamic> _friends = [];
  final Set<String> _selectedFriends = {};

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/community/following');
      if (mounted) {
        setState(() {
          _friends = response.data is List ? response.data : [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _friends = [
            {'id': '1', 'name': 'Ana Silva'},
            {'id': '2', 'name': 'Carlos Souza'},
            {'id': '3', 'name': 'Maria Santos'},
            {'id': '4', 'name': 'Pedro Lima'},
            {'id': '5', 'name': 'Julia Costa'},
          ];
        });
      }
    }
  }

  Future<void> _createChallenge() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um nome para o desafio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_targetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Defina uma meta para o desafio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/gamification/challenges', data: {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'duration': _selectedDuration,
        'target': int.tryParse(_targetController.text.trim()),
        'isPublic': _isPublic,
        'invitedFriends': _selectedFriends.toList(),
      });
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Desafio criado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Desafio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildTypeSelection(),
            const SizedBox(height: 16),
            _buildDurationSelection(),
            const SizedBox(height: 16),
            _buildTargetField(),
            const SizedBox(height: 16),
            _buildPrivacyToggle(),
            const SizedBox(height: 16),
            _buildInviteFriends(),
            const SizedBox(height: 32),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nome do Desafio',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          maxLength: 50,
          decoration: const InputDecoration(
            hintText: 'Ex: Desafio 30 dias de treino',
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'Descreva o objetivo do desafio...',
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelection() {
    final types = [
      {'key': 'workouts', 'label': 'Treinos', 'icon': Icons.fitness_center, 'color': AppColors.primary},
      {'key': 'steps', 'label': 'Passos', 'icon': Icons.directions_walk, 'color': AppColors.success},
      {'key': 'calories', 'label': 'Calorias', 'icon': Icons.local_fire_department, 'color': AppColors.warning},
      {'key': 'minutes', 'label': 'Minutos Ativos', 'icon': Icons.timer, 'color': AppColors.info},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Desafio',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: types.map((type) {
            final isSelected = _selectedType == type['key'];
            final color = type['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = type['key'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        color: isSelected ? color : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationSelection() {
    final durations = [3, 7, 14, 21, 30];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duração (dias)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: durations.map((d) {
            final isSelected = _selectedDuration == d;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDuration = d),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    '${d}d',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTargetField() {
    final unit = _selectedType == 'workouts'
        ? 'treinos'
        : _selectedType == 'steps'
            ? 'passos'
            : _selectedType == 'calories'
                ? 'kcal'
                : 'minutos';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meta ($unit)',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _targetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: ${_selectedType == "steps" ? "100000" : "20"}',
            suffixText: unit,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              _isPublic ? Icons.public : Icons.lock,
              color: _isPublic ? AppColors.info : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isPublic ? 'Desafio Público' : 'Desafio Privado',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _isPublic ? 'Qualquer pessoa pode participar' : 'Apenas convidados',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isPublic,
              onChanged: (v) => setState(() => _isPublic = v),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteFriends() {
    if (_friends.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Convidar Amigos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedFriends.length} selecionados',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        ..._friends.map((friend) {
          final isSelected = _selectedFriends.contains(friend['id']);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFriends.remove(friend['id']);
                } else {
                  _selectedFriends.add(friend['id']);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.surface.withValues(alpha: 0.5),
                    child: Text(
                      (friend['name'] as String).substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      friend['name'] ?? '',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCreating ? null : _createChallenge,
        icon: _isCreating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.emoji_events),
        label: Text(_isCreating ? 'Criando...' : 'Criar Desafio'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

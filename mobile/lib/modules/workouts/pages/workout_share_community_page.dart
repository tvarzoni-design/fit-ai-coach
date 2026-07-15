import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutShareCommunityPage extends StatefulWidget {
  const WorkoutShareCommunityPage({super.key});

  @override
  State<WorkoutShareCommunityPage> createState() => _WorkoutShareCommunityPageState();
}

class _WorkoutShareCommunityPageState extends State<WorkoutShareCommunityPage> {
  bool _isPosting = false;
  final _messageController = TextEditingController();
  String _selectedAudience = 'public';
  final List<String> _selectedTags = [];
  Map<String, dynamic>? _workoutSummary;

  final _availableTags = const [
    'Treino de Força',
    'Cardio',
    'HIIT',
    'Mobilidade',
    'Pernas',
    'Peito',
    'Costas',
    'Ombros',
    'Braços',
    'Core',
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkoutSummary();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkoutSummary() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/workouts/latest-completed');
      if (mounted) setState(() => _workoutSummary = response.data);
    } catch (e) {
      if (mounted) {
        setState(() {
          _workoutSummary = {
            'name': 'Treino A - Peito e Tríceps',
            'duration': 65,
            'exercises': 6,
            'totalSets': 24,
            'totalVolume': '4,250 kg',
            'completedAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartilhar na Comunidade'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWorkoutSummaryCard(),
            const SizedBox(height: 20),
            _buildMessageSection(),
            const SizedBox(height: 20),
            _buildAudienceSection(),
            const SizedBox(height: 20),
            _buildTagsSection(),
            const SizedBox(height: 24),
            _buildPostButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutSummaryCard() {
    final summary = _workoutSummary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 8),
              Text(
                summary?['name'] ?? 'Treino',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat('${summary?['exercises'] ?? 0}', 'Exercícios'),
              _buildSummaryStat('${summary?['totalSets'] ?? 0}', 'Séries'),
              _buildSummaryStat('${summary?['duration'] ?? 0} min', 'Duração'),
              _buildSummaryStat(summary?['totalVolume'] ?? '0', 'Volume'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sua mensagem',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Conte como foi seu treino...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quem pode ver?',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildAudienceOption('public', 'Público', Icons.public, 'Todos na comunidade'),
            _buildAudienceOption('followers', 'Seguidores', Icons.people, 'Apenas seus seguidores'),
            _buildAudienceOption('private', 'Privado', Icons.lock, 'Somente você'),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceOption(String value, String title, IconData icon, String subtitle) {
    final isSelected = _selectedAudience == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedAudience = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tag exercícios',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isPosting ? null : _postToCommunity,
        icon: _isPosting
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send, size: 18),
        label: Text(_isPosting ? 'Publicando...' : 'Publicar na Comunidade'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _postToCommunity() async {
    setState(() => _isPosting = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/community/posts', data: {
        'message': _messageController.text,
        'audience': _selectedAudience,
        'tags': _selectedTags,
        'workoutSummary': _workoutSummary,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Treino publicado na comunidade!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Erro ao publicar'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

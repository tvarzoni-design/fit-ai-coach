import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ActivityTimelinePage extends StatefulWidget {
  const ActivityTimelinePage({super.key});

  @override
  State<ActivityTimelinePage> createState() => _ActivityTimelinePageState();
}

class _ActivityTimelinePageState extends State<ActivityTimelinePage> {
  List<dynamic> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/gamification/activity-timeline');
      if (mounted) setState(() { _activities = response.data ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _activities = _getMockActivities();
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getMockActivities() {
    final now = DateTime.now();
    return [
      {'type': 'treino', 'title': 'Treino de Peito e Tríceps concluído', 'description': '45 min • 6 exercícios • 1200 kcal', 'date': now.toIso8601String(), 'icon': 'fitness_center', 'color': 'primary'},
      {'type': 'medalha', 'title': 'Medalha desbloqueada: Força Bruta', 'description': 'Aumente seu record em 3 exercícios', 'date': now.subtract(const Duration(hours: 3)).toIso8601String(), 'icon': 'emoji_events', 'color': 'warning'},
      {'type': 'nivel', 'title': 'Nível 12 alcançado!', 'description': 'Parabéns! Continue evoluindo', 'date': now.subtract(const Duration(hours: 5)).toIso8601String(), 'icon': 'trending_up', 'color': 'info'},
      {'type': 'post', 'title': 'Post publicado na comunidade', 'description': '"Treino de hoje está epico!"', 'date': now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(), 'icon': 'post_add', 'color': 'secondary'},
      {'type': 'treino', 'title': 'Treino de Costas e Bíceps concluído', 'description': '52 min • 5 exercícios • 1350 kcal', 'date': now.subtract(const Duration(days: 1, hours: 5)).toIso8601String(), 'icon': 'fitness_center', 'color': 'primary'},
      {'type': 'sequencia', 'title': 'Sequência de 18 dias!', 'description': 'Continue assim para desbloquear novas medalhas', 'date': now.subtract(const Duration(days: 2)).toIso8601String(), 'icon': 'local_fire_department', 'color': 'warning'},
      {'type': 'treino', 'title': 'Treino de Pernas concluído', 'description': '60 min • 5 exercícios • 1500 kcal', 'date': now.subtract(const Duration(days: 2, hours: 3)).toIso8601String(), 'icon': 'fitness_center', 'color': 'primary'},
      {'type': 'nutricao', 'title': 'Meta nutricional atingida', 'description': '2200 kcal • 180g proteína', 'date': now.subtract(const Duration(days: 3)).toIso8601String(), 'icon': 'restaurant', 'color': 'success'},
      {'type': 'post', 'title': 'Seu post recebeu 25 likes', 'description': '"Dicas de alimentação pré-treino"', 'date': now.subtract(const Duration(days: 3, hours: 4)).toIso8601String(), 'icon': 'favorite', 'color': 'secondary'},
      {'type': 'medalha', 'title': 'Medalha desbloqueada: Social Butterfly', 'description': 'Fez 10 amigos na comunidade', 'date': now.subtract(const Duration(days: 4)).toIso8601String(), 'icon': 'emoji_events', 'color': 'warning'},
      {'type': 'treino', 'title': 'Treino de Ombros e Abdômen concluído', 'description': '40 min • 5 exercícios • 900 kcal', 'date': now.subtract(const Duration(days: 4, hours: 6)).toIso8601String(), 'icon': 'fitness_center', 'color': 'primary'},
      {'type': 'conquista', 'title': '75% das conquistas desbloqueadas', 'description': 'Faltam apenas 3 medalhas!', 'date': now.subtract(const Duration(days: 5)).toIso8601String(), 'icon': 'emoji_events', 'color': 'success'},
    ];
  }

  Map<String, List<dynamic>> _groupActivities() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    final groups = <String, List<dynamic>>{};
    for (final activity in _activities) {
      final date = DateTime.parse(activity['date']);
      final dateOnly = DateTime(date.year, date.month, date.day);

      String group;
      if (dateOnly == today) {
        group = 'Hoje';
      } else if (dateOnly == yesterday) {
        group = 'Ontem';
      } else if (dateOnly.isAfter(weekStart)) {
        group = 'Esta Semana';
      } else {
        group = 'Anterior';
      }

      groups.putIfAbsent(group, () => []).add(activity);
    }
    return groups;
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fitness_center': return Icons.fitness_center;
      case 'emoji_events': return Icons.emoji_events;
      case 'trending_up': return Icons.trending_up;
      case 'post_add': return Icons.post_add;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'restaurant': return Icons.restaurant;
      case 'favorite': return Icons.favorite;
      default: return Icons.circle;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'primary': return AppColors.primary;
      case 'secondary': return AppColors.secondary;
      case 'success': return AppColors.success;
      case 'warning': return AppColors.warning;
      case 'error': return AppColors.error;
      case 'info': return AppColors.info;
      default: return AppColors.textMuted;
    }
  }

  String _formatTime(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linha do Tempo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadActivities,
              child: _activities.isEmpty
                  ? _buildEmptyState()
                  : _buildTimeline(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('Nenhuma atividade ainda', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Comece treinando para ver sua timeline!', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final groups = _groupActivities();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: groups.keys.length,
      itemBuilder: (context, index) {
        final groupTitle = groups.keys.elementAt(index);
        final activities = groups[groupTitle]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index > 0 ? 16 : 0),
              child: Text(
                groupTitle,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            ...List.generate(activities.length, (i) {
              final activity = activities[i];
              final isLast = i == activities.length - 1;
              return _buildActivityItem(activity, isLast);
            }),
          ],
        );
      },
    );
  }

  Widget _buildActivityItem(dynamic activity, bool isLast) {
    final color = _getColor(activity['color'] ?? 'primary');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(activity['icon']), color: color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.surfaceLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          activity['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Text(
                        _formatTime(activity['date']),
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  if (activity['description'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      activity['description'],
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

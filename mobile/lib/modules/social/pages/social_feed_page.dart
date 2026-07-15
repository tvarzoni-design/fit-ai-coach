import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key});

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/social/feed', queryParameters: {'page': 1});
      if (mounted) setState(() { _posts = response.data ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _posts = [
            {
              'id': '1', 'userName': 'Carlos Silva', 'userAvatar': null,
              'type': 'workout_completed', 'content': 'Treino de peito completo! Novo recorde no supino.',
              'workoutName': 'Treino A - Peito', 'exercises': 6, 'duration': 65,
              'likes': 24, 'comments': 5, 'time': '2h atr\u00e1s', 'liked': false,
            },
            {
              'id': '2', 'userName': 'Ana Costa', 'userAvatar': null,
              'type': 'achievement', 'content': 'Conquistou a badge \u201cSequ\u00eancia de 30 dias\u201d!',
              'likes': 56, 'comments': 12, 'time': '4h atr\u00e1s', 'liked': true,
            },
            {
              'id': '3', 'userName': 'Pedro Santos', 'userAvatar': null,
              'type': 'personal_record', 'content': 'Novo PR no agachamento: 120kg!',
              'likes': 42, 'comments': 8, 'time': '6h atr\u00e1s', 'liked': false,
            },
            {
              'id': '4', 'userName': 'Maria Lima', 'userAvatar': null,
              'type': 'workout_completed', 'content': 'Cardio HIIT de 40 minutos. Calorias queimadas: 450!',
              'workoutName': 'HIIT Cardio', 'exercises': 8, 'duration': 40,
              'likes': 18, 'comments': 3, 'time': '8h atr\u00e1s', 'liked': false,
            },
            {
              'id': '5', 'userName': 'Jo\u00e3o Oliveira', 'userAvatar': null,
              'type': 'level_up', 'content': 'Alcan\u00e7ou o n\u00edvel 25!',
              'likes': 73, 'comments': 15, 'time': '10h atr\u00e1s', 'liked': true,
            },
          ];
        });
      }
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/social/feed', queryParameters: {'page': _page + 1});
      if (mounted) {
        setState(() {
          _posts.addAll(response.data ?? []);
          _page++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Social'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: _posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rss_feed, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text('Nenhum post no feed', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _buildPostCard(_posts[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildPostCard(dynamic post) {
    final type = post['type'] ?? 'info';
    IconData typeIcon;
    Color typeColor;

    switch (type) {
      case 'workout_completed':
        typeIcon = Icons.fitness_center;
        typeColor = AppColors.success;
        break;
      case 'achievement':
        typeIcon = Icons.emoji_events;
        typeColor = AppColors.warning;
        break;
      case 'personal_record':
        typeIcon = Icons.trending_up;
        typeColor = AppColors.primary;
        break;
      case 'level_up':
        typeIcon = Icons.star;
        typeColor = AppColors.secondary;
        break;
      default:
        typeIcon = Icons.info;
        typeColor = AppColors.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: typeColor.withValues(alpha: 0.2),
                child: Text(
                  (post['userName'] ?? 'U')[0],
                  style: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['userName'] ?? 'Usu\u00e1rio', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    Text(post['time'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Icon(typeIcon, color: typeColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(post['content'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4)),
          if (post['workoutName'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWorkoutStat(Icons.fitness_center, '${post['exercises'] ?? 0}', 'Exerc\u00edcios'),
                  _buildWorkoutStat(Icons.timer_outlined, '${post['duration'] ?? 0} min', 'Dura\u00e7\u00e3o'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(post),
                child: Row(
                  children: [
                    Icon(
                      post['liked'] == true ? Icons.favorite : Icons.favorite_border,
                      color: post['liked'] == true ? AppColors.error : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text('${post['likes'] ?? 0}', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.comment_outlined, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 4),
                    Text('${post['comments'] ?? 0}', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 4),
                    Text('Compartilhar', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }

  void _toggleLike(dynamic post) {
    setState(() {
      post['liked'] = !(post['liked'] ?? false);
      post['likes'] = (post['likes'] ?? 0) + (post['liked'] == true ? 1 : -1);
    });
  }
}

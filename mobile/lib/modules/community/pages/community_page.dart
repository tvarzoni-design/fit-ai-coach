import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getCommunityFeed();
      if (mounted) setState(() { _posts = response.data ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidade'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push('/leaderboard'),
            tooltip: 'Leaderboard',
          ),
        ],
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
                          Icon(Icons.people_outline, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text('Nenhum post ainda', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) => _buildFeedCard(_posts[index]),
                    ),
            ),
    );
  }

  Widget _buildFeedCard(dynamic post) {
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
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: typeColor.withValues(alpha: 0.2),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['userName'] ?? post['authorName'] ?? 'Usuário', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    Text(post['time'] ?? post['createdAt'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post['content'] ?? post['title'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionChip(Icons.favorite_border, '${post['likes'] ?? 0}', AppColors.textMuted),
              const SizedBox(width: 16),
              _buildActionChip(Icons.comment_outlined, '${post['comments'] ?? 0}', AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}

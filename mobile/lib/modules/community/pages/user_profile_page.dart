import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CommunityUserProfilePage extends StatefulWidget {
  final String userId;

  const CommunityUserProfilePage({super.key, required this.userId});

  @override
  State<CommunityUserProfilePage> createState() =>
      _CommunityUserProfilePageState();
}

class _CommunityUserProfilePageState extends State<CommunityUserProfilePage> {
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final feedResponse = await api.getCommunityFeed();
      if (mounted) {
        _userPosts = (feedResponse.data as List?)
                ?.where((p) =>
                    p['userId'] == widget.userId ||
                    p['authorId'] == widget.userId)
                .map<Map<String, dynamic>>((p) => {
                      'id': p['id'] ?? '',
                      'content': p['content'] ?? p['title'] ?? '',
                      'category': p['category'] ?? 'Dica',
                      'likes': p['likes'] ?? 0,
                      'comments': p['comments'] ?? 0,
                      'time': p['createdAt'] ?? p['time'] ?? '',
                    })
                .toList() ??
            [];
        _userData = {
          'id': widget.userId,
          'name': 'Ana Fitness',
          'avatar': null,
          'posts': _userPosts.length > 0 ? _userPosts.length : 23,
          'followers': 156,
          'following': 42,
          'isFollowing': false,
          'badges': [
            {'name': 'Primeiro Treino', 'icon': Icons.fitness_center, 'color': AppColors.success},
            {'name': '7 Dias Seguidos', 'icon': Icons.local_fire_department, 'color': AppColors.warning},
            {'name': '100kg no Supino', 'icon': Icons.emoji_events, 'color': AppColors.primary},
            {'name': 'Maratonista', 'icon': Icons.directions_run, 'color': AppColors.secondary},
          ],
        };
        _isFollowing = _userData!['isFollowing'] ?? false;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _userPosts = [
          {
            'id': '1',
            'content': 'Treino de pernas completo! Nao deixem de treinar pernas, pessoal!',
            'category': 'Dica',
            'likes': 34,
            'comments': 8,
            'time': '1 dia atras',
          },
          {
            'id': '2',
            'content': 'Consegui correr 10km sem parar pela primeira vez!',
            'category': 'Conquista',
            'likes': 67,
            'comments': 15,
            'time': '3 dias atras',
          },
        ];
        _userData = {
          'id': widget.userId,
          'name': 'Ana Fitness',
          'avatar': null,
          'posts': 23,
          'followers': 156,
          'following': 42,
          'isFollowing': false,
          'badges': [
            {'name': 'Primeiro Treino', 'icon': Icons.fitness_center, 'color': AppColors.success},
            {'name': '7 Dias Seguidos', 'icon': Icons.local_fire_department, 'color': AppColors.warning},
            {'name': '100kg no Supino', 'icon': Icons.emoji_events, 'color': AppColors.primary},
            {'name': 'Maratonista', 'icon': Icons.directions_run, 'color': AppColors.secondary},
          ],
        };
        _isFollowing = false;
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleFollow() async {
    setState(() => _isFollowing = !_isFollowing);
    try {
      final api = context.read<AuthService>().api;
      if (_isFollowing) {
        await api.followUser(widget.userId);
      } else {
        await api.unfollowUser(widget.userId);
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        final delta = _isFollowing ? 1 : -1;
        _userData!['followers'] = (_userData!['followers'] as int) + delta;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_userData?['name'] ?? 'Perfil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildBadgesSection(),
                  const SizedBox(height: 24),
                  Text(
                    'Publicacoes',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPostsFeed(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    final name = _userData?['name'] ?? 'Usuario';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isFollowing ? AppColors.surfaceLight : AppColors.primary,
                side: _isFollowing
                    ? BorderSide(color: AppColors.primary.withValues(alpha: 0.3))
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _isFollowing ? 'Seguindo' : 'Seguir',
                style: TextStyle(
                  color: _isFollowing ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final posts = _userData?['posts'] ?? 0;
    final followers = _userData?['followers'] ?? 0;
    final following = _userData?['following'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('$posts', 'Publicacoes'),
          Container(width: 1, height: 32, color: AppColors.surfaceLight),
          _buildStatItem('$followers', 'Seguidores'),
          Container(width: 1, height: 32, color: AppColors.surfaceLight),
          _buildStatItem('$following', 'Seguindo'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    final badges = (_userData?['badges'] as List?)
            ?.map<Map<String, dynamic>>((b) => {
                  'name': b['name'] ?? '',
                  'icon': b['icon'] ?? Icons.star,
                  'color': b['color'] ?? AppColors.primary,
                })
            .toList() ??
        [];

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conquistas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              final color = badge['color'] as Color;
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      badge['icon'] as IconData,
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      badge['name'] as String,
                      style: TextStyle(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostsFeed() {
    if (_userPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.article_outlined, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Nenhuma publicacao',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) => _buildPostCard(_userPosts[index]),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final category = post['category'] as String? ?? 'Dica';
    final color = _getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                post['time'] as String? ?? '',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post['content'] as String? ?? '',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite_border, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 4),
              Text(
                '${post['likes'] ?? 0}',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(Icons.comment_outlined,
                  color: AppColors.textMuted, size: 16),
              const SizedBox(width: 4),
              Text(
                '${post['comments'] ?? 0}',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Conquista':
        return AppColors.success;
      case 'Dica':
        return AppColors.warning;
      case 'Motivacao':
        return AppColors.secondary;
      default:
        return AppColors.info;
    }
  }
}

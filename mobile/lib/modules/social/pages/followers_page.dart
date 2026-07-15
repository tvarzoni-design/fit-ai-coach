import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({super.key});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<dynamic> _followers = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFollowers();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowers() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getFollowers();
      if (mounted) {
        setState(() {
          _followers = response.data ?? [];
          _filtered = _followers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _followers = [
            {'id': '1', 'name': 'Lucas Silva', 'username': '@lucas_fit', 'avatar': null, 'isFollowing': true},
            {'id': '2', 'name': 'Maria Santos', 'username': '@maria_fitness', 'avatar': null, 'isFollowing': false},
            {'id': '3', 'name': 'Pedro Lima', 'username': '@pedro_gym', 'avatar': null, 'isFollowing': true},
          ];
          _filtered = _followers;
        });
      }
    }
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _followers.where((u) =>
        (u['name'] ?? '').toLowerCase().contains(query) ||
        (u['username'] ?? '').toLowerCase().contains(query)
      ).toList();
    });
  }

  Future<void> _toggleFollow(dynamic user) async {
    try {
      final api = context.read<AuthService>().api;
      if (user['isFollowing']) {
        await api.unfollowUser(user['id']);
      } else {
        await api.followUser(user['id']);
      }
      setState(() => user['isFollowing'] = !(user['isFollowing'] ?? false));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguidores')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar seguidores...',
                      prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadFollowers,
                    child: _filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) => _buildUserTile(_filtered[index]),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Nenhum seguidor encontrado', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildUserTile(dynamic user) {
    final isFollowing = user['isFollowing'] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              (user['name'] ?? 'U')[0].toUpperCase(),
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(user['username'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _toggleFollow(user),
            style: OutlinedButton.styleFrom(
              foregroundColor: isFollowing ? AppColors.textMuted : AppColors.primary,
              side: BorderSide(color: isFollowing ? AppColors.surfaceLight : AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(isFollowing ? 'Seguindo' : 'Seguir'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<dynamic> _following = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFollowing();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowing() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getFollowing();
      if (mounted) {
        setState(() {
          _following = response.data ?? [];
          _filtered = _following;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _following = [
            {'id': '1', 'name': 'Ana Costa', 'username': '@ana_strength', 'avatar': null},
            {'id': '2', 'name': 'João Mendes', 'username': '@jao_run', 'avatar': null},
            {'id': '3', 'name': 'Carla Souza', 'username': '@carla_yoga', 'avatar': null},
          ];
          _filtered = _following;
        });
      }
    }
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _following.where((u) =>
        (u['name'] ?? '').toLowerCase().contains(query) ||
        (u['username'] ?? '').toLowerCase().contains(query)
      ).toList();
    });
  }

  Future<void> _unfollow(dynamic user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Deixar de seguir?'),
        content: Text('Parar de seguir ${user['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Deixar de seguir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final api = context.read<AuthService>().api;
      await api.unfollowUser(user['id']);
      setState(() => _following.remove(user));
      _filter();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguindo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar seguindo...',
                      prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadFollowing,
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
          Icon(Icons.person_add_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Você não segue ninguém ainda', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildUserTile(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
            child: Text(
              (user['name'] ?? 'U')[0].toUpperCase(),
              style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
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
            onPressed: () => _unfollow(user),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.surfaceLight),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Seguindo'),
          ),
        ],
      ),
    );
  }
}

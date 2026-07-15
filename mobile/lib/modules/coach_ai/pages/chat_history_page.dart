import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<dynamic> _conversations = [];
  List<dynamic> _filteredConversations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/ai/chat/history');
      if (mounted) {
        setState(() {
          _conversations = response.data ?? [];
          _filteredConversations = _conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _conversations = _getMockConversations();
          _filteredConversations = _conversations;
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getMockConversations() {
    return [
      {
        'id': '1',
        'title': 'Plano de treino para hipertrofia',
        'preview': 'Criei um plano focado em treino split 5x...',
        'date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'messageCount': 12,
      },
      {
        'id': '2',
        'title': 'Dicas de alimentação pré-treino',
        'preview': 'Recomendo consumir carboidratos complexos...',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'messageCount': 8,
      },
      {
        'id': '3',
        'title': 'Como melhorar supino reto',
        'preview': 'A técnica correta envolve retração escapular...',
        'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'messageCount': 15,
      },
      {
        'id': '4',
        'title': 'Recuperação muscular',
        'preview': 'O descanso adequado é essencial para...',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'messageCount': 6,
      },
      {
        'id': '5',
        'title': 'Meta de perda de peso',
        'preview': 'Para perder 0.5kg por semana, déficit de...',
        'date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'messageCount': 20,
      },
    ];
  }

  void _filterConversations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations
            .where((c) =>
                (c['title'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
                (c['preview'] ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return '${diff.inDays} dias atrás';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteConversation(String id) async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.delete('/ai/chat/history/$id');
    } catch (_) {}
    setState(() {
      _conversations.removeWhere((c) => c['id'] == id);
      _filterConversations(_searchQuery);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversa excluída')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Conversas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () => context.go('/coach'),
            tooltip: 'Nova conversa',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredConversations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredConversations.length,
                          itemBuilder: (context, index) =>
                              _buildConversationTile(_filteredConversations[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/coach'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Conversa', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterConversations,
        decoration: InputDecoration(
          hintText: 'Buscar conversas...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    _filterConversations('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
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
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Nenhuma conversa encontrada'
                  : 'Nenhuma conversa ainda',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tente buscar com outros termos'
                  : 'Comece uma nova conversa com o Coach IA',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/coach'),
                icon: const Icon(Icons.add),
                label: const Text('Nova Conversa'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(dynamic conversation) {
    return Dismissible(
      key: Key(conversation['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Excluir conversa?'),
            content: const Text('Esta ação não pode ser desfeita.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteConversation(conversation['id']),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy, color: AppColors.primary),
          ),
          title: Text(
            conversation['title'] ?? 'Conversa',
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              conversation['preview'] ?? '',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(conversation['date']),
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                '${conversation['messageCount']} msgs',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          onTap: () => context.go('/coach'),
        ),
      ),
    );
  }
}

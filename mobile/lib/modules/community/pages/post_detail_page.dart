import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map<String, dynamic>? _post;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isLiked = false;
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final commentsResponse = await api.getComments(widget.postId);
      if (mounted) {
        _comments = (commentsResponse.data as List?)
                ?.map<Map<String, dynamic>>((c) => {
                      'id': c['id'] ?? '',
                      'author': c['authorName'] ?? c['userName'] ?? 'Usuario',
                      'content': c['content'] ?? c['text'] ?? '',
                      'time': c['createdAt'] ?? c['time'] ?? '',
                      'likes': c['likes'] ?? 0,
                      'replies': c['replies'] ?? [],
                    })
                .toList() ??
            [];
        _post = {
          'id': widget.postId,
          'author': 'Carlos Silva',
          'content':
              'Consegui bater meu recorde pessoal no supino hoje! 80kg x 8 reps. Estava tentando ha 3 meses. A consistencia e tudo!',
          'category': 'Conquista',
          'time': '2 horas atras',
          'likes': 47,
          'comments': _comments.length,
          'shares': 12,
          'isLiked': false,
        };
        _isLiked = _post!['isLiked'] ?? false;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _comments = [
          {
            'id': '1',
            'author': 'Ana Costa',
            'content': 'Parabens! Muito inspirador!',
            'time': '1 hora atras',
            'likes': 5,
            'replies': [
              {
                'id': '1-1',
                'author': 'Carlos Silva',
                'content': 'Obrigado Ana! Vamos continuar!',
                'time': '45 min atras',
                'likes': 2,
              },
            ],
          },
          {
            'id': '2',
            'author': 'Pedro Santos',
            'content': 'Qual sua serie normalmente? Estou travado em 70kg.',
            'time': '30 min atras',
            'likes': 3,
            'replies': [],
          },
        ];
        _post = {
          'id': widget.postId,
          'author': 'Carlos Silva',
          'content':
              'Consegui bater meu recorde pessoal no supino hoje! 80kg x 8 reps. Estava tentando ha 3 meses. A consistencia e tudo!',
          'category': 'Conquista',
          'time': '2 horas atras',
          'likes': 47,
          'comments': 2,
          'shares': 12,
          'isLiked': false,
        };
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
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
        title: const Text('Post'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
            color: AppColors.surfaceLight,
            onSelected: (value) {
              if (value == 'report') _showReportDialog(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Text('Denunciar', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostContent(),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 24),
                        Text(
                          'Comentarios (${_comments.length})',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCommentsList(),
                      ],
                    ),
                  ),
                ),
                _buildCommentInput(),
              ],
            ),
    );
  }

  Widget _buildPostContent() {
    if (_post == null) return const SizedBox.shrink();
    final category = _post!['category'] as String;
    final categoryColor = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  (_post!['author'] as String)[0].toUpperCase(),
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post!['author'] as String,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _post!['time'] as String,
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _post!['content'] as String,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            '${_post!['likes'] ?? 0}',
            _isLiked ? AppColors.secondary : AppColors.textSecondary,
            () {
              setState(() {
                _isLiked = !_isLiked;
                _post!['likes'] =
                    (_post!['likes'] as int) + (_isLiked ? 1 : -1);
              });
              try {
                final api = context.read<AuthService>().api;
                api.likePost(widget.postId);
              } catch (_) {}
            },
          ),
          _buildActionButton(
            Icons.comment_outlined,
            '${_post!['comments'] ?? 0}',
            AppColors.textSecondary,
            () => _focusNode.requestFocus(),
          ),
          _buildActionButton(
            Icons.share_outlined,
            '${_post!['shares'] ?? 0}',
            AppColors.textSecondary,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 40, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Seja o primeiro a comentar',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      itemBuilder: (context, index) => _buildCommentItem(_comments[index]),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final replies = (comment['replies'] as List?)
            ?.map<Map<String, dynamic>>(
                (r) => Map<String, dynamic>.from(r))
            .toList() ??
        [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    AppColors.secondary.withValues(alpha: 0.2),
                child: Text(
                  (comment['author'] as String)[0].toUpperCase(),
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment['author'] as String,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment['time'] as String,
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment['content'] as String,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Icon(Icons.favorite_border,
                                  color: AppColors.textMuted, size: 14),
                              const SizedBox(width: 4),
                              Text('${comment['likes'] ?? 0}',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {},
                          child: Text('Responder',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (replies.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...replies.map((reply) => _buildReplyItem(reply)),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyItem(Map<String, dynamic> reply) {
    return Container(
      margin: const EdgeInsets.only(left: 42, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.success.withValues(alpha: 0.2),
            child: Text(
              (reply['author'] as String? ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply['author'] as String? ?? '',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reply['time'] as String? ?? '',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  reply['content'] as String? ?? '',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceLight, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Escreva um comentario...',
                    hintStyle:
                        TextStyle(color: AppColors.textMuted, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submitComment,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    setState(() {
      _comments.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'author': context.read<AuthService>().userName ?? 'Voce',
        'content': text,
        'time': 'Agora',
        'likes': 0,
        'replies': [],
      });
      _post!['comments'] = (_post!['comments'] as int) + 1;
    });

    try {
      final api = context.read<AuthService>().api;
      await api.commentPost(widget.postId, text);
    } catch (_) {}
  }

  void _showReportDialog(BuildContext context) {
    final reasons = [
      'Spam',
      'Conteudo ofensivo',
      'Informacao incorreta',
      'Assedio',
      'Outro',
    ];
    String? selectedReason;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Denunciar Post',
              style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons.map((reason) {
              return RadioListTile<String>(
                value: reason,
                groupValue: selectedReason,
                onChanged: (v) => setDialogState(() => selectedReason = v),
                title: Text(reason,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 14)),
                activeColor: AppColors.warning,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Denuncia enviada. Obrigado!'),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Text('Enviar',
                  style: TextStyle(color: AppColors.warning)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Conquista':
        return AppColors.success;
      case 'Duvida':
      case 'Dica':
        return AppColors.primary;
      case 'Motivacao':
        return AppColors.secondary;
      default:
        return AppColors.info;
    }
  }
}

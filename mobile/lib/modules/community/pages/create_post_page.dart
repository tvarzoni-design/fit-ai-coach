import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  String _selectedCategory = 'Duvida';
  XFile? _selectedImage;
  bool _isPosting = false;
  final int _maxChars = 500;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Duvida', 'icon': Icons.help_outline, 'color': AppColors.info},
    {'label': 'Conquista', 'icon': Icons.emoji_events, 'color': AppColors.success},
    {'label': 'Dica', 'icon': Icons.lightbulb_outline, 'color': AppColors.warning},
    {'label': 'Motivacao', 'icon': Icons.whatshot, 'color': AppColors.secondary},
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _textController.text.length;
    final isOverLimit = charCount > _maxChars;
    final canPost = _textController.text.trim().isNotEmpty && !isOverLimit && !_isPosting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Novo Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: canPost ? _submitPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.surfaceLight,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: _isPosting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Postar',
                      style: TextStyle(
                        color: canPost ? Colors.white : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorRow(),
            const SizedBox(height: 16),
            _buildTextInput(),
            const SizedBox(height: 16),
            if (_selectedImage != null) _buildImagePreview(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildActionRow(),
            const SizedBox(height: 12),
            _buildCharCounter(charCount, isOverLimit),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRow() {
    final userName = context.read<AuthService>().userName ?? 'Usuario';
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Text(
            userName[0].toUpperCase(),
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(_selectedCategory)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _selectedCategory,
                  style: TextStyle(
                    color: _getCategoryColor(_selectedCategory),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: 8,
        minLines: 4,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'O que voce quer compartilhar?',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: AppColors.surfaceLight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    _selectedImage!.name,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImage = null),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: AppColors.textPrimary, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat['label'];
            final color = cat['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['label'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: color.withValues(alpha: 0.4))
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        color: isSelected ? color : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildActionRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildActionButton(
            Icons.photo_camera_outlined,
            'Foto',
            () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(
                source: ImageSource.gallery,
                maxHeight: 1024,
                maxWidth: 1024,
              );
              if (image != null) {
                setState(() => _selectedImage = image);
              }
            },
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            Icons.camera_alt_outlined,
            'Camera',
            () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(
                source: ImageSource.camera,
                maxHeight: 1024,
                maxWidth: 1024,
              );
              if (image != null) {
                setState(() => _selectedImage = image);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCharCounter(int count, bool isOverLimit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isOverLimit
                ? AppColors.error.withValues(alpha: 0.15)
                : count > _maxChars * 0.8
                    ? AppColors.warning.withValues(alpha: 0.15)
                    : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count/$_maxChars',
            style: TextStyle(
              color: isOverLimit
                  ? AppColors.error
                  : count > _maxChars * 0.8
                      ? AppColors.warning
                      : AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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

  Future<void> _submitPost() async {
    setState(() => _isPosting = true);

    try {
      final api = context.read<AuthService>().api;
      await api.createPost({
        'content': _textController.text.trim(),
        'category': _selectedCategory,
        if (_selectedImage != null) 'image': _selectedImage!.path,
      });
    } catch (_) {}

    if (mounted) {
      setState(() => _isPosting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post publicado com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.pop();
    }
  }
}

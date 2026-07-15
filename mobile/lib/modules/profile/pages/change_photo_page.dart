import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ChangePhotoPage extends StatefulWidget {
  const ChangePhotoPage({super.key});

  @override
  State<ChangePhotoPage> createState() => _ChangePhotoPageState();
}

class _ChangePhotoPageState extends State<ChangePhotoPage> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _currentPhotoUrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCurrentPhoto();
  }

  Future<void> _loadCurrentPhoto() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getProfile();
      if (mounted) setState(() => _currentPhotoUrl = response.data?['photoUrl']);
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (picked == null) return;
    setState(() => _selectedImage = File(picked.path));
    await _uploadPhoto();
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);
    try {
      final api = context.read<AuthService>().api;
      await api.uploadProfilePhoto(_selectedImage!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto atualizada com sucesso!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao fazer upload da foto')));
      }
    }
  }

  Future<void> _removePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remover foto?'),
        content: const Text('Sua foto de perfil será removida.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remover', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isUploading = true);
    try {
      final api = context.read<AuthService>().api;
      await api.removeProfilePhoto();
      if (mounted) {
        setState(() { _selectedImage = null; _currentPhotoUrl = null; _isUploading = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto removida')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao remover foto')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Foto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildPhotoPreview(),
            const SizedBox(height: 32),
            if (_isUploading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text('Enviando foto...', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
            ],
            _buildOptionTile(Icons.camera_alt, 'Tirar Foto', 'Use a câmera do dispositivo', () => _pickImage(ImageSource.camera)),
            const SizedBox(height: 12),
            _buildOptionTile(Icons.photo_library, 'Escolher da Galeria', 'Selecione uma foto existente', () => _pickImage(ImageSource.gallery)),
            const SizedBox(height: 12),
            _buildOptionTile(Icons.delete_outline, 'Remover Foto', 'Volte ao avatar padrão', _removePhoto, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
          child: _selectedImage == null
              ? (_currentPhotoUrl != null
                  ? null
                  : Icon(Icons.person, size: 60, color: AppColors.primary.withValues(alpha: 0.5)))
              : null,
        ),
        if (!_isUploading)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 3),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
          ),
      ],
    );
  }

  Widget _buildOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
        title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : null)),
        subtitle: Text(subtitle, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: _isUploading ? null : onTap,
      ),
    );
  }
}

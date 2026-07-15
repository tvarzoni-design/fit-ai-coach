import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ProgressPhotosPage extends StatefulWidget {
  const ProgressPhotosPage({super.key});

  @override
  State<ProgressPhotosPage> createState() => _ProgressPhotosPageState();
}

class _ProgressPhotosPageState extends State<ProgressPhotosPage> {
  List<Map<String, dynamic>> _photoGroups = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  int _compareIndexA = 0;
  int _compareIndexB = 1;
  bool _isCompareMode = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getPhotos();
      if (mounted) {
        final data = response.data ?? [];
        _photoGroups = (data as List)
            .map<Map<String, dynamic>>((p) => {
                  'date': p['date'] ?? p['createdAt'] ?? '',
                  'front': p['front'],
                  'side': p['side'],
                  'back': p['back'],
                })
            .toList();
        if (_photoGroups.isEmpty) {
          _photoGroups = _generateMockPhotos();
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _photoGroups = _generateMockPhotos();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _generateMockPhotos() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final date = now.subtract(Duration(days: (5 - i) * 14));
      return {
        'date': '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        'front': null,
        'side': null,
        'back': null,
      };
    });
  }

  Future<void> _addPhoto(String view) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1024,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      try {
        final api = context.read<AuthService>().api;
        await api.addPhoto({
          'view': view,
          'date': _selectedDate.toIso8601String(),
          'path': image.path,
        });
      } catch (_) {}

      if (mounted) {
        setState(() {
          final dateStr =
              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';
          final existing = _photoGroups.indexWhere((g) => g['date'] == dateStr);
          if (existing >= 0) {
            _photoGroups[existing][view] = image.path;
          } else {
            _photoGroups.insert(0, {
              'date': dateStr,
              view: image.path,
              'front': null,
              'side': null,
              'back': null,
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto adicionada!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
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
        title: const Text('Fotos de Evolução'),
        actions: [
          if (_photoGroups.length >= 2)
            IconButton(
              icon: Icon(
                _isCompareMode ? Icons.grid_view : Icons.compare,
                color: _isCompareMode ? AppColors.primary : null,
              ),
              onPressed: () {
                setState(() => _isCompareMode = !_isCompareMode);
              },
              tooltip: _isCompareMode ? 'Grade' : 'Comparar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isCompareMode
              ? _buildCompareView()
              : _buildGridView(),
    );
  }

  Widget _buildGridView() {
    return Column(
      children: [
        _buildDateSelector(),
        Expanded(
          child: _photoGroups.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _photoGroups.length,
                  itemBuilder: (context, index) => _buildPhotoGroupCard(_photoGroups[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fotos mais recentes',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primary,
                      surface: AppColors.surface,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ],
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
          Icon(Icons.camera_alt_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Nenhuma foto ainda',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione fotos para acompanhar sua evolução',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddPhotoOptions(context),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Adicionar Fotos'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGroupCard(Map<String, dynamic> group, int index) {
    final views = ['front', 'side', 'back'];
    final labels = {'front': 'Frente', 'side': 'Lado', 'back': 'Costas'};
    final icons = {'front': Icons.person, 'side': Icons.person_outline, 'back': Icons.person_pin};

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    group['date'] as String,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (index == 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Mais recente',
                    style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: views.map((view) {
              final photo = group[view];
              final hasPhoto = photo != null;

              return Expanded(
                child: GestureDetector(
                  onTap: () => hasPhoto ? _viewPhoto(photo) : _addPhoto(view),
                  child: Container(
                    margin: EdgeInsets.only(right: view != 'back' ? 8 : 0),
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: hasPhoto ? null : Border.all(color: AppColors.textMuted.withValues(alpha: 0.3), width: 1),
                    ),
                    child: hasPhoto
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildPhotoPlaceholder(view),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icons[view], color: AppColors.textMuted, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                labels[view]!,
                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(String view) {
    final colors = {
      'front': AppColors.primary,
      'side': AppColors.warning,
      'back': AppColors.success,
    };
    final icons = {
      'front': Icons.person,
      'side': Icons.person_outline,
      'back': Icons.accessibility_new,
    };

    return Container(
      color: AppColors.surfaceLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons[view], color: colors[view]?.withValues(alpha: 0.5), size: 36),
            const SizedBox(height: 4),
            Text(
              {'front': 'Frente', 'side': 'Lado', 'back': 'Costas'}[view]!,
              style: TextStyle(color: colors[view]?.withValues(alpha: 0.7), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareView() {
    if (_photoGroups.length < 2) {
      return Center(
        child: Text(
          'Adicione pelo menos 2 datas para comparar',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        _buildCompareSelector(),
        Expanded(
          child: _buildCompareBody(),
        ),
      ],
    );
  }

  Widget _buildCompareSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Antes', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _compareIndexA,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceLight,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      items: List.generate(
                        _photoGroups.length,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(_photoGroups[i]['date'] as String),
                        ),
                      ),
                      onChanged: (v) => setState(() => _compareIndexA = v ?? 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, color: AppColors.textMuted),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Depois', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _compareIndexB,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceLight,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      items: List.generate(
                        _photoGroups.length,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text(_photoGroups[i]['date'] as String),
                        ),
                      ),
                      onChanged: (v) => setState(() => _compareIndexB = v ?? 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareBody() {
    final groupA = _photoGroups[_compareIndexA];
    final groupB = _photoGroups[_compareIndexB];
    final views = ['front', 'side', 'back'];
    final labels = {'front': 'Frente', 'side': 'Lado', 'back': 'Costas'};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: views.map((view) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labels[view]!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildComparePhoto(groupA[view], groupA['date'], 'Antes'),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildComparePhoto(groupB[view], groupB['date'], 'Depois'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparePhoto(dynamic photo, dynamic date, String label) {
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: photo != null
              ? _buildPhotoPlaceholder(label == 'Antes' ? 'front' : 'side')
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 32),
                    const SizedBox(height: 4),
                    Text('Sem foto', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
        ),
        const SizedBox(height: 6),
        Text(
          date as String? ?? '',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  void _viewPhoto(String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildPhotoPlaceholder('front'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Toque para fechar',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionar Foto',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPhotoOption(
              context,
              Icons.person,
              'Frente',
              () {
                Navigator.pop(ctx);
                _addPhoto('front');
              },
            ),
            _buildPhotoOption(
              context,
              Icons.person_outline,
              'Lado',
              () {
                Navigator.pop(ctx);
                _addPhoto('side');
              },
            ),
            _buildPhotoOption(
              context,
              Icons.accessibility_new,
              'Costas',
              () {
                Navigator.pop(ctx);
                _addPhoto('back');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(label, style: TextStyle(color: AppColors.textPrimary)),
      trailing: Icon(Icons.camera_alt, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

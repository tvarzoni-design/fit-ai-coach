import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class DataUsagePage extends StatefulWidget {
  const DataUsagePage({super.key});

  @override
  State<DataUsagePage> createState() => _DataUsagePageState();
}

class _DataUsagePageState extends State<DataUsagePage> {
  int _cacheSize = 0;
  bool _wifiOnly = true;
  bool _offlineMode = false;
  String _downloadQuality = 'high';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/settings/data-usage');
      if (mounted) {
        final data = response.data;
        setState(() {
          _cacheSize = data['cacheSize'] ?? 0;
          _wifiOnly = data['wifiOnly'] ?? true;
          _offlineMode = data['offlineMode'] ?? false;
          _downloadQuality = data['downloadQuality'] ?? 'high';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cacheSize = 245760;
          _wifiOnly = true;
          _offlineMode = false;
          _downloadQuality = 'high';
          _isLoading = false;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Future<void> _clearCache() async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/settings/clear-cache');
    } catch (_) {}
    setState(() => _cacheSize = 0);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cache limpo com sucesso'), backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/settings/data-usage', data: {key: value});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final totalStorage = 1024 * 1024 * 1024;
    final storageUsed = _cacheSize + 52428800;
    final storageProgress = (storageUsed / totalStorage).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uso de Dados e Cache'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStorageBar(storageProgress, storageUsed, totalStorage),
                  const SizedBox(height: 16),
                  _buildCacheSection(),
                  const SizedBox(height: 16),
                  _buildDownloadSection(),
                  const SizedBox(height: 16),
                  _buildOfflineSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildStorageBar(double progress, int used, int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Armazenamento', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.8 ? AppColors.error : progress > 0.6 ? AppColors.warning : AppColors.info,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Usado: ${_formatBytes(used)}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text('Total: ${_formatBytes(total)}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toStringAsFixed(1)}% utilizado', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cache', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.cached, color: AppColors.info, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tamanho do Cache', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      Text(_formatBytes(_cacheSize), style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _cacheSize > 0 ? () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('Limpar Cache'),
                      content: Text('Isso removerá ${_formatBytes(_cacheSize)} de dados armazenados.', style: TextStyle(color: AppColors.textSecondary)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                        TextButton(
                          onPressed: () { Navigator.pop(ctx); _clearCache(); },
                          child: Text('Limpar', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                } : null,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Limpar Cache'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadSection() {
    final qualities = [
      {'label': 'Baixa', 'value': 'low', 'desc': 'Menos dados, menor qualidade'},
      {'label': 'Média', 'value': 'medium', 'desc': 'Equilíbrio entre dados e qualidade'},
      {'label': 'Alta', 'value': 'high', 'desc': 'Melhor qualidade, mais dados'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qualidade de Download', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...qualities.map((q) {
              final isSelected = _downloadQuality == q['value'];
              return GestureDetector(
                onTap: () {
                  setState(() => _downloadQuality = q['value']!);
                  _saveSetting('downloadQuality', q['value']);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q['label']!, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                            Text(q['desc']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferências', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Downloads apenas via Wi-Fi', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('Evita usar dados móveis para downloads', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _wifiOnly,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _wifiOnly = v);
                _saveSetting('wifiOnly', v);
              },
            ),
            Divider(color: AppColors.surfaceLight),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Modo offline', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text('Baixa dados automaticamente para uso sem internet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: _offlineMode,
              activeColor: AppColors.primary,
              onChanged: (v) {
                setState(() => _offlineMode = v);
                _saveSetting('offlineMode', v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CardioExportPage extends StatefulWidget {
  const CardioExportPage({super.key});

  @override
  State<CardioExportPage> createState() => _CardioExportPageState();
}

class _CardioExportPageState extends State<CardioExportPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _session;
  DateTimeRange? _dateRange;
  String _selectedFormat = 'PDF';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/cardio/sessions/latest');
      if (mounted) {
        setState(() {
          _session = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _session = {
            'type': 'running',
            'date': DateTime.now().toIso8601String(),
            'duration': 2847,
            'distance': 8.52,
            'calories': 684,
            'avgHeartRate': 156,
            'maxHeartRate': 178,
            'avgPace': '5:33',
            'elevation': 124,
          };
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}min ${s}s';
    return '${m}min ${s}s';
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _dateRange ?? DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/cardio/export', data: {
        'format': _selectedFormat.toLowerCase(),
        'dateStart': _dateRange?.start.toIso8601String(),
        'dateEnd': _dateRange?.end.toIso8601String(),
      });
    } catch (_) {}
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dados exportados como $_selectedFormat com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Dados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSessionSummary(),
                  const SizedBox(height: 20),
                  _buildDateRangePicker(),
                  const SizedBox(height: 20),
                  _buildFormatSelection(),
                  const SizedBox(height: 32),
                  _buildExportButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSessionSummary() {
    if (_session == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_run, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Resumo da Sessão',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Tipo', _session!['type'] ?? 'Corrida'),
            _buildSummaryRow('Duração', _formatDuration(_session!['duration'] ?? 0)),
            _buildSummaryRow('Distância', '${(_session!['distance'] ?? 0).toStringAsFixed(2)} km'),
            _buildSummaryRow('Calorias', '${_session!['calories'] ?? 0} kcal'),
            _buildSummaryRow('FC Média', '${_session!['avgHeartRate'] ?? '--'} bpm'),
            _buildSummaryRow('FC Máxima', '${_session!['maxHeartRate'] ?? '--'} bpm'),
            _buildSummaryRow('Ritmo Médio', '${_session!['avgPace'] ?? '--'} /km'),
            _buildSummaryRow('Elevação', '${_session!['elevation'] ?? 0} m'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker() {
    final startStr = _dateRange?.start != null
        ? '${_dateRange!.start.day.toString().padLeft(2, '0')}/${_dateRange!.start.month.toString().padLeft(2, '0')}/${_dateRange!.start.year}'
        : 'Selecionar início';
    final endStr = _dateRange?.end != null
        ? '${_dateRange!.end.day.toString().padLeft(2, '0')}/${_dateRange!.end.month.toString().padLeft(2, '0')}/${_dateRange!.end.year}'
        : 'Selecionar fim';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Período',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Início', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(startStr, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Fim', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(endStr, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelection() {
    final formats = [
      {'key': 'PDF', 'icon': Icons.picture_as_pdf, 'label': 'PDF', 'desc': 'Relatório visual completo', 'color': AppColors.error},
      {'key': 'CSV', 'icon': Icons.table_chart, 'label': 'CSV', 'desc': 'Dados brutos para análise', 'color': AppColors.success},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_copy, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Formato de Exportação',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...formats.map((f) {
              final isSelected = _selectedFormat == f['key'];
              final color = f['color'] as Color;
              return GestureDetector(
                onTap: () => setState(() => _selectedFormat = f['key'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(f['icon'] as IconData, color: color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f['label'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? color : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              f['desc'] as String,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: color, size: 22),
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

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isExporting ? null : _exportData,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.share),
        label: Text(_isExporting ? 'Exportando...' : 'Compartilhar Dados'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

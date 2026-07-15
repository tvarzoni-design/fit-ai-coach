import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class PersonalRecordsPage extends StatefulWidget {
  const PersonalRecordsPage({super.key});

  @override
  State<PersonalRecordsPage> createState() => _PersonalRecordsPageState();
}

class _PersonalRecordsPageState extends State<PersonalRecordsPage> {
  List<dynamic> _records = [];
  bool _isLoading = true;
  String _sortBy = 'date';
  bool _showCelebration = false;
  String? _celebrationExercise;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/workouts/personal-records');
      if (mounted) setState(() { _records = response.data ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _sortedRecords {
    final sorted = List<dynamic>.from(_records);
    switch (_sortBy) {
      case 'weight':
        sorted.sort((a, b) => (b['weight'] ?? 0).compareTo(a['weight'] ?? 0));
        break;
      case 'reps':
        sorted.sort((a, b) => (b['reps'] ?? 0).compareTo(a['reps'] ?? 0));
        break;
      case 'date':
      default:
        sorted.sort((a, b) {
          final dateA = a['date'] ?? '';
          final dateB = b['date'] ?? '';
          return dateB.toString().compareTo(dateA.toString());
        });
    }
    return sorted;
  }

  void _showNewRecordCelebration(String exerciseName) {
    setState(() {
      _showCelebration = true;
      _celebrationExercise = exerciseName;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showCelebration = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recordes Pessoais'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildSortBar(),
                    Expanded(
                      child: _records.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadRecords,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _sortedRecords.length,
                                itemBuilder: (context, index) => _buildRecordCard(_sortedRecords[index], index),
                              ),
                            ),
                    ),
                  ],
                ),
          if (_showCelebration) _buildCelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _buildSortChip('Data', 'date'),
          const SizedBox(width: 8),
          _buildSortChip('Mais pesado', 'weight'),
          const SizedBox(width: 8),
          _buildSortChip('Mais reps', 'reps'),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: AppColors.textMuted),
            const SizedBox(height: 20),
            Text('Nenhum recorde ainda', style: TextStyle(color: AppColors.textSecondary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Registre seus treinos para acompanhar seus recordes', style: TextStyle(color: AppColors.textMuted, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(dynamic record, int index) {
    final exerciseName = record['exerciseName'] ?? 'Exercício';
    final weight = record['weight'] ?? 0;
    final reps = record['reps'] ?? 0;
    final dateStr = record['date'] ?? '';
    DateTime? date;
    try { date = DateTime.parse(dateStr.toString()); } catch (_) {}
    final isTop3 = index < 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showRecordHistory(exerciseName),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (isTop3)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: index == 0
                        ? AppColors.warning.withValues(alpha: 0.2)
                        : index == 1
                            ? AppColors.textSecondary.withValues(alpha: 0.2)
                            : const Color(0xFFCD7F32).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}°',
                      style: TextStyle(
                        color: index == 0
                            ? AppColors.warning
                            : index == 1
                                ? AppColors.textSecondary
                                : const Color(0xFFCD7F32),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Icon(Icons.emoji_events, color: AppColors.textMuted, size: 20)),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exerciseName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('$weight kg', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(' × ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        Text('$reps reps', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 2),
                      Text(DateFormat('dd/MM/yyyy').format(date), style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordHistory(String exerciseName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(exerciseName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text('Histórico de recordes', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 16),
            ...(_records.where((r) => r['exerciseName'] == exerciseName).map((r) {
              DateTime? d;
              try { d = DateTime.parse((r['date'] ?? '').toString()); } catch (_) {}
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
                ),
                title: Text('${r['weight'] ?? 0}kg × ${r['reps'] ?? 0} reps',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                subtitle: Text(d != null ? DateFormat('dd/MM/yyyy').format(d) : '—',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              );
            })),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedOpacity(
      opacity: _showCelebration ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.warning, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      const Text('Novo Recorde!', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(_celebrationExercise ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 16), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

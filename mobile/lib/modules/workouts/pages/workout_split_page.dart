import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutSplitPage extends StatefulWidget {
  const WorkoutSplitPage({super.key});

  @override
  State<WorkoutSplitPage> createState() => _WorkoutSplitPageState();
}

class _WorkoutSplitPageState extends State<WorkoutSplitPage> {
  final List<String> _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
  final Map<String, String?> _split = {};
  bool _isCustom = false;
  String _templateName = 'Meu Split';
  bool _isSaving = false;

  final List<Map<String, dynamic>> _templates = [
    {
      'name': 'Push/Pull/Legs',
      'days': {'Seg': 'Push', 'Ter': 'Pull', 'Qua': 'Legs', 'Qui': 'Push', 'Sex': 'Pull', 'Sab': 'Legs', 'Dom': null},
    },
    {
      'name': 'Upper/Lower',
      'days': {'Seg': 'Upper', 'Ter': 'Lower', 'Qua': 'Upper', 'Qui': 'Lower', 'Sex': null, 'Sab': null, 'Dom': null},
    },
    {
      'name': 'Full Body',
      'days': {'Seg': 'Full Body', 'Ter': null, 'Qua': 'Full Body', 'Qui': null, 'Sex': 'Full Body', 'Sab': null, 'Dom': null},
    },
  ];

  final List<String> _muscleGroups = [
    'Push', 'Pull', 'Legs', 'Upper', 'Lower', 'Full Body',
    'Chest', 'Back', 'Shoulders', 'Arms', 'Core', 'Rest',
  ];

  final Color _getGroupColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _applyTemplate(0);
  }

  Color _groupColor(String? group) {
    switch (group) {
      case 'Push':
        return const Color(0xFF6C63FF);
      case 'Pull':
        return const Color(0xFF4CAF50);
      case 'Legs':
        return const Color(0xFFFF6584);
      case 'Upper':
        return const Color(0xFF2196F3);
      case 'Lower':
        return const Color(0xFFFF9800);
      case 'Full Body':
        return const Color(0xFF9C27B0);
      case 'Chest':
        return const Color(0xFF6C63FF);
      case 'Back':
        return const Color(0xFF4CAF50);
      case 'Shoulders':
        return const Color(0xFF2196F3);
      case 'Arms':
        return const Color(0xFFFF6584);
      case 'Core':
        return const Color(0xFFFF9800);
      case 'Rest':
        return AppColors.textMuted;
      default:
        return AppColors.surfaceLight;
    }
  }

  void _applyTemplate(int index) {
    final template = _templates[index];
    setState(() {
      _templateName = template['name'];
      _isCustom = false;
      _split.clear();
      (template['days'] as Map<String, String?>).forEach((day, group) {
        _split[day] = group;
      });
    });
  }

  void _clearSplit() {
    setState(() {
      _isCustom = true;
      _templateName = '';
      for (final day in _days) {
        _split[day] = null;
      }
    });
  }

  void _assignGroup(String day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Atribuir grupo - $day', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleGroups.map((group) {
                final color = _groupColor(group);
                return GestureDetector(
                  onTap: () {
                    setState(() => _split[day] = group);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(group, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (_split[day] != null)
              TextButton.icon(
                onPressed: () {
                  setState(() => _split[day] = null);
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Limpar dia'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSplit() async {
    setState(() => _isSaving = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/workouts/split', data: {
        'name': _templateName.isEmpty ? 'Meu Split' : _templateName,
        'days': _split,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Split salvo com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar split')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Workout Split'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTemplateSelector(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(hintText: 'Nome do split'),
                          controller: TextEditingController(text: _templateName)
                            ..selection = TextSelection.fromPosition(TextPosition(offset: _templateName.length)),
                          onChanged: (v) => setState(() {
                            _templateName = v;
                            _isCustom = true;
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.calendar_view_week, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Semanal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildWeekGrid(),
                  const SizedBox(height: 24),
                  _buildLegend(),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Templates', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _templates.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == _templates.length) {
                return GestureDetector(
                  onTap: _clearSplit,
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isCustom ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _isCustom ? AppColors.primary : Colors.transparent),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppColors.primary, size: 28),
                        const SizedBox(height: 6),
                        Text('Custom', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }
              final template = _templates[index];
              final isActive = !_isCustom && _templateName == template['name'];
              return GestureDetector(
                onTap: () => _applyTemplate(index),
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isActive ? AppColors.primary : Colors.transparent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(template['name'], style: TextStyle(color: isActive ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      ...((template['days'] as Map).values.where((v) => v != null).take(3).map((v) =>
                        Text(v!, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekGrid() {
    return Column(
      children: _days.map((day) {
        final group = _split[day];
        final color = _groupColor(group);
        return Dismissible(
          key: Key(day),
          onDismissed: (_) => setState(() => _split[day] = null),
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
          child: GestureDetector(
            onTap: () => _assignGroup(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: group != null ? color.withValues(alpha: 0.15) : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: group != null ? color.withValues(alpha: 0.4) : Colors.transparent),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(day, style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  if (group != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(group, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                    )
                  else
                    Text('Toque para atribuir', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend() {
    final usedGroups = _split.values.where((g) => g != null).toSet().toList();
    if (usedGroups.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grupos asignados', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: usedGroups.map((group) {
            final color = _groupColor(group);
            final count = _split.values.where((g) => g == group).length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('$group ($count)', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.surfaceLight))),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveSplit,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: _isSaving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Salvar Split'),
        ),
      ),
    );
  }
}

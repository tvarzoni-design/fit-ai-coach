import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class StressTrackerPage extends StatefulWidget {
  const StressTrackerPage({super.key});

  @override
  State<StressTrackerPage> createState() => _StressTrackerPageState();
}

class _StressTrackerPageState extends State<StressTrackerPage> {
  int _stressLevel = 5;
  final Set<String> _selectedTriggers = {};
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _history = [];

  final List<Map<String, dynamic>> _triggers = [
    {'id': 'work', 'label': 'Trabalho', 'icon': Icons.work, 'color': AppColors.error},
    {'id': 'training', 'label': 'Treino', 'icon': Icons.fitness_center, 'color': AppColors.primary},
    {'id': 'sleep', 'label': 'Sono', 'icon': Icons.bedtime, 'color': AppColors.info},
    {'id': 'nutrition', 'label': 'Nutrição', 'icon': Icons.restaurant, 'color': AppColors.success},
    {'id': 'personal', 'label': 'Pessoal', 'icon': Icons.person, 'color': AppColors.secondary},
    {'id': 'health', 'label': 'Saúde', 'icon': Icons.favorite, 'color': AppColors.warning},
  ];

  final List<Map<String, dynamic>> _copingStrategies = [
    {'name': 'Respiração Profunda', 'description': '5 min de respiração diafragmática', 'icon': Icons.air, 'color': AppColors.info},
    {'name': 'Caminhada', 'description': '15 min ao ar livre', 'icon': Icons.directions_walk, 'color': AppColors.success},
    {'name': 'Meditação', 'description': '10 min de mindfulness', 'icon': Icons.self_improvement, 'color': AppColors.primary},
    {'name': 'Alongamento', 'description': '10 min deAlongamento suave', 'icon': Icons.accessibility_new, 'color': AppColors.warning},
    {'name': 'Journaling', 'description': 'Escreva seus pensamentos', 'icon': Icons.edit_note, 'color': AppColors.secondary},
    {'name': 'Música', 'description': 'Ouça música relaxante', 'icon': Icons.music_note, 'color': AppColors.error},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/health/stress');
      if (mounted) {
        setState(() {
          _history = (response.data['history'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e))
              .toList() ?? [];
        });
      }
    } catch (e) {
      _history = [
        {'date': '14/07', 'level': 6, 'triggers': ['trabalho']},
        {'date': '13/07', 'level': 4, 'triggers': ['treino']},
        {'date': '12/07', 'level': 7, 'triggers': ['trabalho', 'sono']},
        {'date': '11/07', 'level': 3, 'triggers': []},
        {'date': '10/07', 'level': 5, 'triggers': ['pessoal']},
      ];
    }
  }

  Color _stressColor(int level) {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  String _stressLabel(int level) {
    if (level <= 2) return 'Muito Baixo';
    if (level <= 4) return 'Baixo';
    if (level <= 6) return 'Moderado';
    if (level <= 8) return 'Alto';
    return 'Muito Alto';
  }

  Future<void> _submitLog() async {
    setState(() => _isSubmitting = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/health/stress', data: {
        'level': _stressLevel,
        'triggers': _selectedTriggers.toList(),
        'notes': _notesController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estresse registrado com sucesso!')),
        );
        _loadHistory();
        setState(() {
          _stressLevel = 5;
          _selectedTriggers.clear();
          _notesController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao registrar estresse')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Estresse'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStressLevelCard(),
            const SizedBox(height: 20),
            _buildTriggersSection(),
            const SizedBox(height: 20),
            _buildHistorySection(),
            const SizedBox(height: 20),
            _buildCopingSection(),
            const SizedBox(height: 20),
            _buildNotesSection(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStressLevelCard() {
    final color = _stressColor(_stressLevel);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Nível de Estresse', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              '$_stressLevel',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
            ),
            Text(_stressLabel(_stressLevel), style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: color,
                overlayColor: color.withValues(alpha: 0.2),
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              ),
              child: Slider(
                value: _stressLevel.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setState(() => _stressLevel = v.round()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calmo', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text('Muito Estressado', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gatilhos de Estresse', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Selecione o que está contribuindo', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _triggers.map((trigger) {
            final isSelected = _selectedTriggers.contains(trigger['id']);
            final color = trigger['color'] as Color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTriggers.remove(trigger['id']);
                  } else {
                    _selectedTriggers.add(trigger['id']);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trigger['icon'] as IconData, color: isSelected ? color : AppColors.textMuted, size: 18),
                    const SizedBox(width: 6),
                    Text(trigger['label'], style: TextStyle(
                      color: isSelected ? color : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Tendências', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${_history.length} registros', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _history.isEmpty
                ? Center(child: Text('Nenhum registro ainda', style: TextStyle(color: AppColors.textMuted)))
                : Column(
                    children: [
                      SizedBox(
                        height: 120,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _history.reversed.toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final record = entry.value;
                            final level = record['level'] as int;
                            final color = _stressColor(level);
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: index < _history.length - 1 ? 6 : 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('$level', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: (level / 10) * 80,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(record['date'], style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology, color: AppColors.info, size: 20),
            const SizedBox(width: 8),
            Text('Estratégias de Enfrentamento', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
          ),
          itemCount: _copingStrategies.length,
          itemBuilder: (context, index) {
            final strategy = _copingStrategies[index];
            final color = strategy['color'] as Color;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(strategy['icon'] as IconData, color: color, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(strategy['name'], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(strategy['description'], style: TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notas Adicionais', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Algo que queira registrar...', alignLabelWithHint: true),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitLog,
        icon: _isSubmitting
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save),
        label: const Text('Registrar Estresse'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }
}

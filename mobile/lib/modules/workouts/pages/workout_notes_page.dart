import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutNotesPage extends StatefulWidget {
  const WorkoutNotesPage({super.key});

  @override
  State<WorkoutNotesPage> createState() => _WorkoutNotesPageState();
}

class _WorkoutNotesPageState extends State<WorkoutNotesPage> {
  List<Map<String, dynamic>> _notes = [];
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
      final response = await api.dio.get('/workouts/notes');
      if (mounted) {
        setState(() {
          _notes = List<Map<String, dynamic>>.from(response.data ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notes = [
            {
              'id': '1',
              'workoutName': 'Treino A - Peito e Tríceps',
              'date': '2025-07-14T10:30:00',
              'note': 'Sentindo-me forte hoje. Aumentei a carga no supino.',
              'mood': 'great',
              'rpe': 7,
              'tags': ['força', 'progressão'],
            },
            {
              'id': '2',
              'workoutName': 'Treino B - Costas e Bíceps',
              'date': '2025-07-12T09:00:00',
              'note': 'Dor lombar leve, tive que ajustar a postura no remador.',
              'mood': 'okay',
              'rpe': 6,
              'tags': ['postura', 'atenção'],
            },
            {
              'id': '3',
              'workoutName': 'Treino C - Pernas',
              'date': '2025-07-10T11:00:00',
              'note': 'Excelente sessão! Novo recorde no agachamento.',
              'mood': 'great',
              'rpe': 9,
              'tags': ['recorde', 'perna', 'intenso'],
            },
            {
              'id': '4',
              'workoutName': 'Cardio - Corrida',
              'date': '2025-07-09T07:00:00',
              'note': '5km em 28 min. Ritmo melhorando.',
              'mood': 'good',
              'rpe': 5,
              'tags': ['cardio', 'resistência'],
            },
          ];
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'great':
        return '💪';
      case 'good':
        return '😊';
      case 'okay':
        return '😐';
      case 'bad':
        return '😔';
      case 'terrible':
        return '😫';
      default:
        return '😐';
    }
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case 'great':
        return 'Ótimo';
      case 'good':
        return 'Bom';
      case 'okay':
        return 'Razoável';
      case 'bad':
        return 'Ruim';
      case 'terrible':
        return 'Péssimo';
      default:
        return 'Neutro';
    }
  }

  Color _getRpeColor(int rpe) {
    if (rpe <= 3) return AppColors.success;
    if (rpe <= 6) return AppColors.info;
    if (rpe <= 8) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas de Treino'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteSheet,
        icon: const Icon(Icons.add),
        label: const Text('Nova Nota'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_add_outlined, color: AppColors.textMuted, size: 64),
                      const SizedBox(height: 16),
                      Text('Nenhuma nota ainda', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Adicione notas aos seus treinos para\nacompanhar seu progresso', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) => _buildNoteCard(_notes[index]),
                  ),
                ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final rpe = note['rpe'] ?? 5;
    final mood = note['mood'] ?? 'okay';
    final tags = List<String>.from(note['tags'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_getMoodEmoji(mood), style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note['workoutName'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(_formatDate(note['date'] ?? ''), style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRpeColor(rpe).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('RPE $rpe', style: TextStyle(color: _getRpeColor(rpe), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(note['note'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(tag, style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w500)),
                    )).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(_getMoodLabel(mood), style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18),
                  onPressed: () {
                    setState(() => _notes.removeWhere((n) => n['id'] == note['id']));
                  },
                  color: AppColors.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteSheet() {
    final noteController = TextEditingController();
    String selectedMood = 'okay';
    double selectedRpe = 5;
    final tagsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
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
                const SizedBox(height: 20),
                Text('Nova Nota de Treino', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text('Como você se sentiu?', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMoodOption('terrible', '😫', 'Péssimo', selectedMood, (m) => setModalState(() => selectedMood = m)),
                    _buildMoodOption('bad', '😔', 'Ruim', selectedMood, (m) => setModalState(() => selectedMood = m)),
                    _buildMoodOption('okay', '😐', 'Ok', selectedMood, (m) => setModalState(() => selectedMood = m)),
                    _buildMoodOption('good', '😊', 'Bom', selectedMood, (m) => setModalState(() => selectedMood = m)),
                    _buildMoodOption('great', '💪', 'Ótimo', selectedMood, (m) => setModalState(() => selectedMood = m)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RPE (Esforço)', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    Text('${selectedRpe.toInt()}/10', style: TextStyle(color: _getRpeColor(selectedRpe.toInt()), fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: selectedRpe,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: _getRpeColor(selectedRpe.toInt()),
                  inactiveColor: AppColors.surfaceLight,
                  onChanged: (v) => setModalState(() => selectedRpe = v),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fácil', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    Text('Máximo', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Suas anotações'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(labelText: 'Tags (separadas por vírgula)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final note = noteController.text.trim();
                      final tags = tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                      if (note.isNotEmpty) {
                        setState(() => _notes.insert(0, {
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'workoutName': 'Novo Treino',
                              'date': DateTime.now().toIso8601String(),
                              'note': note,
                              'mood': selectedMood,
                              'rpe': selectedRpe.toInt(),
                              'tags': tags,
                            }));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Salvar Nota'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOption(String mood, String emoji, String label, String selected, ValueChanged<String> onTap) {
    final isSelected = selected == mood;
    return GestureDetector(
      onTap: () => onTap(mood),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
            ),
            child: Text(emoji, style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          )),
        ],
      ),
    );
  }
}

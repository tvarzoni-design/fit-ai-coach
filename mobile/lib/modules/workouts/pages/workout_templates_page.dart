import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class WorkoutTemplatesPage extends StatefulWidget {
  const WorkoutTemplatesPage({super.key});

  @override
  State<WorkoutTemplatesPage> createState() => _WorkoutTemplatesPageState();
}

class _WorkoutTemplatesPageState extends State<WorkoutTemplatesPage> {
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  Map<String, dynamic>? _selectedTemplate;

  final List<String> _categories = ['Todos', 'Full Body', 'Push/Pull/Legs', 'Upper/Lower', 'ABC', 'Custom'];

  final List<Map<String, dynamic>> _templates = [
    {'id': '1', 'name': 'Full Body Força', 'category': 'Full Body', 'exercises': 8, 'duration': 60, 'difficulty': 'Intermediário', 'exerciseList': ['Supino Reto', 'Agachamento Livre', 'Remada Curvada', 'Desenvolvimento', 'Leg Press', 'Puxada Frontal', 'Cadeira Extensora', 'Rosca Direta']},
    {'id': '2', 'name': 'Push Day', 'category': 'Push/Pull/Legs', 'exercises': 6, 'duration': 50, 'difficulty': 'Intermediário', 'exerciseList': ['Supino Reto', 'Supino Inclinado', 'Desenvolvimento', 'Elevação Lateral', 'Tríceps Pulley', 'Tríceps Testa']},
    {'id': '3', 'name': 'Pull Day', 'category': 'Push/Pull/Legs', 'exercises': 6, 'duration': 50, 'difficulty': 'Intermediário', 'exerciseList': ['Puxada Frontal', 'Remada Curvada', 'Remada Unilateral', 'Face Pull', 'Rosca Direta', 'Rosca Martelo']},
    {'id': '4', 'name': 'Leg Day', 'category': 'Push/Pull/Legs', 'exercises': 7, 'duration': 55, 'difficulty': 'Avançado', 'exerciseList': ['Agachamento Livre', 'Leg Press', 'Cadeira Extensora', 'Mesa Flexora', 'Stiff', 'Panturrilha em Pé', 'Panturrilha Sentado']},
    {'id': '5', 'name': 'Upper A', 'category': 'Upper/Lower', 'exercises': 7, 'duration': 50, 'difficulty': 'Intermediário', 'exerciseList': ['Supino Reto', 'Puxada Frontal', 'Desenvolvimento', 'Remada Curvada', 'Elevação Lateral', 'Bíceps', 'Tríceps']},
    {'id': '6', 'name': 'Lower A', 'category': 'Upper/Lower', 'exercises': 6, 'duration': 45, 'difficulty': 'Intermediário', 'exerciseList': ['Agachamento Livre', 'Leg Press', 'Cadeira Extensora', 'Mesa Flexora', 'Stiff', 'Panturrilha']},
    {'id': '7', 'name': 'Treino ABC - A', 'category': 'ABC', 'exercises': 6, 'duration': 50, 'difficulty': 'Iniciante', 'exerciseList': ['Supino Reto', 'Supino Inclinado', 'Crucifixo', 'Tríceps Pulley', 'Tríceps Testa', 'Abdominal']},
    {'id': '8', 'name': 'Treino ABC - B', 'category': 'ABC', 'exercises': 6, 'duration': 50, 'difficulty': 'Iniciante', 'exerciseList': ['Puxada Frontal', 'Remada Curvada', 'Remada Unilateral', 'Rosca Direta', 'Rosca Martelo', 'Abdominal']},
    {'id': '9', 'name': 'Treino ABC - C', 'category': 'ABC', 'exercises': 7, 'duration': 55, 'difficulty': 'Iniciante', 'exerciseList': ['Agachamento Livre', 'Leg Press', 'Cadeira Extensora', 'Mesa Flexora', 'Panturrilha em Pé', 'Abdominal', 'Prancha']},
    {'id': '10', 'name': 'Meu Treino', 'category': 'Custom', 'exercises': 5, 'duration': 40, 'difficulty': 'Iniciante', 'exerciseList': ['Supino Reto', 'Agachamento Livre', 'Remada', 'Desenvolvimento', 'Abdominal']},
  ];

  List<Map<String, dynamic>> get _filteredTemplates {
    return _templates.where((t) {
      final matchCategory = _selectedCategory == 'Todos' || t['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty || t['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Templates de Treino'),
      ),
      body: _selectedTemplate != null ? _buildTemplateDetail() : _buildTemplateList(),
    );
  }

  Widget _buildTemplateList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Buscar template...', prefixIcon: Icon(Icons.search)),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                  ),
                  child: Center(child: Text(cat, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredTemplates.length,
            itemBuilder: (context, index) => _buildTemplateCard(_filteredTemplates[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final diffColor = template['difficulty'] == 'Iniciante'
        ? AppColors.success
        : template['difficulty'] == 'Intermediário'
            ? AppColors.warning
            : AppColors.error;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedTemplate = template),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.fitness_center, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(template['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${template['exercises']} exercícios • ${template['duration']} min', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: diffColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(template['difficulty'], style: TextStyle(color: diffColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateDetail() {
    final template = _selectedTemplate!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => setState(() => _selectedTemplate = null),
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 8),
                Text(template['name'], style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDetailChip(Icons.fitness_center, '${template['exercises']} exercícios'),
                    const SizedBox(width: 12),
                    _buildDetailChip(Icons.timer_outlined, '${template['duration']} min'),
                    const SizedBox(width: 12),
                    _buildDetailChip(Icons.signal_cellular_alt, template['difficulty']),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Exercícios', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...List.generate(template['exerciseList'].length, (i) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Text('${i + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                    ),
                    title: Text(template['exerciseList'][i], style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                )),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/create-workout'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Usar Template'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

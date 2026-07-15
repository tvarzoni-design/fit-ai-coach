import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ExerciseTipsPage extends StatelessWidget {
  final String exerciseName;

  const ExerciseTipsPage({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    final tips = _getTipsForExercise(exerciseName);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: Text('Dicas - $exerciseName'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, tips),
            const SizedBox(height: 24),
            _buildSection('Forma Correta', Icons.check_circle_outline, AppColors.success, tips['formCues'] as List<Map<String, String>>),
            const SizedBox(height: 20),
            _buildSection('Erros Comuns', Icons.error_outline, AppColors.error, tips['mistakes'] as List<Map<String, String>>),
            const SizedBox(height: 20),
            _buildBreathingSection(context, tips['breathing'] as Map<String, String>),
            const SizedBox(height: 20),
            _buildVariationsSection(context, tips['variations'] as List<String>),
            const SizedBox(height: 20),
            _buildMuscleIllustration(context, tips['muscles'] as List<Map<String, dynamic>>),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> tips) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(tips['icon'] as IconData? ?? Icons.fitness_center, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(tips['difficulty'] ?? 'Intermediário', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(tips['description'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(item['detail']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildBreathingSection(BuildContext context, Map<String, String> breathing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.air, color: AppColors.info, size: 20),
            const SizedBox(width: 8),
            Text('Respiração', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.info)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBreathingRow(Icons.arrow_downward, 'Inspire', breathing['inhale'] ?? '', AppColors.info),
                const SizedBox(height: 12),
                _buildBreathingRow(Icons.arrow_upward, 'Expire', breathing['exhale'] ?? '', AppColors.primary),
                const SizedBox(height: 12),
                _buildBreathingRow(Icons.pause, 'Prenda', breathing['hold'] ?? '', AppColors.warning),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingRow(IconData icon, String phase, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(phase, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
              Text(description, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVariationsSection(BuildContext context, List<String> variations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.swap_horiz, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Text('Variações', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variations.map((v) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Text(v, style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w500)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMuscleIllustration(BuildContext context, List<Map<String, dynamic>> muscles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.accessibility_new, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text('Músculos Trabalhados', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: muscles.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    ),
                    Expanded(
                      flex: 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (m['activation'] as double) / 100,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            m['activation'] >= 80 ? AppColors.success : m['activation'] >= 50 ? AppColors.warning : AppColors.info,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 36,
                      child: Text('${m['activation']}%', style: TextStyle(
                        color: m['activation'] >= 80 ? AppColors.success : m['activation'] >= 50 ? AppColors.warning : AppColors.info,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      )),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getTipsForExercise(String name) {
    final allTips = <String, Map<String, dynamic>>{
      'Supino Reto': {
        'icon': Icons.fitness_center,
        'difficulty': 'Intermediário',
        'description': 'Exercício composto para peito, ombros e tríceps. Fundamental para desenvolvimento do peitoral.',
        'formCues': [
          {'title': 'Escápulas retraídas', 'detail': 'Mantenha as escápulas juntas e apoiadas no banco'},
          {'title': 'Arco natural', 'detail': 'Mantenha uma leve lordose lombar natural'},
          {'title': 'Pés firmes', 'detail': 'Mantenha os pés apoiados no chão para estabilidade'},
          {'title': 'Agarre adequado', 'detail': 'Pegada ligeiramente mais larga que os ombros'},
        ],
        'mistakes': [
          {'title': 'Bater o peso no peito', 'detail': 'Controle a descida e toque levemente'},
          {'title': 'Levantar o bumbum', 'detail': 'Mantenha o quadril no banco durante todo o movimento'},
          {'title': 'Cotovelos abertos demais', 'detail': 'Mantenha cotovelos a 45-75 graus do corpo'},
          {'title': 'Amplitude incompleta', 'detail': 'Desça até o peito e suba até extensão quase completa'},
        ],
        'breathing': {
          'inhale': 'Durante a fase excêntrica (descida)',
          'exhale': 'Durante a fase concêntrica (subida)',
          'hold': 'Não prenda a respiração',
        },
        'variations': ['Supino Inclinado', 'Supino Declinado', 'Supino com Halteres', 'Supino com Barra', 'Smith Machine'],
        'muscles': [
          {'name': 'Peitoral Maior', 'activation': 95},
          {'name': 'Deltóide Anterior', 'activation': 75},
          {'name': 'Tríceps', 'activation': 70},
          {'name': 'Serrátil Anterior', 'activation': 40},
        ],
      },
      'Agachamento Livre': {
        'icon': Icons.fitness_center,
        'difficulty': 'Avançado',
        'description': 'Exercício composto para pernas e glúteos. O rei dos exercícios para membros inferiores.',
        'formCues': [
          {'title': 'Pés na largura dos ombros', 'detail': 'Ponta dos pés levemente apontada para fora'},
          {'title': 'Joelhos alinhados', 'detail': 'Joelhos devem seguir a direção dos pés'},
          {'title': 'Coluna neutra', 'detail': 'Mantenha o core ativado e coluna reta'},
          {'title': 'Profundidade adequada', 'detail': 'Desça até as coxas paralelas ao chão ou mais'},
        ],
        'mistakes': [
          {'title': 'Joelhos para dentro', 'detail': 'Mantenha joelhos alinhados com os pés'},
          {'title': 'Heels levantados', 'detail': 'Mantenha os calcanhares firmes no chão'},
          {'title': 'Costas arredondadas', 'detail': 'Mantenha o peito aberto e coluna neutra'},
          {'title': 'Descer rápido demais', 'detail': 'Controle a descida por 2-3 segundos'},
        ],
        'breathing': {
          'inhale': 'Antes de descer (fase excêntrica)',
          'exhale': 'Ao subir (fase concêntrica)',
          'hold': 'Prenda levemente no ponto mais baixo',
        },
        'variations': ['Front Squat', 'Goblet Squat', 'Bulgarian Split Squat', 'Hack Squat', 'Box Squat'],
        'muscles': [
          {'name': 'Quadríceps', 'activation': 90},
          {'name': 'Glúteos', 'activation': 85},
          {'name': 'Isquiotibiais', 'activation': 60},
          {'name': 'Lombar', 'activation': 50},
        ],
      },
    };

    return allTips[name] ?? {
      'icon': Icons.fitness_center,
      'difficulty': 'Intermediário',
      'description': 'Exercício composto que trabalha múltiplos grupos musculares. Foque na forma correta para máxima eficiência.',
      'formCues': [
        {'title': 'Postura correta', 'detail': 'Mantenha a coluna neutra durante todo o movimento'},
        {'title': 'Controle o movimento', 'detail': 'Execute cada repetição de forma controlada'},
        {'title': 'Amplitude completa', 'detail': 'Use toda a amplitude de movimento disponível'},
        {'title': 'Core ativado', 'detail': 'Mantenha o abdômen contraído durante o exercício'},
      ],
      'mistakes': [
        {'title': 'Usar impulso', 'detail': 'Evite balançar o corpo para levantar o peso'},
        {'title': 'Respiração inadequada', 'detail': 'Não prenda a respiração durante o esforço'},
        {'title': 'Peso excessivo', 'detail': 'Reduza o peso se não conseguir manter a forma'},
        {'title': 'Descanso insuficiente', 'detail': 'Respeite os intervalos entre séries'},
      ],
      'breathing': {
        'inhale': 'Durante a fase de preparação',
        'exhale': 'Durante o esforço principal',
        'hold': 'Não prenda a respiração',
      },
      'variations': ['Variação com halteres', 'Variação na máquina', 'Variação unilateral', 'Variação com elástico'],
      'muscles': [
        {'name': 'Músculo Principal', 'activation': 90},
        {'name': 'Músculo Secundário', 'activation': 60},
        {'name': 'Músculo Estabilizador', 'activation': 40},
      ],
    };
  }
}

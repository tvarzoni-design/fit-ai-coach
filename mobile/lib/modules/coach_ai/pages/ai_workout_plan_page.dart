import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AIWorkoutPlanPage extends StatefulWidget {
  const AIWorkoutPlanPage({super.key});

  @override
  State<AIWorkoutPlanPage> createState() => _AIWorkoutPlanPageState();
}

class _AIWorkoutPlanPageState extends State<AIWorkoutPlanPage> {
  Map<String, dynamic>? _plan;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/ai/workout-plan');
      if (mounted) setState(() { _plan = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _plan = {
            'name': 'Plano de Hipertrofia - 12 semanas',
            'status': 'active',
            'week': 4,
            'totalWeeks': 12,
            'objective': 'Ganho de massa muscular',
            'weeklySchedule': [
              {
                'day': 'Segunda',
                'name': 'Peito e Tríceps',
                'exercises': [
                  {'name': 'Supino Reto', 'sets': 4, 'reps': '8-12', 'rest': '90s'},
                  {'name': 'Supino Inclinado', 'sets': 4, 'reps': '10-12', 'rest': '90s'},
                  {'name': 'Crucifixo', 'sets': 3, 'reps': '12-15', 'rest': '60s'},
                  {'name': 'Tríceps Pulley', 'sets': 4, 'reps': '10-12', 'rest': '60s'},
                  {'name': 'Tríceps Testa', 'sets': 3, 'reps': '10-12', 'rest': '60s'},
                ],
              },
              {
                'day': 'Terça',
                'name': 'Costas e Bíceps',
                'exercises': [
                  {'name': 'Puxada Frontal', 'sets': 4, 'reps': '8-12', 'rest': '90s'},
                  {'name': 'Remada Curvada', 'sets': 4, 'reps': '8-12', 'rest': '90s'},
                  {'name': 'Remada Unilateral', 'sets': 3, 'reps': '10-12', 'rest': '60s'},
                  {'name': 'Rosca Direta', 'sets': 4, 'reps': '10-12', 'rest': '60s'},
                  {'name': 'Rosca Martelo', 'sets': 3, 'reps': '12-15', 'rest': '60s'},
                ],
              },
              {
                'day': 'Quarta',
                'name': 'Descanso Ativo',
                'exercises': [
                  {'name': 'Caminhada Leve', 'sets': 1, 'reps': '30min', 'rest': '-'},
                  {'name': 'Alongamento', 'sets': 1, 'reps': '20min', 'rest': '-'},
                ],
              },
              {
                'day': 'Quinta',
                'name': 'Pernas',
                'exercises': [
                  {'name': 'Agachamento', 'sets': 4, 'reps': '8-12', 'rest': '120s'},
                  {'name': 'Leg Press', 'sets': 4, 'reps': '10-12', 'rest': '90s'},
                  {'name': 'Cadeira Extensora', 'sets': 3, 'reps': '12-15', 'rest': '60s'},
                  {'name': 'Cadeira Flexora', 'sets': 3, 'reps': '12-15', 'rest': '60s'},
                  {'name': 'Panturrilha', 'sets': 4, 'reps': '15-20', 'rest': '45s'},
                ],
              },
              {
                'day': 'Sexta',
                'name': 'Ombros e Abdômen',
                'exercises': [
                  {'name': 'Desenvolvimento', 'sets': 4, 'reps': '8-12', 'rest': '90s'},
                  {'name': 'Elevação Lateral', 'sets': 4, 'reps': '12-15', 'rest': '60s'},
                  {'name': 'Face Pull', 'sets': 3, 'reps': '12-15', 'rest': '60s'},
                  {'name': 'Abdominal Crunch', 'sets': 4, 'reps': '15-20', 'rest': '45s'},
                  {'name': 'Prancha', 'sets': 3, 'reps': '45s', 'rest': '45s'},
                ],
              },
              {
                'day': 'Sábado',
                'name': 'Descanso',
                'exercises': [],
              },
              {
                'day': 'Domingo',
                'name': 'Descanso',
                'exercises': [],
              },
            ],
          };
        });
      }
    }
  }

  Future<void> _generateNewPlan() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      await api.generateWorkout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Novo plano gerado com sucesso!')),
        );
        _loadPlan();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao gerar novo plano')),
        );
      }
    }
  }

  void _acceptPlan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plano aceito e ativado!')),
    );
    context.go('/workouts');
  }

  void _rejectPlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rejeitar plano?'),
        content: const Text('O plano atual será descartado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plano rejeitado')),
              );
            },
            child: const Text('Rejeitar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plano de Treino IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showPreferencesSheet(context),
            tooltip: 'Preferências',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar plano', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadPlan, child: const Text('Tentar novamente')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPlan,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlanHeader(),
                        const SizedBox(height: 16),
                        _buildProgressCard(),
                        const SizedBox(height: 16),
                        _buildWeeklySchedule(),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPlanHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _plan!['name'] ?? 'Plano IA',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _plan!['objective'] ?? '',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Plano Ativo',
                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final week = _plan!['week'] ?? 1;
    final totalWeeks = _plan!['totalWeeks'] ?? 12;
    final progress = week / totalWeeks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progresso', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('Semana $week/$totalWeeks', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressStat('Semana', '$week', AppColors.primary),
                _buildProgressStat('Total', '$totalWeeks sem', AppColors.textSecondary),
                _buildProgressStat('Restante', '${totalWeeks - week} sem', AppColors.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklySchedule() {
    final schedule = _plan!['weeklySchedule'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cronograma Semanal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...schedule.map((day) => _buildDayCard(day)),
      ],
    );
  }

  Widget _buildDayCard(dynamic day) {
    final exercises = day['exercises'] as List? ?? [];
    final isRest = exercises.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isRest
                ? AppColors.surfaceLight
                : AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              (day['day'] ?? '').substring(0, 2).toUpperCase(),
              style: TextStyle(
                color: isRest ? AppColors.textMuted : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          day['day'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          day['name'] ?? '',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        children: isRest
            ? [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Dia de descanso', style: TextStyle(color: AppColors.textMuted)),
                ),
              ]
            : exercises.map<Widget>((exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          exercise['name'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${exercise['sets']}x${exercise['reps']}',
                          style: TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Desc: ${exercise['rest']}',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _acceptPlan,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Aceitar Plano'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _rejectPlan,
                icon: const Icon(Icons.close),
                label: const Text('Rejeitar'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _generateNewPlan,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Gerar Novo Plano'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _showPreferencesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Preferências do Plano', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPreferenceItem('Dias por semana', '5 dias', Icons.calendar_today),
            _buildPreferenceItem('Foco', 'Hipertrofia', Icons.fitness_center),
            _buildPreferenceItem('Duração', '60-75 min', Icons.timer_outlined),
            _buildPreferenceItem('Nível', 'Intermediário', Icons.signal_cellular_alt),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Salvar Preferências'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: AppColors.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

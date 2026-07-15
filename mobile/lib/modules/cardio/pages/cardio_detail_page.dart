import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CardioDetailPage extends StatelessWidget {
  final String sessionId;

  const CardioDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cardio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSessionHeader(context),
            const SizedBox(height: 16),
            _buildSessionStats(context),
            const SizedBox(height: 16),
            _buildHeartRateCard(context),
            const SizedBox(height: 16),
            _buildSplitCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_run,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Corrida ao Ar Livre',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hoje, 07:30',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo da Sessão',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.straighten, '5.2 km', 'Distância'),
                _buildStatItem(Icons.timer, '32:15', 'Duração'),
                _buildStatItem(Icons.speed, '6:12/km', 'Pace'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.local_fire_department, '385 kcal', 'Calorias'),
                _buildStatItem(Icons.favorite, '156 bpm', 'FC Média'),
                _buildStatItem(Icons.trending_up, '182 bpm', 'FC Máx'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHeartRateCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zonas de FC',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeartRateZone('Zona 5 (Máxima)', 8, AppColors.error),
            _buildHeartRateZone('Zona 4 (Anaeróbico)', 22, AppColors.warning),
            _buildHeartRateZone('Zona 3 (Aeróbico)', 45, AppColors.success),
            _buildHeartRateZone('Zona 2 (Queima)', 20, AppColors.info),
            _buildHeartRateZone('Zona 1 (Aquec.)', 5, AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateZone(String label, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitCard(BuildContext context) {
    final splits = [
      {'km': '1 km', 'time': '6:25', 'pace': '6:25/km'},
      {'km': '2 km', 'time': '6:10', 'pace': '6:10/km'},
      {'km': '3 km', 'time': '6:05', 'pace': '6:05/km'},
      {'km': '4 km', 'time': '6:00', 'pace': '6:00/km'},
      {'km': '5 km', 'time': '5:55', 'pace': '5:55/km'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Splits por Km',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...splits.map((split) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      split['km']!,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      split['time']!,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Text(
                    split['pace']!,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

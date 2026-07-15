import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class HeartRateZonePage extends StatefulWidget {
  const HeartRateZonePage({super.key});

  @override
  State<HeartRateZonePage> createState() => _HeartRateZonePageState();
}

class _HeartRateZonePageState extends State<HeartRateZonePage> {
  bool _isLoading = true;
  List<dynamic> _zones = [];
  int _maxHeartRate = 190;

  final List<Map<String, dynamic>> _defaultZones = [
    {
      'name': 'Repouso',
      'zone': 1,
      'minBPM': 95,
      'maxBPM': 114,
      'color': Color(0xFF4CAF50),
      'timeMinutes': 45,
      'description': 'Atividade leve, aquecimento e recuperação',
      'recommendation': 'Ideal para aquecimento e volta à calma',
    },
    {
      'name': 'Queima de Gordura',
      'zone': 2,
      'minBPM': 114,
      'maxBPM': 133,
      'color': Color(0xFF8BC34A),
      'timeMinutes': 32,
      'description': 'Exercício moderado para queima de gordura',
      'recommendation': 'Mantenha este ritmo por 30-60 minutos para melhores resultados',
    },
    {
      'name': 'Cardio',
      'zone': 3,
      'minBPM': 133,
      'maxBPM': 152,
      'color': Color(0xFFFF9800),
      'timeMinutes': 18,
      'description': 'Exercício intenso para melhorar resistência',
      'recommendation': 'Alterne entre 5-10 minutos nesta zona durante o treino',
    },
    {
      'name': 'Pico',
      'zone': 4,
      'minBPM': 152,
      'maxBPM': 171,
      'color': Color(0xFFFF5722),
      'timeMinutes': 8,
      'description': 'Exercício muito intenso para performance máxima',
      'recommendation': 'Use em intervalos curtos de 1-3 minutos',
    },
    {
      'name': 'Máximo',
      'zone': 5,
      'minBPM': 171,
      'maxBPM': 190,
      'color': Color(0xFFF44336),
      'timeMinutes': 3,
      'description': 'Esforço máximo, capacidade aeróbica',
      'recommendation': 'Apenas para atletas avançados em treinos de alta intensidade',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/health/heart-rate-zones');
      if (mounted) {
        setState(() {
          _zones = response.data is List ? response.data : _defaultZones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _zones = _defaultZones;
          _isLoading = false;
        });
      }
    }
  }

  int get _totalTime => _zones.fold(0, (sum, z) => sum + ((z['timeMinutes'] ?? 0) as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zonas de Frequência Cardíaca'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadZones,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMaxHRHeader(),
                  const SizedBox(height: 16),
                  _buildZoneBarChart(),
                  const SizedBox(height: 16),
                  ..._zones.map((zone) => _buildZoneCard(zone)),
                  const SizedBox(height: 16),
                  _buildRecommendations(),
                ],
              ),
            ),
    );
  }

  Widget _buildMaxHRHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: AppColors.error, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FC Máxima Estimada',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_maxHeartRate bpm',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Tempo Total',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalTime} min',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneBarChart() {
    if (_totalTime == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribuição de Tempo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 28,
              child: Row(
                children: _zones.map((zone) {
                  final minutes = (zone['timeMinutes'] ?? 0) as int;
                  final fraction = _totalTime > 0 ? minutes / _totalTime : 0.0;
                  final color = zone['color'] as Color;
                  return Expanded(
                    flex: (fraction * 1000).round().clamp(1, 1000),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: fraction > 0.08
                          ? Center(
                              child: Text(
                                '$minutes',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: _zones.map((zone) {
                final color = zone['color'] as Color;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      zone['name'],
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneCard(dynamic zone) {
    final color = zone['color'] as Color;
    final minutes = (zone['timeMinutes'] ?? 0) as int;
    final fraction = _totalTime > 0 ? minutes / _totalTime : 0.0;
    final zoneNum = zone['zone'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$zoneNum',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${zone['minBPM']} - ${zone['maxBPM']} bpm',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$minutes min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${(fraction * 100).round()}%',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              zone['description'],
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Recomendações',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._zones.map((zone) {
              final color = zone['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        zone['recommendation'],
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

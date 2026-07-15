import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _gamification;
  Map<String, dynamic>? _dailyCoach;
  List<dynamic> _workouts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final auth = context.read<AuthService>();
      final results = await Future.wait([
        auth.api.getGamificationProfile().catchError((_) => null),
        auth.api.getDailyCoach().catchError((_) => null),
        auth.api.getWorkouts().catchError((_) => null),
      ]);
      if (mounted) {
        setState(() {
          _gamification = results[0]?.data;
          _dailyCoach = results[1]?.data;
          _workouts = results[2]?.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final userName = auth.userName ?? 'Atleta';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fit AI Coach'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push('/notifications')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar dados', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadData, child: const Text('Tentar novamente')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(userName),
                        const SizedBox(height: 24),
                        _buildTodayWorkoutCard(),
                        const SizedBox(height: 16),
                        _buildQuickStats(),
                        const SizedBox(height: 16),
                        _buildAiCoachMessage(),
                        const SizedBox(height: 16),
                        _buildQuickAccessGrid(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting, $name!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Vamos treinar hoje?', style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTodayWorkoutCard() {
    final workoutName = _workouts.isNotEmpty ? (_workouts[0]['name'] ?? 'Treino Personalizado') : 'Sem treinos ainda';
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
                  child: const Icon(Icons.fitness_center, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Treino de Hoje', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(workoutName, style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/workouts'),
                child: const Text('Ver Treinos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final xp = _gamification?['xpTotal'] ?? 0;
    final level = _gamification?['level'] ?? 1;
    final streak = _gamification?['currentStreak'] ?? 0;
    return Row(
      children: [
        Expanded(child: _buildStatCard('Sequência', '$streak dias', AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Nível', '$level', AppColors.info)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('XP', '$xp pts', AppColors.success)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildAiCoachMessage() {
    final message = _dailyCoach?['message'] ?? 'Configure seu objetivo para receber dicas personalizadas!';
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.smart_toy, color: AppColors.primary),
        ),
        title: const Text('Coach IA'),
        subtitle: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/coach'),
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final items = [
      _GridItem(Icons.restaurant, 'Nutrição', '/nutrition', AppColors.success),
      _GridItem(Icons.monitor_weight, 'Análise', '/body-analysis', AppColors.info),
      _GridItem(Icons.psychology, 'Predições', '/predictive', AppColors.warning),
      _GridItem(Icons.people, 'Comunidade', '/community', AppColors.secondary),
      _GridItem(Icons.emoji_events, 'Conquistas', '/achievements', AppColors.primary),
      _GridItem(Icons.stars, 'Desafios', '/daily-challenges', AppColors.warning),
      _GridItem(Icons.leaderboard, 'Ranking', '/leaderboard', AppColors.primary),
      _GridItem(Icons.diamond, 'Premium', '/premium', AppColors.warning),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acesso Rápido', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => context.push(item.route),
              child: Column(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: item.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(height: 6),
                Text(item.label, style: TextStyle(color: AppColors.textSecondary, fontSize: 10), textAlign: TextAlign.center),
              ]),
            );
          },
        ),
      ],
    );
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  _GridItem(this.icon, this.label, this.route, this.color);
}

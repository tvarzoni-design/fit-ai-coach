import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class QuickActionsPage extends StatelessWidget {
  const QuickActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.play_circle_outline,
        label: 'Iniciar Treino',
        route: '/workouts/create',
        color: AppColors.primary,
      ),
      _QuickAction(
        icon: Icons.restaurant_menu,
        label: 'Registrar Refeição',
        route: '/nutrition/log',
        color: AppColors.success,
      ),
      _QuickAction(
        icon: Icons.directions_run,
        label: 'Rastrear Cardio',
        route: '/cardio',
        color: AppColors.info,
      ),
      _QuickAction(
        icon: Icons.chat_bubble_outline,
        label: 'Chat IA',
        route: '/coach',
        color: AppColors.secondary,
      ),
      _QuickAction(
        icon: Icons.qr_code_scanner,
        label: 'Escanear Código',
        route: '/nutrition/scan',
        color: AppColors.warning,
      ),
      _QuickAction(
        icon: Icons.straighten,
        label: 'Medida Corporal',
        route: '/progress/add-measurement',
        color: AppColors.info,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ações Rápidas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(context, action);
          },
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, _QuickAction action) {
    return GestureDetector(
      onTap: () => context.push(action.route),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: action.color, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                action.label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;
  final Color color;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

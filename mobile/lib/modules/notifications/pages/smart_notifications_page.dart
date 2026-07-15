import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SmartNotificationsPage extends StatefulWidget {
  const SmartNotificationsPage({super.key});

  @override
  State<SmartNotificationsPage> createState() => _SmartNotificationsPageState();
}

class _SmartNotificationsPageState extends State<SmartNotificationsPage> {
  List<dynamic> _smartNotifications = [];
  List<dynamic> _notifications = [];
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
      final smartRes = await api.getSmartNotifications();
      final notifRes = await api.getNotifications();
      if (mounted) {
        setState(() {
          _smartNotifications = smartRes.data ?? [];
          _notifications = notifRes.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notificações Inteligentes')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações Inteligentes'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Notificações baseadas no seu padrão de treino e hábitos', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                ]),
              ),
              const SizedBox(height: 20),
              if (_smartNotifications.isEmpty)
                Card(child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('Nenhuma notificação inteligente disponível', style: TextStyle(color: AppColors.textSecondary))),
                ))
              else
                ..._smartNotifications.map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Icon(Icons.notifications, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n['title'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        Text(n['description'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    )),
                  ]),
                )),
              if (_notifications.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Histórico', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._notifications.take(5).map((n) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(Icons.notifications, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n['title'] ?? '', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        Text(n['body'] ?? '', style: TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    )),
                  ]),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import 'package:provider/provider.dart';

class NotificationDetailPage extends StatefulWidget {
  final String notificationId;
  const NotificationDetailPage({super.key, required this.notificationId});
  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  Map<String, dynamic>? _notification;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotification();
  }

  Future<void> _loadNotification() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getNotifications();
      final notifications = response.data as List? ?? [];
      _notification = notifications.firstWhere(
        (n) => n['id'] == widget.notificationId,
        orElse: () => {'title': 'Notificação', 'body': '', 'type': 'system', 'createdAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      _notification = {'title': 'Notificação', 'body': '', 'type': 'system', 'createdAt': DateTime.now().toIso8601String()};
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text('Notificação')), body: Center(child: CircularProgressIndicator()));

    final n = _notification ?? {};
    final type = n['type'] ?? 'system';
    IconData icon;
    Color color;
    switch (type) {
      case 'workout': icon = Icons.fitness_center; color = AppColors.primary; break;
      case 'achievement': icon = Icons.emoji_events; color = AppColors.warning; break;
      default: icon = Icons.info; color = AppColors.info;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificação'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(n['title'] ?? 'Notificação', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18))),
                  ]),
                  const SizedBox(height: 16),
                  Text(n['body'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
                  const SizedBox(height: 12),
                  Text(_formatDate(n['createdAt']), style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () async {
                  try {
                    final api = context.read<AuthService>().api;
                    await api.markNotificationAsRead(widget.notificationId);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marcada como lida')));
                  } catch (e) {}
                  context.pop();
                },
                child: Text('Marcar como Lida'),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(
                onPressed: () async {
                  try {
                    final api = context.read<AuthService>().api;
                    await api.deleteNotification(widget.notificationId);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excluída')));
                  } catch (e) {}
                  context.pop();
                },
                style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.error)),
                child: Text('Excluir', style: TextStyle(color: AppColors.error)),
              )),
            ]),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (e) { return date; }
  }
}

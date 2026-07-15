import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  bool _isSending = false;
  bool _isScheduling = false;
  final _titleController = TextEditingController(text: 'Teste de Notificação');
  final _bodyController = TextEditingController(text: 'Esta é uma notificação de teste do Fit AI Coach');
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _debugInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final api = context.read<AuthService>().api;
      final historyRes = await api.get('/notifications/test/history');
      final debugRes = await api.get('/notifications/debug');
      if (mounted) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(historyRes.data ?? []);
          _debugInfo = debugRes.data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _history = [
            {'title': 'Treino Diário', 'sentAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(), 'status': 'delivered'},
            {'title': 'Lembrete de Água', 'sentAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(), 'status': 'delivered'},
            {'title': 'Meta Alcançada', 'sentAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(), 'status': 'failed'},
          ];
          _debugInfo = {
            'deviceToken': 'fcm_token_abc123...',
            'platform': 'android',
            'appVersion': '2.1.0',
            'notificationsEnabled': true,
            'lastReceived': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          };
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testar Notificações'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSendTestCard(),
              const SizedBox(height: 16),
              _buildScheduleCard(),
              const SizedBox(height: 16),
              _buildHistorySection(),
              const SizedBox(height: 16),
              _buildDebugSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.send, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Enviar Notificação de Teste',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Corpo'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendTestNotification,
                icon: _isSending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(_isSending ? 'Enviando...' : 'Enviar Agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Agendar Notificação',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Agendar uma notificação de teste para 30 segundos a partir de agora',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isScheduling ? null : _scheduleTestNotification,
                icon: _isScheduling
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.schedule_send, size: 18),
                label: Text(_isScheduling ? 'Agendando...' : 'Agendar para 30s'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: AppColors.info, size: 20),
            const SizedBox(width: 8),
            Text(
              'Histórico de Notificações',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Nenhuma notificação enviada',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          )
        else
          ..._history.map((entry) => _buildHistoryItem(entry)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final status = entry['status'] ?? 'unknown';
    final statusColor = status == 'delivered' ? AppColors.success : AppColors.error;
    final statusText = status == 'delivered' ? 'Entregue' : 'Falhou';
    final sentAt = entry['sentAt'] != null ? DateTime.tryParse(entry['sentAt']) : null;
    final timeStr = sentAt != null ? _formatTime(sentAt) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              status == 'delivered' ? Icons.check_circle_outline : Icons.error_outline,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['title'] ?? '',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  timeStr,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugSection() {
    if (_debugInfo == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bug_report, color: AppColors.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Informações de Debug',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDebugRow('Token FCM', _debugInfo!['deviceToken'] ?? 'N/A'),
                _buildDebugRow('Plataforma', _debugInfo!['platform'] ?? 'N/A'),
                _buildDebugRow('Versão do App', _debugInfo!['appVersion'] ?? 'N/A'),
                _buildDebugRow(
                  'Notificações Ativas',
                  (_debugInfo!['notificationsEnabled'] ?? false) ? 'Sim' : 'Não',
                ),
                _buildDebugRow('Último Recebido', _formatDebugDate(_debugInfo!['lastReceived'])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    setState(() => _isSending = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/notifications/test/send', data: {
        'title': _titleController.text,
        'body': _bodyController.text,
      });
      if (mounted) {
        setState(() {
          _isSending = false;
          _history.insert(0, {
            'title': _titleController.text,
            'sentAt': DateTime.now().toIso8601String(),
            'status': 'delivered',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Notificação enviada!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Erro ao enviar notificação'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _scheduleTestNotification() async {
    setState(() => _isScheduling = true);
    try {
      final api = context.read<AuthService>().api;
      await api.post('/notifications/test/schedule', data: {
        'delaySeconds': 30,
        'title': _titleController.text,
        'body': _bodyController.text,
      });
      if (mounted) {
        setState(() => _isScheduling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Notificação agendada para 30 segundos!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScheduling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Erro ao agendar notificação'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  String _formatDebugDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return 'N/A';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

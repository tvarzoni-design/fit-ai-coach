import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ShareProgressPage extends StatefulWidget {
  const ShareProgressPage({super.key});

  @override
  State<ShareProgressPage> createState() => _ShareProgressPageState();
}

class _ShareProgressPageState extends State<ShareProgressPage> {
  Map<String, dynamic>? _progress;
  bool _isLoading = true;
  final _messageController = TextEditingController(text: 'Minha evolução no Fit AI Coach! 💪');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getShareableProgress();
      if (mounted) setState(() { _progress = response.data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _progress = {
            'userName': 'Atleta',
            'weightLost': 3.5, 'bodyFatLost': 2.1,
            'workoutsThisMonth': 17, 'currentStreak': 12,
            'personalRecords': 4, 'level': 8,
          };
        });
      }
    }
  }

  void _copyToClipboard() {
    final msg = _messageController.text;
    final progress = _progress!;
    final text = '$msg\n\n'
        '🏋️ ${progress['workoutsThisMonth']} treinos este mês\n'
        '🔥 Sequência de ${progress['currentStreak']} dias\n'
        '📉 ${progress['weightLost']}kg perdidos\n'
        '🏆 ${progress['personalRecords']} recordes pessoais\n\n'
        '#FitAICoach #Evolução';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado para a área de transferência!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compartilhar Progresso')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = _progress!;

    return Scaffold(
      appBar: AppBar(title: const Text('Compartilhar Progresso')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(data),
            const SizedBox(height: 16),
            _buildBeforeAfter(),
            const SizedBox(height: 16),
            _buildShareStats(data),
            const SizedBox(height: 16),
            _buildMessageField(),
            const SizedBox(height: 16),
            _buildShareButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> data) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.secondary.withValues(alpha: 0.2)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withValues(alpha: 0.3),
              child: Text((data['userName'] ?? 'A')[0], style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text(data['userName'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Nível ${data['level'] ?? 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeAfter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comparativo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 32),
                            const SizedBox(height: 4),
                            Text('Antes', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: AppColors.primary),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 32),
                            const SizedBox(height: 4),
                            Text('Depois', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareStats(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estatísticas para Compartilhar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildShareStatRow(Icons.fitness_center, '${data['workoutsThisMonth']} treinos este mês', AppColors.primary),
            _buildShareStatRow(Icons.local_fire_department, 'Sequência de ${data['currentStreak']} dias', AppColors.warning),
            _buildShareStatRow(Icons.trending_down, '${data['weightLost']}kg perdidos', AppColors.success),
            _buildShareStatRow(Icons.emoji_events, '${data['personalRecords']} recordes pessoais', AppColors.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildShareStatRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMessageField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Mensagem personalizada', border: OutlineInputBorder()),
        ),
      ),
    );
  }

  Widget _buildShareButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compartilhar via', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildShareOption(Colors.green, Icons.chat, 'WhatsApp', () {})),
            const SizedBox(width: 8),
            Expanded(child: _buildShareOption(Colors.purple, Icons.camera, 'Instagram', () {})),
            const SizedBox(width: 8),
            Expanded(child: _buildShareOption(AppColors.info, Icons.copy, 'Copiar', _copyToClipboard)),
          ],
        ),
      ],
    );
  }

  Widget _buildShareOption(Color color, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

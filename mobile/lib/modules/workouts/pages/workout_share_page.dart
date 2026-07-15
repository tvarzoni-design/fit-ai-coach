import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class WorkoutSharePage extends StatefulWidget {
  final String workoutId;

  const WorkoutSharePage({super.key, required this.workoutId});

  @override
  State<WorkoutSharePage> createState() => _WorkoutSharePageState();
}

class _WorkoutSharePageState extends State<WorkoutSharePage> {
  Map<String, dynamic>? _workout;
  List<dynamic> _exercises = [];
  bool _isLoading = true;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  Future<void> _loadWorkout() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getWorkout(widget.workoutId);
      if (mounted) {
        setState(() {
          _workout = response.data;
          _exercises = _workout!['exercises'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  int get _totalSets => _exercises.fold(0, (sum, e) => sum + (e['sets'] as int? ?? 3));

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carregando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Compartilhar Treino'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildShareCard(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildMessageSection(),
            const SizedBox(height: 24),
            _buildQRCodeSection(),
            const SizedBox(height: 24),
            _buildShareButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8B83FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 8),
              Text('Fit AI Coach', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(_workout?['name'] ?? 'Treino', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareStat('${_exercises.length}', 'Exercícios'),
                    _buildShareStat('$_totalSets', 'Séries'),
                    _buildShareStat('${_workout?['estimatedDuration'] ?? 0} min', 'Duração'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Treinei com o Fit AI Coach!', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildShareStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.fitness_center, '${_exercises.length}', 'Exercícios'),
            _buildStatItem(Icons.repeat, '$_totalSets', 'Séries'),
            _buildStatItem(Icons.timer_outlined, '${_workout?['estimatedDuration'] ?? 0} min', 'Duração'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mensagem personalizada', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Escreva uma mensagem para compartilhar...'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('QR Code', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(12),
              child: CustomPaint(painter: _QRPlaceholderPainter()),
            ),
            const SizedBox(height: 12),
            Text('Escaneie para ver o treino', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compartilhar via', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildShareButton(Icons.chat, 'WhatsApp', const Color(0xFF25D366)),
            const SizedBox(width: 12),
            _buildShareButton(Icons.camera_alt, 'Instagram', const Color(0xFFE4405F)),
            const SizedBox(width: 12),
            _buildShareButton(Icons.copy, 'Copiar', AppColors.primary),
          ],
        ),
      ],
    );
  }

  Widget _buildShareButton(IconData icon, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Compartilhando via $label...'), backgroundColor: color),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QRPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final blockSize = size.width / 21;
    final pattern = [
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,0,0,1],
      [1,0,1,1,1,0,1,0,1,1,0,0,1,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,0,0,1,1,0,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,1,0,0,1,1,0,1,0,1,1,1,0,1],
      [1,0,0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [0,0,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,0,0,0],
      [1,0,1,0,1,1,1,1,0,0,1,0,0,1,1,0,1,0,1,0,1],
      [0,1,0,1,0,0,0,1,1,0,0,1,1,0,0,1,0,1,0,1,0],
      [1,0,1,1,1,0,1,0,1,1,0,0,1,0,1,0,1,1,0,0,1],
      [0,1,0,0,0,1,0,1,0,0,1,1,0,1,0,1,0,0,1,1,0],
      [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1],
    ];
    for (int row = 0; row < pattern.length; row++) {
      for (int col = 0; col < pattern[row].length; col++) {
        if (pattern[row][col] == 1) {
          canvas.drawRect(Rect.fromLTWH(col * blockSize, row * blockSize, blockSize, blockSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

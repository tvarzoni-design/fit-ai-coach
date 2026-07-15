import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class RestTimerPage extends StatefulWidget {
  final int restSeconds;
  final String nextExerciseName;

  const RestTimerPage({super.key, required this.restSeconds, required this.nextExerciseName});

  @override
  State<RestTimerPage> createState() => _RestTimerPageState();
}

class _RestTimerPageState extends State<RestTimerPage> with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late int _initialSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _soundEnabled = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.restSeconds;
    _initialSeconds = widget.restSeconds;
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() => _isRunning = false);
        _pulseController.repeat();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer(int seconds) {
    _timer?.cancel();
    _pulseController.reset();
    setState(() {
      _remainingSeconds = seconds;
      _initialSeconds = seconds;
      _isRunning = false;
    });
  }

  void _skip() {
    _timer?.cancel();
    _pulseController.reset();
    context.pop({'skipped': true});
  }

  double get _progress => _initialSeconds > 0 ? _remainingSeconds / _initialSeconds : 0;

  @override
  Widget build(BuildContext context) {
    final isFinished = _remainingSeconds <= 0 && !_isRunning;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: const Text('Descanso'),
        actions: [
          IconButton(
            icon: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off, color: AppColors.textSecondary),
            onPressed: () => setState(() => _soundEnabled = !_soundEnabled),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildTimerCircle(isFinished),
            const SizedBox(height: 32),
            _buildControlButtons(isFinished),
            const SizedBox(height: 32),
            _buildPresetButtons(),
            const SizedBox(height: 32),
            _buildNextExerciseCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCircle(bool isFinished) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isFinished ? 1.0 + 0.05 * sin(_pulseController.value * 2 * pi) : 1.0;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: _progress.clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFinished ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: isFinished ? AppColors.secondary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isFinished ? 'Tempo esgotado!' : 'segundos restantes',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildControlButtons(bool isFinished) {
    if (isFinished) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.pop({'skipped': true}),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Próximo Exercício'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _skip,
            child: const Text('Pular'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(_isRunning ? 'Pausar' : 'Iniciar'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButtons() {
    final presets = [30, 60, 90, 120, 180];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tempos predefinidos', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((s) {
            final isSelected = _initialSeconds == s;
            return GestureDetector(
              onTap: () => _resetTimer(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                ),
                child: Text(
                  s >= 60 ? '${s ~/ 60}min' : '${s}s',
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showCustomTimeDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text('Tempo customizado', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomTimeDialog() {
    final controller = TextEditingController(text: '${_initialSeconds}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Tempo de descanso'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Segundos', suffixText: 's'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final seconds = int.tryParse(controller.text) ?? 60;
              Navigator.pop(ctx);
              _resetTimer(seconds.clamp(5, 600));
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNextExerciseCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.fitness_center, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Próximo exercício', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(widget.nextExerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

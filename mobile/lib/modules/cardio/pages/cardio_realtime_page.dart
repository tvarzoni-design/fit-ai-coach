import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CardioRealtimePage extends StatefulWidget {
  const CardioRealtimePage({super.key});

  @override
  State<CardioRealtimePage> createState() => _CardioRealtimePageState();
}

class _CardioRealtimePageState extends State<CardioRealtimePage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  int _elapsedSeconds = 0;
  double _distance = 0.0;
  int _calories = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;
          _distance += 0.004;
          _calories = (_elapsedSeconds * 0.17).round();
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() => _isPaused = true);
  }

  void _resumeTimer() {
    setState(() => _isPaused = false);
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _elapsedSeconds = 0;
      _distance = 0.0;
      _calories = 0;
    });
  }

  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _pace {
    if (_distance <= 0 || _elapsedSeconds <= 0) return '--:--';
    final paceSeconds = (_elapsedSeconds / _distance).round();
    final m = paceSeconds ~/ 60;
    final s = paceSeconds % 60;
    return '$m\'${s.toString().padLeft(2, '0')}\"';
  }

  Future<void> _saveSession() async {
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/cardio/sessions', data: {
        'duration': _elapsedSeconds,
        'distance': double.parse(_distance.toStringAsFixed(2)),
        'calories': _calories,
        'type': 'running',
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final progress = _elapsedSeconds > 0
        ? (_elapsedSeconds % 3600) / 3600.0
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cardio em Tempo Real'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_elapsedSeconds > 0 && !_isRunning)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSession,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildCircularTimer(progress),
            const SizedBox(height: 24),
            _buildPrimaryStats(),
            const SizedBox(height: 16),
            _buildSecondaryStats(),
            const SizedBox(height: 24),
            _buildControls(),
            const SizedBox(height: 24),
            _buildMapPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTimer(double progress) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = _isRunning && !_isPaused
            ? 1.0 + (_pulseController.value * 0.02)
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.surfaceLight,
            width: 8,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceLight,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(_elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isRunning
                      ? (_isPaused ? 'PAUSADO' : 'EM ANDAMENTO')
                      : 'PRONTO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isRunning
                        ? (_isPaused ? AppColors.warning : AppColors.success)
                        : AppColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryStats() {
    return Row(
      children: [
        _buildStatCard(
          Icons.straighten,
          '${_distance.toStringAsFixed(2)}',
          'km',
          AppColors.primary,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          Icons.local_fire_department,
          '$_calories',
          'kcal',
          AppColors.warning,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          Icons.speed,
          _pace,
          '/km',
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String unit, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryStats() {
    final avgSpeed = _elapsedSeconds > 0
        ? (_distance / (_elapsedSeconds / 3600)).toStringAsFixed(1)
        : '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMiniStat(Icons.speed, 'Vel. Média', '$avgSpeed km/h'),
            Container(width: 1, height: 40, color: AppColors.surfaceLight),
            _buildMiniStat(Icons.favorite, 'FC Atual', '142 bpm'),
            Container(width: 1, height: 40, color: AppColors.surfaceLight),
            _buildMiniStat(Icons.alt_route, 'Passos', '${(_distance * 1312).round()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isRunning) ...[
          _buildControlButton(
            icon: Icons.stop,
            color: AppColors.error,
            onTap: _stopTimer,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: _isPaused ? Icons.play_arrow : Icons.pause,
            color: _isPaused ? AppColors.success : AppColors.warning,
            onTap: _isPaused ? _resumeTimer : _pauseTimer,
            large: true,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: Icons.refresh,
            color: AppColors.textMuted,
            onTap: _resetTimer,
          ),
        ] else
          _buildControlButton(
            icon: Icons.play_arrow,
            color: AppColors.success,
            onTap: _startTimer,
            large: true,
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool large = false,
  }) {
    final size = large ? 72.0 : 56.0;
    final iconSize = large ? 36.0 : 28.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Card(
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Mapa da Rota',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'GPS será exibido aqui durante o exercício',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

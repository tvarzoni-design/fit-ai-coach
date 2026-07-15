import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class ChallengeDetailPage extends StatefulWidget {
  final String challengeId;
  const ChallengeDetailPage({super.key, required this.challengeId});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  Map<String, dynamic>? _challenge;
  bool _isLoading = true;
  bool _isParticipating = false;
  Duration _timeRemaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadChallenge() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final res = await api.getDailyChallenges();
      final challenges = res.data as List<dynamic>? ?? [];
      final match = challenges.where((c) => c['id'].toString() == widget.challengeId);
      if (mounted) {
        setState(() {
          _challenge = match.isNotEmpty ? match.first : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _challenge = {
            'id': widget.challengeId,
            'title': 'Desafio Semanal',
            'description': 'Complete 5 treinos esta semana para ganhar XP extra e desbloquear uma conquista especial.',
            'icon': '🏆',
            'category': 'strength',
            'target': 5,
            'progress': 2,
            'completed': false,
            'xpReward': 150,
            'badgeReward': 'Guerreiro da Semana',
            'timeLimitHours': 72,
            'requirements': [
              {'text': 'Complete 5 treinos', 'done': false},
              {'text': 'Registre sua alimentação', 'done': true},
              {'text': 'Mantenha sequência de 3 dias', 'done': false},
            ],
          };
          _isLoading = false;
        });
        _startTimer(72);
      }
    }
  }

  void _startTimer(int hours) {
    _timeRemaining = Duration(hours: hours);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeRemaining.inSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _timeRemaining -= const Duration(seconds: 1));
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'strength': return AppColors.primary;
      case 'cardio': return AppColors.secondary;
      case 'health': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhe do Desafio')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final ch = _challenge;
    if (ch == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhe do Desafio')),
        body: Center(child: Text('Desafio não encontrado', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final completed = ch['completed'] == true;
    final progress = (ch['progress'] ?? 0).toDouble();
    final target = (ch['target'] ?? 1).toDouble();
    final percentage = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
    final cat = ch['category'] ?? 'general';
    final catColor = _categoryColor(cat);
    final requirements = ch['requirements'] as List<dynamic>? ?? [];
    final xpReward = ch['xpReward'] ?? 0;
    final badgeReward = ch['badgeReward'] ?? '';
    final timeLimit = ch['timeLimitHours'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe do Desafio'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [catColor.withValues(alpha: 0.3), AppColors.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(ch['icon'] ?? '🏆', style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(ch['title'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: catColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(cat.toUpperCase(), style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(ch['description'] ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            Text('Progresso', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(completed ? AppColors.success : catColor),
                      minHeight: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${progress.toInt()}/${target.toInt()}', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            if (timeLimit > 0 && _timeRemaining.inSeconds > 0) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text('Tempo restante: ${_formatDuration(_timeRemaining)}', style: const TextStyle(color: AppColors.warning, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
            if (requirements.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Requisitos', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...requirements.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: r['done'] == true ? AppColors.success.withValues(alpha: 0.1) : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: r['done'] == true ? Border.all(color: AppColors.success.withValues(alpha: 0.3)) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      r['done'] == true ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: r['done'] == true ? AppColors.success : AppColors.textMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(r['text'] ?? '', style: TextStyle(
                        color: r['done'] == true ? AppColors.textSecondary : AppColors.textPrimary,
                        fontSize: 14,
                        decoration: r['done'] == true ? TextDecoration.lineThrough : null,
                      )),
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 24),
            Text('Recompensas', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.star, color: AppColors.warning, size: 32),
                        const SizedBox(height: 8),
                        Text('+$xpReward', style: const TextStyle(color: AppColors.warning, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('XP', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                if (badgeReward.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.emoji_events, color: AppColors.secondary, size: 32),
                          const SizedBox(height: 8),
                          Text(badgeReward, style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            if (completed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                    const SizedBox(width: 8),
                    Text('Concluído!', style: TextStyle(color: AppColors.success, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else if (_isParticipating)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final api = context.read<AuthService>().api;
                      await api.completeDailyChallenge(ch['id'].toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Progresso registrado!'), backgroundColor: AppColors.success),
                      );
                      _loadChallenge();
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao registrar progresso'), backgroundColor: AppColors.error),
                      );
                    }
                  },
                  child: const Text('Registrar Progresso'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isParticipating = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Você está participando do desafio!'), backgroundColor: AppColors.primary),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: catColor),
                  child: const Text('Participar'),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class CoachAiPage extends StatefulWidget {
  const CoachAiPage({super.key});

  @override
  State<CoachAiPage> createState() => _CoachAiPageState();
}

class _CoachAiPageState extends State<CoachAiPage> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'message': 'Olá! Sou seu Coach IA. Como posso te ajudar hoje?'},
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () async {
              final api = context.read<AuthService>().api;
              try {
                final response = await api.generateWorkout();
                final workout = response.data;
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Treino "${workout['name'] ?? 'Personalizado'}" gerado!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao gerar treino')),
                  );
                }
              }
            },
            tooltip: 'Gerar treino IA',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.fitness_center, 'label': 'Criar treino', 'action': 'create_workout'},
      {'icon': Icons.trending_up, 'label': 'Evolução', 'action': 'view_progress'},
      {'icon': Icons.restaurant, 'label': 'Nutrição', 'action': 'nutrition'},
      {'icon': Icons.lightbulb_outline, 'label': 'Dicas', 'action': 'tips'},
    ];
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _handleQuickAction(action['action'] as String),
              child: Column(children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(action['icon'] as IconData, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(action['label'] as String, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.surfaceLight))),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: const InputDecoration(hintText: 'Digite sua mensagem...', border: InputBorder.none),
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ),
      ]),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'create_workout':
        _sendQuickMessage('Crie um treino personalizado para mim');
        break;
      case 'view_progress':
        context.go('/progress');
        break;
      case 'nutrition':
        context.go('/nutrition');
        break;
      case 'tips':
        _sendQuickMessage('Me dê uma dica de treino para hoje');
        break;
    }
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'message': message});
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final api = context.read<AuthService>().api;
      final response = await api.chatWithAi(message);
      final aiResponse = response.data['response'] ?? 'Desculpe, não consegui processar.';

      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'message': aiResponse});
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'message': 'Erro ao conectar com o Coach IA. Tente novamente.'});
          _isLoading = false;
        });
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class RestorePurchasesPage extends StatefulWidget {
  const RestorePurchasesPage({super.key});

  @override
  State<RestorePurchasesPage> createState() => _RestorePurchasesPageState();
}

enum _RestoreState { idle, loading, success, error }

class _RestorePurchasesPageState extends State<RestorePurchasesPage> with SingleTickerProviderStateMixin {
  _RestoreState _state = _RestoreState.idle;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  List<Map<String, dynamic>> _activeSubscriptions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _restorePurchases() async {
    setState(() => _state = _RestoreState.loading);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/premium/restore');
      if (mounted) {
        final data = response.data;
        _activeSubscriptions = List<Map<String, dynamic>>.from(data['subscriptions'] ?? []);
        setState(() => _state = _RestoreState.success);
        _controller.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _RestoreState.error;
          _errorMessage = 'Não foi possível restaurar as compras. Verifique sua conexão e tente novamente.';
        });
        _controller.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurar Compras'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case _RestoreState.idle:
        return _buildIdleState();
      case _RestoreState.loading:
        return _buildLoadingState();
      case _RestoreState.success:
        return _buildSuccessState();
      case _RestoreState.error:
        return _buildErrorState();
    }
  }

  Widget _buildIdleState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.replay, color: AppColors.primary, size: 64),
        ),
        const SizedBox(height: 24),
        Text('Restaurar Compras', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'Se você já possui uma assinatura ativa, clique no botão abaixo para restaurar suas compras anteriores.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _restorePurchases,
            icon: const Icon(Icons.replay),
            label: const Text('Restaurar Compras'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text('Verificando compras...', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Aguarde enquanto verificamos suas compras anteriores', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ],
    );
  }

  Widget _buildSuccessState() {
    if (_activeSubscriptions.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, color: AppColors.textMuted, size: 64),
            ),
            const SizedBox(height: 24),
            Text('Nenhuma compra encontrada', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Não encontramos assinaturas ativas vinculadas a esta conta.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restorePurchases,
                child: const Text('Tentar Novamente'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: AppColors.success, size: 64),
          ),
          const SizedBox(height: 24),
          Text('Compras restauradas!', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            '${_activeSubscriptions.length} assinatura(s) encontrada(s)',
            style: TextStyle(color: AppColors.success, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ..._activeSubscriptions.map((sub) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.workspace_premium, color: AppColors.success, size: 20),
                  ),
                  title: Text(sub['planName'] ?? 'Premium', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle: Text(sub['status'] ?? 'Ativa', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  trailing: Icon(Icons.check_circle, color: AppColors.success, size: 20),
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: AppColors.error, size: 64),
          ),
          const SizedBox(height: 24),
          Text('Erro ao restaurar', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Ocorreu um erro inesperado.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _restorePurchases,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Voltar', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

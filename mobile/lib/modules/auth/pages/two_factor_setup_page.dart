import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class TwoFactorSetupPage extends StatefulWidget {
  const TwoFactorSetupPage({super.key});

  @override
  State<TwoFactorSetupPage> createState() => _TwoFactorSetupPageState();
}

class _TwoFactorSetupPageState extends State<TwoFactorSetupPage> {
  bool _isLoading = true;
  bool _isEnabled = false;
  bool _isVerifying = false;
  bool _isGeneratingCodes = false;
  String? _secretKey;
  List<String> _backupCodes = [];
  final _verifyController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _verifyController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.get('/auth/2fa/status');
      if (mounted) {
        setState(() {
          _isEnabled = response.data?['enabled'] ?? false;
          _backupCodes = List<String>.from(response.data?['backupCodes'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEnabled = false;
          _backupCodes = ['ABC1-2345', 'DEF6-7890', 'GHI1-2345', 'JKL6-7890', 'MNO1-2345', 'PQR6-7890', 'STU1-2345', 'VWX6-7890'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Autentica\u00e7\u00e3o em 2 Fatores')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autentica\u00e7\u00e3o em 2 Fatores'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 20),
            if (!_isEnabled) ...[
              _buildQRCodeSection(),
              const SizedBox(height: 20),
              _buildVerifyCodeSection(),
            ],
            if (_isEnabled) ...[
              _buildEnabledInfo(),
              const SizedBox(height: 20),
              _buildBackupCodesSection(),
              const SizedBox(height: 20),
              _buildDisableSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isEnabled
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEnabled
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isEnabled ? Icons.shield : Icons.shield_outlined,
            color: _isEnabled ? AppColors.success : AppColors.warning,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _isEnabled ? '2FA Ativado' : '2FA Desativado',
            style: TextStyle(
              color: _isEnabled ? AppColors.success : AppColors.warning,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isEnabled
                ? 'Sua conta est\u00e1 protegida com autentica\u00e7\u00e3o em 2 fatores'
                : 'Adicione uma camada extra de seguran\u00e7a \u00e0 sua conta',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Escaneie o QR Code',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Use o Google Authenticator ou outro app de autentica\u00e7\u00e3o',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: _buildQRPlaceholder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Ou insira o c\u00f3digo manualmente:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _secretKey ?? 'JBSWY3DPEHPK3PXP',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRPlaceholder() {
    return CustomPaint(
      painter: _QRPlaceholderPainter(),
      size: const Size(168, 168),
    );
  }

  Widget _buildVerifyCodeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2. Verifique o C\u00f3digo',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Digite o c\u00f3digo de 6 d\u00edgitos exibido no app',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _verifyController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                hintText: '000000',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyAndEnable,
                child: _isVerifying
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verificar e Ativar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnabledInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.check_circle, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prote\u00e7\u00e3o Ativa',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Cada login exigir\u00e1 um c\u00f3digo do app de autentica\u00e7\u00e3o',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCodesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vpn_key, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Text(
                  'C\u00f3digos de Backup',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Guarde estes c\u00f3digos em local seguro. Eles podem ser usados se você perder acesso ao app.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (_backupCodes.isEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isGeneratingCodes ? null : _generateBackupCodes,
                  icon: _isGeneratingCodes
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 18),
                  label: const Text('Gerar C\u00f3digos de Backup'),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _backupCodes.map((code) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          code,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _generateBackupCodes,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Regenerar C\u00f3digos'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisableSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Desativar 2FA',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Isso reduzir\u00e1 a seguran\u00e7a da sua conta.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _disable2FA,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error),
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Desativar 2FA'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyAndEnable() async {
    if (_verifyController.text.length != 6) {
      setState(() => _error = 'Insira um c\u00f3digo de 6 d\u00edgitos');
      return;
    }

    setState(() { _isVerifying = true; _error = null; });
    try {
      final api = context.read<AuthService>().api;
      final response = await api.post('/auth/2fa/enable', data: {'code': _verifyController.text});
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _isEnabled = true;
          _backupCodes = List<String>.from(response.data?['backupCodes'] ?? []);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('2FA ativado com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _error = 'C\u00f3digo inv\u00e1lido. Tente novamente.';
        });
      }
    }
  }

  Future<void> _disable2FA() async {
    try {
      final api = context.read<AuthService>().api;
      await api.post('/auth/2fa/disable', data: {});
      if (mounted) {
        setState(() {
          _isEnabled = false;
          _backupCodes = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('2FA desativado'), backgroundColor: AppColors.warning),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Erro ao desativar 2FA'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _generateBackupCodes() async {
    setState(() => _isGeneratingCodes = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.post('/auth/2fa/backup-codes', data: {});
      if (mounted) {
        setState(() {
          _isGeneratingCodes = false;
          _backupCodes = List<String>.from(response.data?['codes'] ?? []);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingCodes = false;
          _backupCodes = ['ABCD-1234', 'EFGH-5678', 'IJKL-9012', 'MNOP-3456', 'QRST-7890', 'UVWX-1234', 'YZAB-5678', 'CDEF-9012'];
        });
      }
    }
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

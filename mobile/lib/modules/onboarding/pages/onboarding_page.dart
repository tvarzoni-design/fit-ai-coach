import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _selectedGoal;
  String? _selectedExperience;
  int _trainingDays = 3;

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;

  static const _goals = [
    {'key': 'fat_loss', 'label': 'Emagrecer', 'icon': Icons.monitor_weight_outlined, 'desc': 'Perder peso e reduzir medidas'},
    {'key': 'hypertrophy', 'label': 'Ganhar massa', 'icon': Icons.fitness_center_outlined, 'desc': 'Aumentar massa muscular'},
    {'key': 'health', 'label': 'Manter peso', 'icon': Icons.favorite_outline, 'desc': 'Manter o peso e ter mais saúde'},
    {'key': 'conditioning', 'label': 'Condicionamento', 'icon': Icons.directions_run, 'desc': 'Melhorar o condicionamento físico'},
  ];

  static const _experiences = [
    {'key': 'beginner', 'label': 'Iniciante', 'icon': Icons.eco_outlined, 'desc': 'Nunca treinei ou estou começando'},
    {'key': 'intermediate', 'label': 'Intermediário', 'icon': Icons.trending_up_outlined, 'desc': 'Já treino há alguns meses'},
    {'key': 'advanced', 'label': 'Avançado', 'icon': Icons.whatshot_outlined, 'desc': 'Treino há mais de um ano'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage > 0) _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomeStep(),
                  _buildGoalStep(),
                  _buildBodyDataStep(),
                  _buildExperienceStep(),
                  _buildTrainingDaysStep(),
                ],
              ),
            ),
            if (_currentPage > 0) _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passo $_currentPage de 4',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              TextButton(
                onPressed: _isLoading ? null : () => context.go('/home'),
                child: const Text('Pular'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDotsIndicator(),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index + 1 ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index + 1 ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.fitness_center, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            'Fit AI Coach',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Seu personal trainer inteligente\ncom inteligência artificial',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const Spacer(flex: 1),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Vamos começar', style: TextStyle(fontSize: 18)),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Qual seu objetivo?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione o que você deseja alcançar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = goal['key'] == _selectedGoal;
                return _buildSelectionCard(
                  icon: goal['icon'] as IconData,
                  label: goal['label'] as String,
                  description: goal['desc'] as String,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedGoal = goal['key'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyDataStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Seus dados',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe seus dados corporais',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Peso (kg)',
              prefixIcon: Icon(Icons.monitor_weight_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Altura (cm)',
              prefixIcon: Icon(Icons.height_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Idade',
              prefixIcon: Icon(Icons.cake_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Qual seu nível?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Isso define a complexidade dos treinos',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _experiences.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final exp = _experiences[index];
                final isSelected = exp['key'] == _selectedExperience;
                return _buildSelectionCard(
                  icon: exp['icon'] as IconData,
                  label: exp['label'] as String,
                  description: exp['desc'] as String,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedExperience = exp['key'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingDaysStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Disponibilidade',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quantos dias por semana você pode treinar?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: List.generate(5, (index) {
                  final day = index + 2;
                  final isSelected = _trainingDays == day;
                  return GestureDetector(
                    onTap: () => setState(() => _trainingDays = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day == 1 ? 'dia' : 'dias',
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isLastStep = _currentPage == 4;
    final canProceed = _canProceed();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Voltar'),
              ),
            ),
          if (_currentPage > 1) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed && !_isLoading
                  ? (isLastStep ? _handleFinish : _goToNextPage)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isLastStep ? 'Começar' : 'Próximo'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 1:
        return _selectedGoal != null;
      case 2:
        return _weightController.text.isNotEmpty &&
            _heightController.text.isNotEmpty &&
            _ageController.text.isNotEmpty;
      case 3:
        return _selectedExperience != null;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleFinish() async {
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthService>();

      await auth.completeOnboarding();

      // Try to sync with server in background (non-blocking)
      try {
        final api = auth.api;
        await api.updateProfile({
          'goal': _selectedGoal,
          'experience': _selectedExperience,
          'trainingDays': _trainingDays,
          'weight': double.tryParse(_weightController.text),
          'height': double.tryParse(_heightController.text),
          'age': int.tryParse(_ageController.text),
        });
      } catch (_) {}

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

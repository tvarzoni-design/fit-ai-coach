import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SchedulePage extends StatefulWidget {
  final Map<String, dynamic> onboardingData;
  final ValueChanged<Map<String, dynamic>> onNext;

  const SchedulePage({
    super.key,
    required this.onboardingData,
    required this.onNext,
  });

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final Map<String, bool> _selectedDays = {
    'Seg': false, 'Ter': false, 'Qua': false,
    'Qui': false, 'Sex': false, 'Sáb': false, 'Dom': false,
  };
  String _preferredTime = 'manha';
  int _duration = 60;
  int _restTime = 90;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final savedDays = widget.onboardingData['scheduleDays'];
    if (savedDays is Map) {
      savedDays.forEach((key, value) {
        if (_selectedDays.containsKey(key)) _selectedDays[key] = value == true;
      });
    }
    _preferredTime = widget.onboardingData['preferredTime'] ?? 'manha';
    _duration = widget.onboardingData['duration'] ?? 60;
    _restTime = widget.onboardingData['restTime'] ?? 90;
  }

  @override
  Widget build(BuildContext context) {
    final activeDays = _selectedDays.values.where((v) => v).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Seu horário semanal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure seus dias e horários de treino',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dias de treino',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: activeDays > 0
                                  ? AppColors.success.withOpacity(0.15)
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$activeDays dias',
                              style: TextStyle(
                                color: activeDays > 0 ? AppColors.success : AppColors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _selectedDays.entries.map((entry) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDays[entry.key] = !entry.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: entry.value ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: entry.value ? AppColors.primary : AppColors.surfaceLight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  entry.key.substring(0, 2),
                                  style: TextStyle(
                                    color: entry.value ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horário preferido',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildTimeOption('Manhã', 'manha', Icons.wb_sunny_outlined),
                          const SizedBox(width: 10),
                          _buildTimeOption('Tarde', 'tarde', Icons.wb_cloudy_outlined),
                          const SizedBox(width: 10),
                          _buildTimeOption('Noite', 'noite', Icons.nightlight_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Duração do treino',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_duration min',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceLight,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.1),
                        ),
                        child: Slider(
                          value: _duration.toDouble(),
                          min: 30,
                          max: 120,
                          divisions: 9,
                          onChanged: (v) => setState(() => _duration = v.round()),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('30 min', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text('120 min', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Descanso entre séries',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_restTime s',
                              style: TextStyle(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.info,
                          inactiveTrackColor: AppColors.surfaceLight,
                          thumbColor: AppColors.info,
                          overlayColor: AppColors.info.withOpacity(0.1),
                        ),
                        child: Slider(
                          value: _restTime.toDouble(),
                          min: 30,
                          max: 180,
                          divisions: 10,
                          onChanged: (v) => setState(() => _restTime = v.round()),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('30s', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text('180s', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || activeDays == 0 ? null : _handleNext,
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
                      : const Text('Próximo'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeOption(String label, String value, IconData icon) {
    final isSelected = _preferredTime == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _preferredTime = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.surfaceLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    final data = {
      ...widget.onboardingData,
      'scheduleDays': _selectedDays,
      'preferredTime': _preferredTime,
      'duration': _duration,
      'restTime': _restTime,
    };
    widget.onNext(data);
  }
}

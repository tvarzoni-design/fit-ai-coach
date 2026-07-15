import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class AddMeasurementPage extends StatefulWidget {
  const AddMeasurementPage({super.key});

  @override
  State<AddMeasurementPage> createState() => _AddMeasurementPageState();
}

class _AddMeasurementPageState extends State<AddMeasurementPage> {
  final _formKey = GlobalKey<FormState>();
  double _weight = 78.5;
  double _bodyFat = 18.0;
  final _neckController = TextEditingController(text: '38');
  final _chestController = TextEditingController(text: '102');
  final _waistController = TextEditingController(text: '82');
  final _hipController = TextEditingController(text: '98');
  final _bicepController = TextEditingController(text: '36');
  final _thighController = TextEditingController(text: '58');
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  Map<String, dynamic>? _previous;

  @override
  void initState() {
    super.initState();
    _loadPrevious();
  }

  @override
  void dispose() {
    _neckController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _bicepController.dispose();
    _thighController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPrevious() async {
    try {
      final api = context.read<AuthService>().api;
      final response = await api.getLatestMeasurement();
      if (mounted) setState(() => _previous = response.data);
    } catch (_) {}
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final api = context.read<AuthService>().api;
      await api.saveMeasurement({
        'date': _selectedDate.toIso8601String(),
        'weight': _weight, 'bodyFat': _bodyFat,
        'neck': double.tryParse(_neckController.text) ?? 0,
        'chest': double.tryParse(_chestController.text) ?? 0,
        'waist': double.tryParse(_waistController.text) ?? 0,
        'hip': double.tryParse(_hipController.text) ?? 0,
        'bicep': double.tryParse(_bicepController.text) ?? 0,
        'thigh': double.tryParse(_thighController.text) ?? 0,
        'notes': _notesController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medida salva com sucesso!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar medida')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Medida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildWeightSection(),
              const SizedBox(height: 16),
              _buildBodyFatSection(),
              const SizedBox(height: 16),
              _buildBodyMeasurements(),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 16),
              if (_previous != null) _buildPreviousReference(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Salvar Medida'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: AppColors.primary),
        title: Text(
          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Data da medição'),
        trailing: const Icon(Icons.edit, size: 18),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildWeightSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peso (kg)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleButton(Icons.remove, () {
                  setState(() => _weight = (_weight - 0.1).clamp(30, 250));
                }),
                const SizedBox(width: 24),
                Text('${_weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                _buildCircleButton(Icons.add, () {
                  setState(() => _weight = (_weight + 0.1).clamp(30, 250));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyFatSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gordura Corporal (%)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircleButton(Icons.remove, () {
                  setState(() => _bodyFat = (_bodyFat - 0.1).clamp(3, 50));
                }),
                const SizedBox(width: 24),
                Text('${_bodyFat.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                _buildCircleButton(Icons.add, () {
                  setState(() => _bodyFat = (_bodyFat + 0.1).clamp(3, 50));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _buildBodyMeasurements() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medidas Corporais (cm)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildMeasurementField('Pescoço', _neckController),
            _buildMeasurementField('Peito', _chestController),
            _buildMeasurementField('Cintura', _waistController),
            _buildMeasurementField('Quadril', _hipController),
            _buildMeasurementField('Bíceps', _bicepController),
            _buildMeasurementField('Coxa', _thighController),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, suffixText: 'cm'),
        validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Observações', hintText: 'Ex: treinei antes de medir'),
        ),
      ),
    );
  }

  Widget _buildPreviousReference() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medida Anterior', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Peso: ${_previous!['weight'] ?? '--'} kg | Gordura: ${_previous!['bodyFat'] ?? '--'}%',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

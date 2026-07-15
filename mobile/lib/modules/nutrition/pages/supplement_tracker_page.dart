import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class SupplementTrackerPage extends StatefulWidget {
  const SupplementTrackerPage({super.key});

  @override
  State<SupplementTrackerPage> createState() => _SupplementTrackerPageState();
}

class _SupplementTrackerPageState extends State<SupplementTrackerPage> {
  List<Map<String, dynamic>> _supplements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<AuthService>().api;
      final response = await api.dio.get('/nutrition/supplements');
      if (mounted) {
        setState(() {
          _supplements = List<Map<String, dynamic>>.from(response.data ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _supplements = [
            {'name': 'Creatina', 'dosage': '5g', 'enabled': true, 'time': 'Manhã', 'reminder': true},
            {'name': 'Whey Protein', 'dosage': '30g', 'enabled': true, 'time': 'Pós-treino', 'reminder': false},
            {'name': 'Vitamina D', 'dosage': '2000 UI', 'enabled': true, 'time': 'Manhã', 'reminder': true},
            {'name': 'Ômega-3', 'dosage': '1000mg', 'enabled': false, 'time': 'Almoço', 'reminder': false},
            {'name': 'Magnésio', 'dosage': '400mg', 'enabled': false, 'time': 'Noite', 'reminder': true},
            {'name': 'Zinco', 'dosage': '30mg', 'enabled': false, 'time': 'Noite', 'reminder': false},
            {'name': 'Vitamina C', 'dosage': '1000mg', 'enabled': true, 'time': 'Manhã', 'reminder': false},
            {'name': 'Cafeína', 'dosage': '200mg', 'enabled': false, 'time': 'Pré-treino', 'reminder': true},
          ];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleSupplement(int index, bool value) async {
    setState(() => _supplements[index]['enabled'] = value);
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/nutrition/supplements/toggle', data: {
        'name': _supplements[index]['name'],
        'enabled': value,
      });
    } catch (_) {}
  }

  Future<void> _toggleReminder(int index, bool value) async {
    setState(() => _supplements[index]['reminder'] = value);
    try {
      final api = context.read<AuthService>().api;
      await api.dio.post('/nutrition/supplements/reminder', data: {
        'name': _supplements[index]['name'],
        'reminder': value,
      });
    } catch (_) {}
  }

  void _showDosageDialog(int index) {
    final controller = TextEditingController(text: _supplements[index]['dosage']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Dosagem - ${_supplements[index]['name']}', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Dosagem'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final dosage = controller.text.trim();
                  if (dosage.isNotEmpty) {
                    setState(() => _supplements[index]['dosage'] = dosage);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeDialog(int index) {
    final times = ['Manhã', 'Almoço', 'Noite', 'Pré-treino', 'Pós-treino'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Horário - ${_supplements[index]['name']}', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...times.map((time) => ListTile(
                  title: Text(time, style: TextStyle(color: AppColors.textPrimary)),
                  trailing: _supplements[index]['time'] == time
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _supplements[index]['time'] = time);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suplementos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSupplementDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildActiveSummary(),
                  const SizedBox(height: 16),
                  Text('Suplementos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(_supplements.length, (i) => _buildSupplementCard(i)),
                ],
              ),
            ),
    );
  }

  Widget _buildActiveSummary() {
    final active = _supplements.where((s) => s['enabled'] == true).length;
    final withReminders = _supplements.where((s) => s['reminder'] == true).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('$active', style: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Ativos', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.surfaceLight),
            Expanded(
              child: Column(
                children: [
                  Text('$withReminders', style: TextStyle(color: AppColors.warning, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Lembretes', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplementCard(int index) {
    final supplement = _supplements[index];
    final isEnabled = supplement['enabled'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isEnabled ? AppColors.success : AppColors.surfaceLight).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: isEnabled ? AppColors.success : AppColors.textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplement['name'], style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _showDosageDialog(index),
                        child: Text(
                          '${supplement['dosage']} · ${supplement['time']}',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  activeColor: AppColors.success,
                  onChanged: (v) => _toggleSupplement(index, v),
                ),
              ],
            ),
            if (isEnabled) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.alarm, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text('Lembrete', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showTimeDialog(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(supplement['time'], style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: supplement['reminder'] == true,
                    activeColor: AppColors.warning,
                    onChanged: (v) => _toggleReminder(index, v),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddSupplementDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    String selectedTime = 'Manhã';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Novo Suplemento', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: 'Dosagem'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTime,
                items: ['Manhã', 'Almoço', 'Noite', 'Pré-treino', 'Pós-treino']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setModalState(() => selectedTime = v ?? selectedTime),
                decoration: const InputDecoration(labelText: 'Horário'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final dosage = dosageController.text.trim();
                    if (name.isNotEmpty && dosage.isNotEmpty) {
                      setState(() => _supplements.add({
                            'name': name,
                            'dosage': dosage,
                            'enabled': true,
                            'time': selectedTime,
                            'reminder': false,
                          }));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

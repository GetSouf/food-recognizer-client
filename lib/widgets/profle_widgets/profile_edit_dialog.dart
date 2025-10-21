// lib/widgets/profile_widgets/profile_edit_dialog.dart
import 'package:flutter/material.dart';

import 'package:food_recognizer_client/models/dailygoal_model.dart';
import 'package:food_recognizer_client/services/user_service.dart';

class ProfileEditDialog extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Function(DailyGoal?) onGoalUpdated;

  const ProfileEditDialog({super.key, required this.profile, required this.onGoalUpdated}); 

  @override
  _ProfileEditDialogState createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  int _selectedGoal = 0; // 0: Поддержание, 1: Набор массы, 2: Похудение
  final List<String> _goalOptions = ['Поддержание', 'Набор', 'Похудение'];
  final _formKey = GlobalKey<FormState>();
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _heightCtrl.text = widget.profile['height_cm']?.toString() ?? '';
    _weightCtrl.text = widget.profile['weight_kg']?.toString() ?? '';
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final heightCm = double.tryParse(_heightCtrl.text);
    final weightKg = double.tryParse(_weightCtrl.text);
    if (heightCm == null || weightKg == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите корректные значения')));
      return;
    }

    try {
      await UserService.updateProfile(heightCm: heightCm, weightKg: weightKg);
      Navigator.pop(context); // Закрываем диалог после успеха
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Профиль обновлён')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _calculateDailyGoal() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isCalculating = true);
    final heightCm = double.tryParse(_heightCtrl.text);
    final weightKg = double.tryParse(_weightCtrl.text);
    if (heightCm == null || weightKg == null) {
      setState(() => _isCalculating = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите корректные значения')));
      return;
    }

    final age = 25;
    final isMale = true;
    final goal = _selectedGoal == 0 ? 'Maintenance' : _selectedGoal == 1 ? 'Gain' : 'Lose';

    try {
      final bmr = UserService.calculateBMR(weightKg, heightCm, age, isMale);
      final newGoal = UserService.calculateDailyGoal(bmr, goal);
      await UserService.updateDailyGoal(newGoal);
      widget.onGoalUpdated(newGoal);
      Navigator.pop(context); // Закрываем диалог после успеха
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Норма рассчитана и сохранена')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при расчёте: $e')));
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать профиль'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _heightCtrl,
                decoration: const InputDecoration(labelText: 'Рост (см)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Введите рост' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightCtrl,
                decoration: const InputDecoration(labelText: 'Вес (кг)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Введите вес' : null,
              ),
              const SizedBox(height: 16),
              const Text('Цель:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: List.generate(3, (index) => _selectedGoal == index),
                onPressed: (index) => setState(() => _selectedGoal = index),
                borderRadius: BorderRadius.circular(12),
                constraints: const BoxConstraints(minHeight: 30, minWidth: 90),
                fillColor: Theme.of(context).primaryColor.withOpacity(0.2),
                selectedColor: Theme.of(context).primaryColor,
                color: Colors.grey,
                children: _goalOptions.map((option) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(option, style: const TextStyle(fontSize: 12)),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _updateProfile,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Меньший padding
            textStyle: const TextStyle(fontSize: 12), // Меньший шрифт
          ),
          child: const Text('Обновить профиль'),
        ),
        ElevatedButton(
          onPressed: _isCalculating ? null : _calculateDailyGoal,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Меньший padding
            textStyle: const TextStyle(fontSize: 12), // Меньший шрифт
          ),
          child: _isCalculating
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Рассчитать норму'),
        ),
      ],
    );
  }
}
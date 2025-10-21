// lib/widgets/edit_profile_dialog.dart
import 'package:flutter/material.dart';

class EditProfileDialog extends StatefulWidget {
  final Map<String, dynamic> initialProfile;
  final Function(Map<String, dynamic>) onSave;

  const EditProfileDialog({super.key, required this.initialProfile, required this.onSave});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _goalsController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(text: widget.initialProfile['height_cm']?.toString() ?? '');
    _weightController = TextEditingController(text: widget.initialProfile['weight_kg']?.toString() ?? '');
    _goalsController = TextEditingController(text: widget.initialProfile['goals']?.toString() ?? '{}');
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedProfile = {
      'height_cm': _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
      'weight_kg': _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
      'goals': _goalsController.text.isNotEmpty ? _goalsController.text : '{}',
    };
    widget.onSave(updatedProfile);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Редактировать профиль', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Рост (см)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Вес (кг)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _goalsController,
              decoration: const InputDecoration(labelText: 'Цели (JSON)'),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
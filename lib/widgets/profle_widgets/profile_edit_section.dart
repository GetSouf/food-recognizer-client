// lib/widgets/profile_widgets/profile_edit_section.dart
import 'package:flutter/material.dart';
import 'package:food_recognizer_client/models/dailygoal_model.dart';

import 'package:food_recognizer_client/widgets/profle_widgets/profile_edit_dialog.dart';

class ProfileEditSection extends StatelessWidget {
  final Map<String, dynamic> profile;
  final Function(DailyGoal?) onGoalUpdated;

  const ProfileEditSection({super.key, required this.profile, required this.onGoalUpdated});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Редактировать профиль',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
        profile: profile,
        onGoalUpdated: onGoalUpdated,
      ),
    );
  }
}
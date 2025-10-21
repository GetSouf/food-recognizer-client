// lib/widgets/profile_card.dart
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onEdit;

  const ProfileCard({super.key, required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bmi = profile['bmi']?.toStringAsFixed(1) ?? 'N/A';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profile['username'] ?? 'N/A',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Email: ${profile['email'] ?? 'N/A'}', style: theme.textTheme.bodyLarge),
            Text('Рост: ${profile['height_cm']?.toStringAsFixed(1) ?? 'N/A'} см', style: theme.textTheme.bodyLarge),
            Text('Вес: ${profile['weight_kg']?.toStringAsFixed(1) ?? 'N/A'} кг', style: theme.textTheme.bodyLarge),
            Text('Цели: ${profile['goals']?.toString() ?? '{}'}', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('BMI: $bmi', style: theme.textTheme.titleMedium?.copyWith(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
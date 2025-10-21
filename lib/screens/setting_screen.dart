// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:food_recognizer_client/widgets/global_widgets/pull_to_refresh_scaffold.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return PullToRefresh(
      onRefresh: () async {}, // Ничего не обновляем
      child: Scaffold(
        appBar: AppBar(title: const Text('Настройки')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Тёмная тема'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) => themeProvider.toggleTheme(),
              ),
            ],
            
          ),
        ),
      ),
    );
  }
}
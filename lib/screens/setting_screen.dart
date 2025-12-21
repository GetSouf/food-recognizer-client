// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:food_recognizer_client/screens/login_screen.dart';
import 'package:food_recognizer_client/widgets/global_widgets/pull_to_refresh_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_recognizer_client/services/user_service.dart';
import '../providers/theme_provider.dart';
import 'package:webview_flutter/webview_flutter.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserService.getProfile();
      if (mounted) {
        final height = profile['height_cm'] ?? '';
        final weight = profile['weight_kg'] ?? '';
        _heightController.text = height.toString();
        _weightController.text = weight.toString();
      }
    } catch (e) {
      // Игнорируем ошибку — поля останутся пустыми
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    double? heightCm, weightKg;
    if (heightText.isNotEmpty) heightCm = double.tryParse(heightText);
    if (weightText.isNotEmpty) weightKg = double.tryParse(weightText);

    if (heightCm == null && weightKg == null) return;

    setState(() => _isSaving = true);
    try {
      await UserService.updateProfile(heightCm: heightCm, weightKg: weightKg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные сохранены')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString().split('.').first}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

 Future<void> _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("token");
  
  if (!mounted) return;

  // Полный выход: заменяем всё на LoginScreen
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (Route<dynamic> route) => false,
  );
}

  Future<String> _getAppVersion() async {
    // Заглушка — можно подключить package_info_plus
    return "1.0.0";
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PullToRefresh(
      onRefresh: () async {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Настройки'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // === Профиль: Рост и Вес ===
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Профиль', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildTextField(_heightController, 'Рост (см)', TextInputType.number),
                        const SizedBox(height: 12),
                        _buildTextField(_weightController, 'Вес (кг)', TextInputType.number),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            ),
                            child: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // === Тема ===
                /*Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile.adaptive(
                    title: const Text('Тёмная тема'),
                    subtitle: Text(sisDark ? 'Включена' : 'Выключена'),
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeColor: theme.primaryColor,
                    dense: true,
                  ),
                ),*/

                // === Уведомления ===
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: 'Уведомления',
                  subtitle: 'Настройки напоминаний',
                  onTap: () {
                    // Заглушка
                  },
                ),

                // === Поддержка ===
                _buildSettingTile(
                  icon: Icons.help,
                  title: 'Поддержка',
                  subtitle: 'Связь с разработчиками',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Поддержка'),
                        content: const Text('Email: support@foodai.app\nTelegram: @foodai_support'),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: const Text('Закрыть'),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // === Политика конфиденциальности ===
                _buildSettingTile(
                  icon: Icons.policy,
                  title: 'Политика конфиденциальности',
                  subtitle: 'Как мы используем ваши данные',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Документация')),
                          body: WebViewWidget(
                            controller: WebViewController()
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..loadRequest(Uri.parse('https://getsouf.github.io/food-recognizer-client/')),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // === ДОКУМЕНТАЦИЯ ===
                _buildSettingTile(
                  icon: Icons.menu_book,
                  title: 'Документация',
                  subtitle: 'Руководство пользователя и справка',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('Документация')),
                          body: WebViewWidget(
                            controller: WebViewController()
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..loadRequest(Uri.parse('https://getsouf.github.io/food-recognizer-client/')),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // === Версия ===
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Версия'),
                    subtitle: FutureBuilder<String>(
                      future: _getAppVersion(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text('v${snapshot.data}');
                        }
                        return const Text('...');
                      },
                    ),
                    enabled: false, // нельзя нажать
                  ),
                ),

                // === Выход ===
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('Завершить сеанс', style: TextStyle(color: Colors.red)),
                    onTap: _logout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: type,
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
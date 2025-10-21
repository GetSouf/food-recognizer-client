// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:food_recognizer_client/models/meal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/global_widgets/bottom_nav_screen.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool isLogin = true;
  String message = '';

  Future<void> _submit() async {
    try {
      final data = isLogin
          ? await loginUser(usernameCtrl.text, passwordCtrl.text)
          : await registerUser(usernameCtrl.text, emailCtrl.text, passwordCtrl.text);

      if (data.containsKey("access_token")) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["access_token"]);

        // Предварительная загрузка данных
        List<Meal> meals = []; // Инициализируем пустым списком
        Map<String, dynamic> profile = {};
        bool hasError = false;

        try {
          meals = await DataService.getMeals();
          profile = await UserService.getProfile();
        } catch (e) {
          hasError = true; // Отмечаем ошибку, но продолжаем
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BottomNavScreen(
              token: data["access_token"],
              preloadedMeals: meals, // Передаём либо загруженные, либо пустой список
              preloadedProfile: profile,
              hasError: hasError,
            ),
          ),
        );
      } else {
        setState(() {
          message = data["detail"] ?? "Ошибка";
        });
      }
    } catch (e) {
      setState(() => message = "Ошибка: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Вход" : "Регистрация")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameCtrl,
              decoration: const InputDecoration(labelText: "Имя пользователя"),
            ),
            if (!isLogin)
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Пароль"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isLogin ? "Войти" : "Зарегистрироваться"),
            ),
            TextButton(
              onPressed: () => setState(() {
                isLogin = !isLogin;
                message = '';
              }),
              child: Text(isLogin ? "Создать аккаунт" : "Уже есть аккаунт"),
            ),
            if (message.isNotEmpty) Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
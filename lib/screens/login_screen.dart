// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:food_recognizer_client/models/meal_model.dart';
import 'package:food_recognizer_client/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/global_widgets/bottom_nav_screen.dart';
import '../services/data_service.dart';
import '../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  String message = '';

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      final data = isLogin
          ? await loginUser(usernameCtrl.text, passwordCtrl.text)
          : await registerUser(usernameCtrl.text, emailCtrl.text, passwordCtrl.text);

      if (data.containsKey("access_token")) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["access_token"]);

        List<Meal> meals = [];
        Map<String, dynamic> profile = {};
        bool hasError = false;

        try {
          meals = await DataService.getMeals();
          profile = await UserService.getProfile();
        } catch (e) {
          hasError = true;
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => BottomNavScreen(
              token: data["access_token"],
              preloadedMeals: meals,
              preloadedProfile: profile,
              hasError: hasError,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        setState(() {
          message = data["detail"] ?? "Ошибка авторизации";
        });
      }
    } catch (e) {
      setState(() {
        message = "Ошибка: ${e.toString().split('.').first}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade200,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? "Добро пожаловать!" : "Создайте аккаунт",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // Поле логина
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: usernameCtrl,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                            hintText: "Имя пользователя",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Поле email (только при регистрации)
                      if (!isLogin)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: TextField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                              hintText: "Email",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 8),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Поле пароля
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: passwordCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            hintText: "Пароль",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(left: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Кнопка действия
                      GestureDetector(
                        onTapDown: (_) => _controller.forward(),
                        onTapUp: (_) => _controller.reverse(),
                        onTapCancel: () => _controller.reverse(),
                        onTap: _submit,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.green, Colors.teal],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isLogin ? "Войти" : "Зарегистрироваться",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Переключатель режима
                      TextButton(
                        onPressed: () => setState(() {
                          isLogin = !isLogin;
                          message = '';
                        }),
                        child: Text(
                          isLogin
                              ? "Нет аккаунта? Зарегистрируйтесь"
                              : "Уже есть аккаунт? Войдите",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      // Сообщение об ошибке
                      if (message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            message,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Кастомный рисовальщик волн
class WavePainter extends CustomPainter {
  final bool top;

  WavePainter({required this.top});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    if (top) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width, size.height * 0.2);
      path.lineTo(0, size.height * 0.2);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.6);
      path.lineTo(0, size.height * 0.6);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
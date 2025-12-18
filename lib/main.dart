// lib/main.dart
import 'package:flutter/material.dart';
import 'package:food_recognizer_client/models/meal_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'config/theme_config.dart';
import 'widgets/global_widgets/bottom_nav_screen.dart';
import 'screens/login_screen.dart';
import 'services/data_service.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  List<Meal> meals = [];
  Map<String, dynamic> profile = {};
  bool hasError = false;

  if (token != null && token.isNotEmpty) {
    try {
      meals = await DataService.getMeals();
      profile = await UserService.getProfile();
    } catch (e) {
      
      print('Auth error on startup: $e');
      hasError = true;
    }
  }

  runApp(FoodRecognizerApp(
    token: token,
    meals: meals,
    profile: profile,
    hasError: hasError,
  ));
}

class FoodRecognizerApp extends StatelessWidget {
  final String? token;
  final List<Meal> meals;
  final Map<String, dynamic> profile;
  final bool hasError;

  const FoodRecognizerApp({
    super.key,
    required this.token,
    required this.meals,
    required this.profile,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Food Recognizer',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: BottomNavScreen(
              token: token,
              preloadedMeals: meals,
              preloadedProfile: profile,
              hasError: hasError,
            ),
          );
        },
      ),
    );
  }
}
// lib/widgets/bottom_nav_screen.dart
import 'package:flutter/material.dart';
import 'package:food_recognizer_client/config/perfomance_config.dart';
import 'package:food_recognizer_client/models/meal_model.dart';
import 'package:food_recognizer_client/screens/setting_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../screens/login_screen.dart';
import '../../screens/news_screen.dart';
import '../../screens/meals_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/profile_screen.dart';
import '../../services/data_service.dart';
import '../../services/user_service.dart';
import 'pull_to_refresh_scaffold.dart';

class BottomNavScreen extends StatefulWidget {
  final String? token;
  final List<Meal> preloadedMeals;
  final Map<String, dynamic> preloadedProfile;
  final bool hasError;

  const BottomNavScreen({
    super.key,
    required this.token,
    required this.preloadedMeals,
    required this.preloadedProfile,
    required this.hasError,
  });

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 2;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuthorization();
  }

  Future<void> _checkAuthorization() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? widget.token;
    if (token?.isNotEmpty ?? false) {
      if (mounted) {
        setState(() {
          _isAuthorized = true;
        });
      }
    } else if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    PerformanceConfig.optimizeWidget(context);
    final theme = Theme.of(context);

    final List<Meal> mealsForScreen = List<Meal>.from(widget.preloadedMeals);

    final List<Widget> screens = [
      PullToRefresh(
        onRefresh: () async {},
        child: const NewsScreen(),
      ),
      PullToRefresh(
        onRefresh: () async {
          try {
            final meals = await DataService.getMeals();
            setState(() {
              // Нельзя мутировать widget.preloadedMeals
              // Но лучше перепроектировать архитектуру (например, через Provider)
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обновления: $e')));
          }
        },
        child: MealsScreen(preloadedMeals: mealsForScreen),
      ),
      PullToRefresh(
        onRefresh: () async {},
        child: const HomeScreen(),
      ),
      PullToRefresh(
        onRefresh: () async {
          try {
            final profile = await UserService.getProfile();
            setState(() {
              widget.preloadedProfile.clear();
              widget.preloadedProfile.addAll(profile);
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обновления: $e')));
          }
        },
        child: _isAuthorized ? ProfileScreen(preloadedProfile: widget.preloadedProfile) : const LoginScreen(),
      ),
      PullToRefresh(
        onRefresh: () async {},
        child: const SettingsScreen(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: theme.cardColor,
                unselectedItemColor: theme.iconTheme.color?.withOpacity(0.5),
                selectedItemColor: theme.primaryColor,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.article, size: 28), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.history, size: 28), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.camera_alt, size: 28), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.settings, size: 28), label: ''),
                ],
              ),
            ),
            Positioned(
              child: GestureDetector(
                onTap: () => _onItemTapped(2),
                child: Transform.translate(
                  offset: const Offset(0, -25),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.camera_alt,
                      size: 36,
                      color: _selectedIndex == 2 ? theme.primaryColor : theme.iconTheme.color?.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
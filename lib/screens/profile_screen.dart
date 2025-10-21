import 'package:flutter/material.dart';

import 'package:food_recognizer_client/models/dailygoal_model.dart';
import 'package:food_recognizer_client/models/meal_model.dart';
import 'package:food_recognizer_client/screens/login_screen.dart';
import 'package:food_recognizer_client/services/data_service.dart';
import 'package:food_recognizer_client/services/user_service.dart';

import 'package:food_recognizer_client/widgets/global_widgets/pull_to_refresh_scaffold.dart';
import 'package:food_recognizer_client/widgets/profle_widgets/profile_edit_section.dart';
import 'package:food_recognizer_client/widgets/profle_widgets/profile_header.dart';
import 'package:food_recognizer_client/widgets/profle_widgets/profile_stats_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> preloadedProfile;

  const ProfileScreen({super.key, required this.preloadedProfile});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _profile;
  late Future<List<Meal>> _mealsFuture;
  late DailyGoal? _dailyGoal;

  @override
  void initState() {
    super.initState();
    _profile = Map.from(widget.preloadedProfile);
    _dailyGoal = _profile['goals'] != null ? DailyGoal.fromJson(_profile['goals']) : null;
    _mealsFuture = DataService.getMeals();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserService.getProfile();
      setState(() {
        _profile = profile;
        _dailyGoal = profile['goals'] != null ? DailyGoal.fromJson(profile['goals']) : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefresh(
      onRefresh: () async {
        await _loadProfile();
        setState(() {
          _mealsFuture = DataService.getMeals();
        });
      },
      child: Scaffold(
        body: FutureBuilder<List<Meal>>(
          future: _mealsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }
            final meals = snapshot.data ?? [];
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ProfileHeader(username: _profile['username'] ?? 'N/A'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ProfileStatsSection(meals: meals, dailyGoal: _dailyGoal),
                        const SizedBox(height: 16),
                        ProfileEditSection(
                          profile: _profile,
                          onGoalUpdated: (newGoal) {
                            if (newGoal != null) {
                              setState(() {
                                _dailyGoal = newGoal;
                                _profile['goals'] = newGoal.toJson(); // Синхронизация
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Выйти', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
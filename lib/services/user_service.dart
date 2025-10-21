import 'dart:convert';

import 'package:food_recognizer_client/models/dailygoal_model.dart' show DailyGoal;
import 'package:http/http.dart' as http;
import 'token_service.dart';

class UserService {
  static const String _baseUrl = 'http://46.8.29.113:8000';

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['daily_goal'] != null) {
        //data['goals'] = DailyGoal.fromJson(data['daily_goal']);
      }
      return data;
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  static Future<void> updateProfile({double? heightCm, double? weightKg}) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    final response = await http.put(
      Uri.parse('$_baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        if (heightCm != null) 'height_cm': heightCm.toString(),
        if (weightKg != null) 'weight_kg': weightKg.toString(),
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> updateDailyGoal(DailyGoal goal) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    final jsonBody = jsonEncode(goal.toJson());
    print('Sending goal to /profile/goal: $jsonBody');
    final response = await http.put(
      Uri.parse('$_baseUrl/profile/goal'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonBody,
    );
    if (response.statusCode != 200) {
      print('Error response: ${response.body}');
      throw Exception('Failed to update daily goal: ${response.statusCode} - ${response.body}');
    }
  }

  static double calculateBMR(double weightKg, double heightCm, int age, bool isMale) {
    final bmr = isMale
        ? (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5
        : (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    if (bmr.isNaN || bmr.isInfinite) throw Exception('Invalid BMR calculation');
    return bmr;
  }

  static DailyGoal calculateDailyGoal(double bmr, String goal) {
    double multiplier;
    switch (goal) {
      case 'Maintenance':
        multiplier = 1.0;
        break;
      case 'Gain':
        multiplier = 1.1;
        break;
      case 'Lose':
        multiplier = 0.9;
        break;
      default:
        multiplier = 1.0;
    }
    final totalCalories = bmr * multiplier;
    if (totalCalories.isNaN || totalCalories.isInfinite || totalCalories <= 0) {
      print('Invalid totalCalories: $totalCalories');
      throw Exception('Invalid total calories calculation');
    }
    return DailyGoal(
      calories: totalCalories,
      proteins: (totalCalories * 0.30) / 4,
      fats: (totalCalories * 0.30) / 9,
      carbs: (totalCalories * 0.40) / 4,
    );
  }
}
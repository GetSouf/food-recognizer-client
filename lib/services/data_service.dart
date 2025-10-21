// lib/services/data_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../models/meal_model.dart';

class DataService {
  static const String _baseUrl = 'http://46.8.29.113:8000';

  static Future<List<Meal>> getMeals() async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    final response = await http.get(
      Uri.parse('$_baseUrl/meals'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Meal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meals: ${response.statusCode}');
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

static List<Meal> filterTodayMeals(List<Meal> meals) {
  final today = DateTime.now();
  return meals.where((meal) => _isSameDay(meal.createdAt, today)).toList();
}
}
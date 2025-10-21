// lib/services/scan_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'token_service.dart';

class ScanService {
  static const String _baseUrl = 'http://46.8.29.113:8000';

  static Future<Map<String, dynamic>> predictImage(File image, {String? weightG}) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/predict'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    if (weightG != null) request.fields['weight_g'] = weightG;

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return jsonDecode(responseData);
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  static Future<void> rateMeal(int mealId, int rating) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    final response = await http.put(
      Uri.parse('$_baseUrl/meals/$mealId'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'rating': rating.toString()},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to rate meal: ${response.statusCode}');
    }
  }
}
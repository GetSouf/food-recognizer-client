// lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../models/news_model.dart';

class NewsService {
  static const String _baseUrl = 'http://46.8.29.113:8000';

  static Future<List<News>> getNews() async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    final response = await http.get(
      Uri.parse('$_baseUrl/news'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }

  static Future<void> likeNews(int newsId) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    final response = await http.post(
      Uri.parse('$_baseUrl/news/$newsId/like'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to like news: ${response.statusCode}');
    }
  }

  static Future<void> viewNews(int newsId) async {
    final token = await TokenService().getToken();
    if (token == null) throw Exception('No token available');

    final response = await http.post(
      Uri.parse('$_baseUrl/news/$newsId/view'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to view news: ${response.statusCode}');
    }
  }
}
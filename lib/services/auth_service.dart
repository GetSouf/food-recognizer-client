// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> registerUser(String username, String email, String password) async {
  final response = await http.post(
    Uri.parse('http://46.8.29.113:8000/auth/register'),  // Добавил /auth
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'email': email, 'password': password}),
  );
  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> loginUser(String username, String password) async {
  final response = await http.post(
    Uri.parse('http://46.8.29.113:8000/auth/login'),  // Добавил /auth
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );
  return jsonDecode(response.body);
}
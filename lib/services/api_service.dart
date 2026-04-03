import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api/v1'; // Update with your server IP for physical device

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_token', data['token']);
      await prefs.setString('admin_id', data['admin']['id']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createNews({
    required String title,
    required String content,
    String? headerImageUrl,
    List<String>? images,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/news'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'content': content,
        'header_image_url': headerImageUrl,
        'images': images ?? [],
      }),
    );
    return jsonDecode(response.body);
  }

  // Wishes don't have a dedicated route in the analyzed backend yet, 
  // but they are in the schema. We'll use a placeholder or createNews for now 
  // if you want to reuse the news table, or wait for wishes routes.
}

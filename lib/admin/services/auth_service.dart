import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'api_client.dart';

class AuthService {
  AuthService._(this._apiClient);

  static AuthService? _instance;
  static const String _tokenKey = 'admin_token';
  final ApiClient _apiClient;

  static void initialize() {
    _instance = AuthService._(ApiClient(baseUrl: AppConfig.apiV1BaseUrl));
  }

  static AuthService get instance {
    final AuthService? service = _instance;
    if (service == null) {
      throw StateError('AuthService.initialize() must be called before use');
    }
    return service;
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final Map<String, dynamic> payload = await _apiClient.post(
      '/admin/login',
      body: <String, dynamic>{
        'username': username,
        'password': password,
      },
    );

    final Object? token = payload['token'];
    if (token is! String || token.isEmpty) {
      throw Exception('Invalid login response: missing token');
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String> requireToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('Admin session not found. Please login again.');
    }
    return token;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final String token = await requireToken();
    final Map<String, dynamic> payload = await _apiClient.get(
      '/admin/dashboard',
      bearerToken: token,
    );
    return (payload['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;

  Future<Map<String, dynamic>> get(
    String path, {
    String? bearerToken,
  }) async {
    final Uri uri = Uri.parse('$baseUrl$path');
    final http.Response response = await http.get(uri, headers: _headers(bearerToken));
    return _parse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    final Uri uri = Uri.parse('$baseUrl$path');
    final http.Response response = await http.post(
      uri,
      headers: _headers(bearerToken),
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    final Uri uri = Uri.parse('$baseUrl$path');
    final http.Response response = await http.put(
      uri,
      headers: _headers(bearerToken),
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  Map<String, String> _headers(String? bearerToken) {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }
    return headers;
  }

  Map<String, dynamic> _parse(http.Response response) {
    Map<String, dynamic> payload = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }
    final Object? message = payload['message'] ?? payload['error'];
    throw Exception(
      'HTTP ${response.statusCode}: ${message ?? 'Request failed'}',
    );
  }
}

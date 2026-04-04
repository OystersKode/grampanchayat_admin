class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.137.1:5000',
  );

  static String get apiV1BaseUrl => '$apiBaseUrl/api/v1';
}

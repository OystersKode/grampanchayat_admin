import '../config/app_config.dart';
import 'api_client.dart';
import 'auth_service.dart';

class NewsService {
  NewsService._(this._apiClient);

  static NewsService? _instance;
  final ApiClient _apiClient;

  static void initialize() {
    _instance = NewsService._(ApiClient(baseUrl: AppConfig.apiV1BaseUrl));
  }

  static NewsService get instance {
    final NewsService? service = _instance;
    if (service == null) {
      throw StateError('NewsService.initialize() must be called before use');
    }
    return service;
  }

  Future<List<Map<String, dynamic>>> fetchNews() async {
    final String? token = await AuthService.instance.getToken();
    final Map<String, dynamic> payload = await _apiClient.get(
      '/news',
      bearerToken: token,
    );
    final List<dynamic> rows = (payload['data'] as List<dynamic>?) ?? <dynamic>[];
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> deleteNews(String id) async {
    final String token = await AuthService.instance.requireToken();
    await _apiClient.delete(
      '/news/$id',
      bearerToken: token,
    );
  }

  Future<void> createNews({
    required String title,
    required String content,
    String headerImageUrl = '',
  }) async {
    final String token = await AuthService.instance.requireToken();
    await _apiClient.post(
      '/news',
      bearerToken: token,
      body: <String, dynamic>{
        'title': title,
        'content': content,
        'header_image_url': headerImageUrl,
      },
    );
  }

  Future<void> updateNews({
    required String id,
    required String title,
    required String content,
    String headerImageUrl = '',
  }) async {
    final String token = await AuthService.instance.requireToken();
    await _apiClient.put(
      '/news/$id',
      bearerToken: token,
      body: <String, dynamic>{
        'title': title,
        'content': content,
        'header_image_url': headerImageUrl,
      },
    );
  }

  Future<String> uploadImageBase64(String imageBase64) async {
    final String token = await AuthService.instance.requireToken();
    final Map<String, dynamic> response = await _apiClient.post(
      '/news/upload-image',
      bearerToken: token,
      body: <String, dynamic>{'image_base64': imageBase64},
    );
    final Object? imageUrl = response['image_url'];
    if (imageUrl is! String || imageUrl.isEmpty) {
      throw Exception('Image upload response missing image_url');
    }
    return imageUrl;
  }
}

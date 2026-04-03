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

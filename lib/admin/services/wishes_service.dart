import '../config/app_config.dart';
import 'api_client.dart';
import 'auth_service.dart';

class WishesService {
  WishesService._(this._apiClient);

  static WishesService? _instance;
  final ApiClient _apiClient;

  static void initialize() {
    _instance = WishesService._(ApiClient(baseUrl: AppConfig.apiV1BaseUrl));
  }

  static WishesService get instance {
    final WishesService? service = _instance;
    if (service == null) {
      throw StateError('WishesService.initialize() must be called before use');
    }
    return service;
  }

  Future<List<Map<String, dynamic>>> fetchWishes() async {
    final String? token = await AuthService.instance.getToken();
    final Map<String, dynamic> payload = await _apiClient.get(
      '/wishes',
      bearerToken: token,
    );
    final List<dynamic> rows = (payload['data'] as List<dynamic>?) ?? <dynamic>[];
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> createWish({
    required String title,
    required String content,
    String headerImageUrl = '',
    String tag = '',
  }) async {
    final String token = await AuthService.instance.requireToken();
    await _apiClient.post(
      '/wishes',
      bearerToken: token,
      body: <String, dynamic>{
        'title': title,
        'content': content,
        'header_image_url': headerImageUrl,
        'tag': tag,
      },
    );
  }

  Future<void> updateWish({
    required String id,
    required String title,
    required String content,
    String headerImageUrl = '',
    String tag = '',
  }) async {
    final String token = await AuthService.instance.requireToken();
    await _apiClient.put(
      '/wishes/$id',
      bearerToken: token,
      body: <String, dynamic>{
        'title': title,
        'content': content,
        'header_image_url': headerImageUrl,
        'tag': tag,
      },
    );
  }

  Future<void> deleteWish(String id) async {
    final String token = await AuthService.instance.requireToken();
    await _apiClient.delete(
      '/wishes/$id',
      bearerToken: token,
    );
  }
}

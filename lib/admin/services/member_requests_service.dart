import '../config/app_config.dart';
import 'api_client.dart';
import 'auth_service.dart';

class MemberRequestsService {
  MemberRequestsService._(this._apiClient);

  static MemberRequestsService? _instance;
  final ApiClient _apiClient;

  static void initialize() {
    _instance = MemberRequestsService._(ApiClient(baseUrl: AppConfig.apiV1BaseUrl));
  }

  static MemberRequestsService get instance {
    final MemberRequestsService? service = _instance;
    if (service == null) {
      throw StateError('MemberRequestsService.initialize() must be called before use');
    }
    return service;
  }

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    final String token = await AuthService.instance.requireToken();
    final Map<String, dynamic> payload = await _apiClient.get(
      '/member-requests',
      bearerToken: token,
    );
    final List<dynamic> rows = (payload['data'] as List<dynamic>?) ?? <dynamic>[];
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> updateStatus({
    required int id,
    required String status,
  }) async {
    final String token = await AuthService.instance.requireToken();
    await _apiClient.put(
      '/member-request/$id',
      bearerToken: token,
      body: <String, dynamic>{'status': status},
    );
  }
}

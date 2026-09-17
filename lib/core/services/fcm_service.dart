import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../network/api_client.dart';
import '../config/app_config.dart';

class FcmService {
  final ApiClient _apiClient;

  FcmService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  /// Gets or generates a stable device token for push notification dispatch
  Future<String> getDeviceToken() async {
    String token;
    try {
      token = const Uuid().v4();
    } catch (_) {
      token = 'device-${DateTime.now().millisecondsSinceEpoch}';
    }
    return token;
  }

  /// Registers device token with FastAPI backend
  Future<bool> registerDeviceToken() async {
    if (AppConfig.demoMode) return true;

    try {
      final token = await getDeviceToken();
      await _apiClient.post(
        '/devices/fcm-token',
        body: {
          'fcm_token': token,
          'device_platform': 'Android',
        },
      );
      debugPrint('[FcmService] Registered device token: $token');
      return true;
    } catch (e) {
      debugPrint('[FcmService] Failed to register FCM token: $e');
      return false;
    }
  }
}

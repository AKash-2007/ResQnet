import 'package:flutter/services.dart';

class NativeBridgeService {
  static const MethodChannel _channel = MethodChannel('com.resqnet/native_bridge');

  /// Sets up Android 8.0+ notification channels for emergency alerts
  static Future<bool> setupNotificationChannels() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('setupNotificationChannels');
      return result ?? false;
    } on MissingPluginException {
      // Running on web/desktop/unsupported platform or test
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Triggers emergency haptic/vibration feedback pattern via native Android Vibrator
  static Future<void> triggerNativeEmergencyFeedback() async {
    try {
      await _channel.invokeMethod('triggerNativeEmergencyFeedback');
    } catch (_) {}
  }

  /// Checks if the notification channel is enabled in Android settings
  static Future<bool> checkNotificationChannelStatus() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('checkNotificationChannelStatus');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Displays a heads-up high-importance native Android emergency notification
  static Future<void> showEmergencyNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _channel.invokeMethod('showEmergencyNotification', {
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }

  /// Gets device platform details for diagnostics
  static Future<Map<String, dynamic>> getDevicePlatformInfo() async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod('getDevicePlatformInfo');
      return result != null ? Map<String, dynamic>.from(result) : {};
    } catch (_) {
      return {'platform': 'unknown'};
    }
  }
}

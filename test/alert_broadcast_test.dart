import 'package:flutter_test/flutter_test.dart';
import 'package:resqnet/core/config/app_config.dart';
import 'package:resqnet/features/emergency/models/emergency_incident_model.dart';
import 'package:resqnet/core/services/emergency_alert_listener_service.dart';

void main() {
  group('Real-World Alert Broadcasting Tests', () {
    test('AppConfig defaults to real-world mode with demoMode false', () {
      expect(AppConfig.demoMode, isFalse);
    });

    test('AppConfig dynamically computes active host and URLs', () {
      AppConfig.customServerHost = '192.168.1.55:8000';
      expect(AppConfig.activeHost, '192.168.1.55:8000');
      expect(AppConfig.apiBaseUrl, 'http://192.168.1.55:8000/api/v1');
      expect(AppConfig.wsBaseUrl, 'ws://192.168.1.55:8000/api/v1/ws');

      // Reset
      AppConfig.customServerHost = null;
      expect(AppConfig.activeHost, AppConfig.defaultLanHost);
    });

    test('IncomingAlertEvent properly bundles incident model and proximity distance', () {
      final incident = EmergencyIncidentModel(
        id: 'real-inc-101',
        requesterId: 'user-nearby-1',
        emergencyType: EmergencyType.medical,
        status: EmergencyStatus.active,
        latitude: 12.9716,
        longitude: 77.5946,
        helpersNotifiedCount: 5,
        createdAt: DateTime.now(),
        isDemo: false,
      );

      final event = IncomingAlertEvent(
        incident: incident,
        distanceMeters: 450,
        minutesAgo: 1,
      );

      expect(event.incident.id, 'real-inc-101');
      expect(event.distanceMeters, 450);
      expect(event.minutesAgo, 1);
      expect(event.incident.isDemo, isFalse);
      expect(event.incident.emergencyType, EmergencyType.medical);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:resqnet/features/auth/models/user_model.dart';
import 'package:resqnet/features/emergency/models/emergency_incident_model.dart';
import 'package:resqnet/features/nearby/models/nearby_stats_model.dart';

void main() {
  group('ResQnet Domain Models Tests', () {
    test('UserModel serializes and deserializes properly', () {
      final user = UserModel(
        id: 'usr-123',
        email: 'test@resqnet.org',
        fullName: 'Test Helper',
        gender: 'Female',
        availableToHelp: true,
        language: 'ta',
      );

      final json = user.toJson();
      expect(json['id'], 'usr-123');
      expect(json['email'], 'test@resqnet.org');
      expect(json['available_to_help'], true);

      final fromJson = UserModel.fromJson(json);
      expect(fromJson.id, user.id);
      expect(fromJson.fullName, user.fullName);
      expect(fromJson.gender, user.gender);
      expect(fromJson.availableToHelp, user.availableToHelp);
    });

    test('EmergencyIncidentModel serializes and parses emergency types', () {
      final incident = EmergencyIncidentModel(
        id: 'inc-999',
        requesterId: 'usr-1',
        emergencyType: EmergencyType.sos,
        status: EmergencyStatus.active,
        latitude: 12.9716,
        longitude: 77.5946,
        helpersNotifiedCount: 8,
        createdAt: DateTime.now(),
        isDemo: true,
      );

      final json = incident.toJson();
      expect(json['emergency_type'], 'SOS');
      expect(json['status'], 'ACTIVE');
      expect(json['helpers_notified_count'], 8);

      final parsed = EmergencyIncidentModel.fromJson(json);
      expect(parsed.emergencyType, EmergencyType.sos);
      expect(parsed.status, EmergencyStatus.active);
      expect(parsed.helpersNotifiedCount, 8);
    });

    test('NearbyStatsModel enforces aggregate metrics with no individual identities', () {
      const stats = NearbyStatsModel(
        totalUsers: 14,
        maleCount: 8,
        femaleCount: 6,
        radiusMeters: 1000,
        isMaskedForPrivacy: false,
        isDemo: true,
      );

      final json = stats.toJson();
      expect(json['total_users'], 14);
      expect(json['male_count'], 8);
      expect(json['female_count'], 6);
      expect(json.containsKey('names'), isFalse);
      expect(json.containsKey('coordinates'), isFalse);
    });
  });
}

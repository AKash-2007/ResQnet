import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../features/emergency/models/emergency_incident_model.dart';
import '../../features/nearby/models/nearby_stats_model.dart';

class DemoService {
  static final DemoService _instance = DemoService._internal();
  factory DemoService() => _instance;
  DemoService._internal();

  bool isDemoModeActive = true;

  // Stream controller to simulate incoming helper responses
  final StreamController<EmergencyIncidentModel> _incidentStreamController =
      StreamController<EmergencyIncidentModel>.broadcast();
  Stream<EmergencyIncidentModel> get incidentStream => _incidentStreamController.stream;

  Timer? _simulationTimer;

  /// Simulates an active emergency incident creation with 8 helpers notified
  EmergencyIncidentModel createDemoEmergency({
    required EmergencyType type,
    double latitude = 12.9716, // Default to Bengaluru coordinates or mock
    double longitude = 77.5946,
  }) {
    final incident = EmergencyIncidentModel(
      id: const Uuid().v4(),
      requesterId: 'demo-user-101',
      emergencyType: type,
      status: EmergencyStatus.active,
      latitude: latitude,
      longitude: longitude,
      helpersNotifiedCount: 8,
      helpersRespondingCount: 0,
      createdAt: DateTime.now(),
      isDemo: true,
    );

    // Schedule progressive simulated helper responses
    _startHelperResponseSimulation(incident);

    return incident;
  }

  void _startHelperResponseSimulation(EmergencyIncidentModel initialIncident) {
    _simulationTimer?.cancel();
    var current = initialIncident;

    // After 3 seconds: 1st helper responds
    _simulationTimer = Timer(const Duration(seconds: 3), () {
      current = current.copyWith(
        helpersRespondingCount: 1,
        status: EmergencyStatus.responding,
      );
      _incidentStreamController.add(current);

      // After 6 seconds: 2nd helper responds ("2 helpers responding")
      _simulationTimer = Timer(const Duration(seconds: 4), () {
        current = current.copyWith(
          helpersRespondingCount: 2,
        );
        _incidentStreamController.add(current);
      });
    });
  }

  /// Cancels active simulation
  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Provides simulated aggregate nearby safety data (strict privacy)
  NearbyStatsModel getDemoNearbyStats({int radiusMeters = 1000}) {
    if (radiusMeters <= 500) {
      return const NearbyStatsModel(
        totalUsers: 6,
        maleCount: 4,
        femaleCount: 2,
        radiusMeters: 500,
        isDemo: true,
      );
    }
    return const NearbyStatsModel(
      totalUsers: 14,
      maleCount: 8,
      femaleCount: 6,
      radiusMeters: 1000,
      isDemo: true,
    );
  }

  void dispose() {
    _simulationTimer?.cancel();
    _incidentStreamController.close();
  }
}

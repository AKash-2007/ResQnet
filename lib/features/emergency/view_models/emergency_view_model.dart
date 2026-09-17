import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/demo_service.dart';
import '../../../core/native/native_bridge_service.dart';
import '../models/emergency_incident_model.dart';

class EmergencyViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final LocationService _locationService;
  final DemoService _demoService;

  EmergencyIncidentModel? _activeIncident;
  EmergencyIncidentModel? get activeIncident => _activeIncident;
  bool get hasActiveEmergency => _activeIncident != null && _activeIncident!.status != EmergencyStatus.resolved && _activeIncident!.status != EmergencyStatus.cancelled;

  List<EmergencyIncidentModel> _incidentHistory = [];
  List<EmergencyIncidentModel> get incidentHistory => _incidentHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _demoStreamSub;
  WebSocketChannel? _incidentWsChannel;
  StreamSubscription? _incidentWsSub;
  Timer? _elapsedTimer;
  int _secondsElapsed = 0;
  int get secondsElapsed => _secondsElapsed;

  EmergencyViewModel({
    ApiClient? apiClient,
    LocationService? locationService,
    DemoService? demoService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _locationService = locationService ?? LocationService(),
        _demoService = demoService ?? DemoService() {
    _listenToDemoEvents();
  }

  void _listenToDemoEvents() {
    _demoStreamSub = _demoService.incidentStream.listen((updatedIncident) {
      if (_activeIncident != null && _activeIncident!.id == updatedIncident.id) {
        _activeIncident = updatedIncident;
        notifyListeners();
      }
    });
  }

  void _startTimer() {
    _secondsElapsed = 0;
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _secondsElapsed = 0;
  }

  void _connectIncidentWebSocket(String incidentId) {
    _disconnectIncidentWebSocket();
    try {
      final wsUrl = Uri.parse('${AppConfig.wsBaseUrl}/emergencies/$incidentId');
      debugPrint('[EmergencyViewModel] Connecting incident WebSocket: $wsUrl');
      _incidentWsChannel = WebSocketChannel.connect(wsUrl);
      _incidentWsSub = _incidentWsChannel!.stream.listen(
        (msg) {
          try {
            final data = jsonDecode(msg.toString()) as Map<String, dynamic>;
            final event = data['event'] as String?;
            if (event == 'helper_responding') {
              final count = (data['helpers_responding_count'] as num?)?.toInt() ?? 1;
              if (_activeIncident != null) {
                _activeIncident = _activeIncident!.copyWith(
                  helpersRespondingCount: count,
                  status: EmergencyStatus.responding,
                );
                notifyListeners();
              }
            } else if (event == 'incident_resolved') {
              if (_activeIncident != null) {
                _activeIncident = _activeIncident!.copyWith(status: EmergencyStatus.resolved);
                notifyListeners();
              }
            } else if (event == 'incident_cancelled') {
              if (_activeIncident != null) {
                _activeIncident = _activeIncident!.copyWith(status: EmergencyStatus.cancelled);
                notifyListeners();
              }
            }
          } catch (e) {
            debugPrint('[EmergencyViewModel] Error parsing incident WS message: $e');
          }
        },
        onError: (e) => debugPrint('[EmergencyViewModel] Incident WS error: $e'),
        onDone: () => debugPrint('[EmergencyViewModel] Incident WS closed'),
      );
    } catch (e) {
      debugPrint('[EmergencyViewModel] Could not connect incident WS: $e');
    }
  }

  void _disconnectIncidentWebSocket() {
    _incidentWsSub?.cancel();
    _incidentWsSub = null;
    try {
      _incidentWsChannel?.sink.close();
    } catch (_) {}
    _incidentWsChannel = null;
  }

  /// Triggers a community emergency alert
  Future<bool> triggerEmergency({required EmergencyType type}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Trigger native emergency haptic feedback immediately
    NativeBridgeService.triggerNativeEmergencyFeedback();

    // Obtain coordinates with fast multi-tier fallback (never delays SOS dispatch)
    double lat = 12.9716;
    double lng = 77.5946;
    final pos = await _locationService.getCurrentLocation(
      highAccuracyTimeout: const Duration(seconds: 3),
      balancedTimeout: const Duration(seconds: 2),
    );
    if (pos != null) {
      lat = pos.latitude;
      lng = pos.longitude;
    }

    if (AppConfig.demoMode) {
      _activeIncident = _demoService.createDemoEmergency(
        type: type,
        latitude: lat,
        longitude: lng,
      );
      _startTimer();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final res = await _apiClient.post(
        '/emergencies',
        body: {
          'emergency_type': type.name.toUpperCase(),
          'latitude': lat,
          'longitude': lng,
          'radius_meters': AppConfig.defaultRadiusMeters,
        },
      );

      if (res != null && res is Map<String, dynamic>) {
        _activeIncident = EmergencyIncidentModel.fromJson(res);
        final incidentId = _activeIncident!.id;
        _startTimer();
        _connectIncidentWebSocket(incidentId);

        // Asynchronously refine incident coordinates with high-accuracy satellite GPS
        _locationService.getCurrentLocation(
          highAccuracyTimeout: const Duration(seconds: 8),
        ).then((refinedPos) {
          if (refinedPos != null &&
              _activeIncident != null &&
              _activeIncident!.id == incidentId &&
              (refinedPos.latitude != lat || refinedPos.longitude != lng)) {
            updateLocationWithCoordinates(refinedPos.latitude, refinedPos.longitude);
          }
        }).catchError((_) {});

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Updates current incident coordinates with explicit coordinates
  Future<void> updateLocationWithCoordinates(double lat, double lng) async {
    if (_activeIncident == null) return;
    _activeIncident = _activeIncident!.copyWith(
      latitude: lat,
      longitude: lng,
    );
    notifyListeners();

    if (!AppConfig.demoMode) {
      try {
        await _apiClient.post(
          '/emergencies/${_activeIncident!.id}/location',
          body: {'latitude': lat, 'longitude': lng},
        );
      } catch (_) {}
    }
  }

  /// Updates current incident coordinates by polling GPS
  Future<void> updateLocation() async {
    if (_activeIncident == null) return;
    _isLoading = true;
    notifyListeners();

    final pos = await _locationService.getCurrentLocation(
      highAccuracyTimeout: const Duration(seconds: 6),
    );
    if (pos != null) {
      await updateLocationWithCoordinates(pos.latitude, pos.longitude);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Marks the current active incident as safe
  Future<void> markAsSafe() async {
    if (_activeIncident == null) return;
    _isLoading = true;
    notifyListeners();

    _demoService.stopSimulation();
    _stopTimer();
    _disconnectIncidentWebSocket();

    final resolved = _activeIncident!.copyWith(
      status: EmergencyStatus.resolved,
      resolvedAt: DateTime.now(),
    );
    _incidentHistory.insert(0, resolved);

    if (!AppConfig.demoMode) {
      try {
        await _apiClient.post('/emergencies/${_activeIncident!.id}/resolve');
      } catch (_) {}
    }

    _activeIncident = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Cancels the emergency alert
  Future<void> cancelEmergency() async {
    if (_activeIncident == null) return;
    _isLoading = true;
    notifyListeners();

    _demoService.stopSimulation();
    _stopTimer();
    _disconnectIncidentWebSocket();

    final cancelled = _activeIncident!.copyWith(
      status: EmergencyStatus.cancelled,
      resolvedAt: DateTime.now(),
    );
    _incidentHistory.insert(0, cancelled);

    if (!AppConfig.demoMode) {
      try {
        await _apiClient.post('/emergencies/${_activeIncident!.id}/cancel');
      } catch (_) {}
    }

    _activeIncident = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Helper responds to an emergency alert
  Future<bool> respondAsHelper(String incidentId) async {
    if (AppConfig.demoMode) {
      return true;
    }
    try {
      await _apiClient.post('/emergencies/$incidentId/respond');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetches an emergency incident by ID (useful for refreshing coordinates)
  Future<EmergencyIncidentModel?> getIncident(String incidentId) async {
    if (AppConfig.demoMode) {
      return _activeIncident;
    }
    try {
      final res = await _apiClient.get('/emergencies/$incidentId');
      if (res != null && res is Map<String, dynamic>) {
        return EmergencyIncidentModel.fromJson(res);
      }
    } catch (_) {}
    return null;
  }

  /// Loads emergency history for the authenticated user
  Future<void> loadHistory() async {
    if (AppConfig.demoMode) {
      if (_incidentHistory.isEmpty) {
        _incidentHistory = [
          EmergencyIncidentModel(
            id: 'hist-1',
            requesterId: 'demo-user-101',
            emergencyType: EmergencyType.medical,
            status: EmergencyStatus.resolved,
            latitude: 12.9716,
            longitude: 77.5946,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            resolvedAt: DateTime.now().subtract(const Duration(days: 1, minutes: -15)),
            isDemo: true,
          ),
          EmergencyIncidentModel(
            id: 'hist-2',
            requesterId: 'demo-user-101',
            emergencyType: EmergencyType.sos,
            status: EmergencyStatus.cancelled,
            latitude: 12.9716,
            longitude: 77.5946,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            resolvedAt: DateTime.now().subtract(const Duration(days: 5, minutes: -2)),
            isDemo: true,
          ),
        ];
        notifyListeners();
      }
      return;
    }

    try {
      final res = await _apiClient.get('/emergencies/history');
      if (res != null && res is List) {
        _incidentHistory = res.map((item) => EmergencyIncidentModel.fromJson(item as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _demoStreamSub?.cancel();
    _elapsedTimer?.cancel();
    _disconnectIncidentWebSocket();
    super.dispose();
  }
}

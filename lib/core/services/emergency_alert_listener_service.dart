import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';
import '../native/native_bridge_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/emergency/models/emergency_incident_model.dart';

class IncomingAlertEvent {
  final EmergencyIncidentModel incident;
  final int distanceMeters;
  final int minutesAgo;

  IncomingAlertEvent({
    required this.incident,
    required this.distanceMeters,
    required this.minutesAgo,
  });
}

class EmergencyAlertListenerService {
  static final EmergencyAlertListenerService _instance = EmergencyAlertListenerService._internal();
  factory EmergencyAlertListenerService() => _instance;
  EmergencyAlertListenerService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final _alertController = StreamController<IncomingAlertEvent>.broadcast();
  Stream<IncomingAlertEvent> get alertStream => _alertController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;
  String? _currentUserId;

  /// Connects to community emergency broadcast stream
  void startListening({required String userId}) {
    if (_isConnected && _currentUserId == userId) return;
    _currentUserId = userId;
    _connect();
  }

  /// Disconnects and stops listening to community emergency alerts
  void stopListening() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _pingTimer?.cancel();
    _pingTimer = null;
    _cleanup();
    _isConnected = false;
    _currentUserId = null;
    debugPrint('[EmergencyAlertListener] Stopped listening to emergency alerts.');
  }

  void _connect() {
    _cleanup();

    if (AppConfig.demoMode) return;

    try {
      final wsUrl = Uri.parse('${AppConfig.wsBaseUrl}/community/alerts?user_id=$_currentUserId');
      debugPrint('[EmergencyAlertListener] Connecting to: $wsUrl');
      _channel = WebSocketChannel.connect(wsUrl);

      _subscription = _channel!.stream.listen(
        (message) {
          _isConnected = true;
          _handleMessage(message);
        },
        onError: (err) {
          debugPrint('[EmergencyAlertListener] WebSocket error: $err');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('[EmergencyAlertListener] WebSocket connection closed.');
          _scheduleReconnect();
        },
        cancelOnError: false,
      );

      _isConnected = true;

      // Start ping timer every 30s to keep connection alive
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (_isConnected && _channel != null) {
          try {
            _channel!.sink.add('ping');
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('[EmergencyAlertListener] Failed to connect: $e');
      _scheduleReconnect();
    }
  }

  Future<void> _handleMessage(dynamic message) async {
    try {
      final data = jsonDecode(message.toString()) as Map<String, dynamic>;
      final event = data['event'] as String?;

      if (event == 'new_emergency_alert') {
        final incidentJson = data['incident'] as Map<String, dynamic>;
        final incident = EmergencyIncidentModel.fromJson(incidentJson);

        // STRICT RULE 1: The emergency person who pressed SOS MUST NEVER receive the alert notification!
        if (_currentUserId != null && incident.requesterId == _currentUserId) {
          debugPrint('[EmergencyAlertListener] Suppressing alert: current user is the requester (${incident.requesterId})');
          return;
        }

        // STRICT RULE 2: If the user disabled "Available to Help", alerts MUST NEVER reach that person!
        final isAvailable = await SecureStorageService().getAvailableToHelp();
        if (!isAvailable) {
          debugPrint('[EmergencyAlertListener] Suppressing alert: user has disabled Available to Help');
          return;
        }

        final distanceMeters = (data['distance_meters'] as num?)?.toInt() ?? 500;
        final minutesAgo = (data['minutes_ago'] as num?)?.toInt() ?? 0;

        // 1. Trigger native emergency sound and haptic vibration pattern
        NativeBridgeService.triggerNativeEmergencyFeedback();

        // 2. Surface high-importance native Android notification
        final typeName = incident.emergencyType.name.toUpperCase();
        NativeBridgeService.showEmergencyNotification(
          title: 'ResQnet Emergency Alert: $typeName',
          body: '$typeName emergency approximately $distanceMeters m away. Tap to respond.',
        );

        // 3. Emit on stream for in-app UI modal display
        _alertController.add(
          IncomingAlertEvent(
            incident: incident,
            distanceMeters: distanceMeters,
            minutesAgo: minutesAgo,
          ),
        );
      }
    } catch (e) {
      debugPrint('[EmergencyAlertListener] Error parsing message: $e');
    }
  }

  void _scheduleReconnect() {
    _isConnected = false;
    _cleanup();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_currentUserId != null) {
        debugPrint('[EmergencyAlertListener] Attempting reconnection...');
        _connect();
      }
    });
  }

  void _cleanup() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _isConnected = false;
  }

  void dispose() {
    stopListening();
    _alertController.close();
  }
}

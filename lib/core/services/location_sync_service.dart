import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../network/api_client.dart';
import 'location_service.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

class LocationSyncService {
  final ApiClient _apiClient;
  final LocationService _locationService;
  final SecureStorageService _storage;

  Timer? _syncTimer;
  StreamSubscription<Position>? _movementSub;
  bool _isSyncing = false;

  LocationSyncService({
    ApiClient? apiClient,
    LocationService? locationService,
    SecureStorageService? storage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _locationService = locationService ?? LocationService(),
        _storage = storage ?? SecureStorageService();

  /// Starts periodic background synchronization and live movement tracking when available to help
  void startPeriodicSync({Duration interval = const Duration(minutes: 2)}) {
    stopPeriodicSync();

    // Run initial sync immediately
    syncLocation();

    // Heartbeat periodic timer
    _syncTimer = Timer.periodic(interval, (_) => syncLocation());

    // Live movement stream: sync whenever helper moves >= 25 meters
    try {
      _movementSub = _locationService.getPositionStream(distanceFilter: 25).listen(
        (pos) => syncCoordinates(pos.latitude, pos.longitude),
        onError: (e) => debugPrint('[LocationSync] Stream error: $e'),
      );
    } catch (e) {
      debugPrint('[LocationSync] Could not start location stream: $e');
    }
  }

  /// Stops periodic synchronization and live movement stream
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _movementSub?.cancel();
    _movementSub = null;
  }

  /// Sends specific coordinates to the backend database
  Future<bool> syncCoordinates(double lat, double lng) async {
    if (_isSyncing || AppConfig.demoMode) return false;

    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) return false;

    final isAvailable = await _storage.getAvailableToHelp();
    if (!isAvailable) return false;

    _isSyncing = true;
    try {
      await _apiClient.post(
        '/helpers/location',
        body: {
          'latitude': lat,
          'longitude': lng,
        },
      );
      debugPrint('[LocationSync] Synced helper coordinates: $lat, $lng');
      _isSyncing = false;
      return true;
    } catch (e) {
      debugPrint('[LocationSync] Failed to sync location: $e');
    } finally {
      _isSyncing = false;
    }
    return false;
  }

  /// Sends the current GPS coordinates to the backend database
  Future<bool> syncLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      return await syncCoordinates(position.latitude, position.longitude);
    }
    return false;
  }
}

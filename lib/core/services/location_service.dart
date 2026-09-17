import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Position? _cachedPosition;

  /// Returns the most recently cached valid position, if any.
  Position? get lastCachedPosition => _cachedPosition;

  /// Checks whether device GPS/location provider is enabled.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Checks whether location permission is granted (whileInUse or always).
  Future<bool> hasPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// Checks if permission was permanently denied by the user.
  Future<bool> isPermissionDeniedForever() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.deniedForever;
    } catch (_) {
      return false;
    }
  }

  /// Requests runtime location permissions from the user.
  Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('[LocationService] Error requesting permission: $e');
      return false;
    }
  }

  /// Opens the device app settings screen (useful if permission is permanently denied).
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Opens the system location settings screen (useful if device GPS toggle is turned OFF).
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (_) {
      return false;
    }
  }

  /// Obtains current GPS coordinates with multi-tiered fallback:
  /// 1. High-accuracy GPS request (default 4s timeout)
  /// 2. Balanced / Cell & Wi-Fi triangulation fallback (default 3s timeout)
  /// 3. Device system last-known position fallback
  /// 4. In-memory cached position fallback
  Future<Position?> getCurrentLocation({
    Duration highAccuracyTimeout = const Duration(seconds: 4),
    Duration balancedTimeout = const Duration(seconds: 3),
  }) async {
    try {
      final permitted = await hasPermission();
      if (!permitted) {
        final granted = await requestPermission();
        if (!granted) {
          debugPrint('[LocationService] Location permission not granted');
          return _cachedPosition;
        }
      }

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Location services (GPS) are disabled on device');
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          _cachedPosition = lastKnown;
          return lastKnown;
        }
        return _cachedPosition;
      }

      // Tier 1: Try High Accuracy (GPS hardware satellite lock)
      try {
        final highPos = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: highAccuracyTimeout,
          ),
        );
        _cachedPosition = highPos;
        return highPos;
      } catch (e) {
        debugPrint('[LocationService] High accuracy position timed out or failed: $e. Falling back to balanced...');
      }

      // Tier 2: Fallback to Medium/Cell/Wi-Fi network accuracy (fast indoors)
      try {
        final mediumPos = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: balancedTimeout,
          ),
        );
        _cachedPosition = mediumPos;
        return mediumPos;
      } catch (e) {
        debugPrint('[LocationService] Medium accuracy position failed: $e. Trying last known...');
      }

      // Tier 3: Fallback to system last-known position
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _cachedPosition = lastKnown;
        return lastKnown;
      }
    } catch (e) {
      debugPrint('[LocationService] Error in getCurrentLocation: $e');
    }

    // Tier 4: In-memory cached position
    return _cachedPosition;
  }

  /// Continuous stream of location updates for real-time tracking
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 15,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).map((pos) {
      _cachedPosition = pos;
      return pos;
    });
  }

  /// Calculates geodesic distance between two coordinate pairs in meters
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Formats distance into friendly string (e.g. "350 m" or "1.8 km")
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}

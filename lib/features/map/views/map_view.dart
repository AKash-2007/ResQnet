import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../l10n/generated/app_localizations.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSub;
  LatLng _currentLocation = const LatLng(12.9716, 77.5946);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _subscribeToLiveLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  void _subscribeToLiveLocation() {
    _positionSub = _locationService.getPositionStream(distanceFilter: 10).listen(
      (pos) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(pos.latitude, pos.longitude);
          });
        }
      },
      onError: (e) => debugPrint('[MapView] Location stream error: $e'),
    );
  }

  Future<void> _loadLocation() async {
    setState(() => _isLoading = true);

    // Verify if device GPS hardware is enabled
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Device GPS is off. Please enable location services.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => _locationService.openLocationSettings(),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    final pos = await _locationService.getCurrentLocation();
    if (pos != null && mounted) {
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _isLoading = false;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 15),
      );
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navMap),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14.5,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            circles: {
              // Safe community assistance radius circle
              Circle(
                circleId: const CircleId('community_radius'),
                center: _currentLocation,
                radius: 1000,
                strokeWidth: 2,
                strokeColor: AppColors.nearby.withOpacity(0.5),
                fillColor: AppColors.nearby.withOpacity(0.08),
              ),
            },
          ),
          if (_isLoading)
            const Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('Locating...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Privacy note at bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.privacyAssurance,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

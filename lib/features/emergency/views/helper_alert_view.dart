import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/emergency_incident_model.dart';
import '../view_models/emergency_view_model.dart';

class HelperAlertView extends StatefulWidget {
  final EmergencyIncidentModel incident;
  final int distanceMeters;
  final int minutesAgo;

  const HelperAlertView({
    super.key,
    required this.incident,
    this.distanceMeters = 650,
    this.minutesAgo = 2,
  });

  @override
  State<HelperAlertView> createState() => _HelperAlertViewState();
}

class _HelperAlertViewState extends State<HelperAlertView> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;

  late LatLng _victimPosition;
  Position? _responderPosition;
  double? _liveDistanceMeters;
  bool _hasAccepted = false;
  bool _isIncidentResolved = false;
  bool _isIncidentCancelled = false;

  WebSocketChannel? _incidentWsChannel;
  StreamSubscription? _incidentWsSub;
  StreamSubscription<Position>? _responderPositionSub;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _victimPosition = LatLng(widget.incident.latitude, widget.incident.longitude);
    _liveDistanceMeters = widget.distanceMeters.toDouble();
    _connectIncidentWebSocket();
    _startResponderLocationTracking();
    _startIncidentPolling();
  }

  @override
  void dispose() {
    _incidentWsSub?.cancel();
    try {
      _incidentWsChannel?.sink.close();
    } catch (_) {}
    _responderPositionSub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Connects to the incident's live WebSocket for real-time victim location updates
  void _connectIncidentWebSocket() {
    if (AppConfig.demoMode) return;
    try {
      final wsUrl = Uri.parse('${AppConfig.wsBaseUrl}/emergencies/${widget.incident.id}');
      debugPrint('[HelperAlertView] Connecting to incident WS: $wsUrl');
      _incidentWsChannel = WebSocketChannel.connect(wsUrl);

      _incidentWsSub = _incidentWsChannel!.stream.listen(
        (msg) {
          try {
            final data = jsonDecode(msg.toString()) as Map<String, dynamic>;
            final event = data['event'] as String?;

            if (event == 'location_updated') {
              final double lat = (data['latitude'] as num).toDouble();
              final double lng = (data['longitude'] as num).toDouble();
              if (mounted) {
                setState(() {
                  _victimPosition = LatLng(lat, lng);
                  _recalculateDistance();
                });
                _mapController?.animateCamera(CameraUpdate.newLatLng(_victimPosition));
              }
            } else if (event == 'incident_resolved') {
              if (mounted) setState(() => _isIncidentResolved = true);
            } else if (event == 'incident_cancelled') {
              if (mounted) setState(() => _isIncidentCancelled = true);
            }
          } catch (e) {
            debugPrint('[HelperAlertView] Error parsing incident WS msg: $e');
          }
        },
        onError: (err) => debugPrint('[HelperAlertView] WS error: $err'),
      );
    } catch (e) {
      debugPrint('[HelperAlertView] WS connection failed: $e');
    }
  }

  /// Tracks responder's own live position and continuously updates geodesic distance to victim
  void _startResponderLocationTracking() async {
    final initialPos = await _locationService.getCurrentLocation();
    if (initialPos != null && mounted) {
      setState(() {
        _responderPosition = initialPos;
        _recalculateDistance();
      });
    }

    _responderPositionSub = _locationService.getPositionStream(distanceFilter: 5).listen(
      (pos) {
        if (mounted) {
          setState(() {
            _responderPosition = pos;
            _recalculateDistance();
          });
        }
      },
      onError: (err) => debugPrint('[HelperAlertView] Position stream error: $err'),
    );
  }

  /// Polls the incident every 12 seconds as a fallback to ensure coordinates stay synchronized
  void _startIncidentPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) async {
      if (!mounted || _isIncidentResolved || _isIncidentCancelled) return;
      final fresh = await context.read<EmergencyViewModel>().getIncident(widget.incident.id);
      if (fresh != null && mounted) {
        if (fresh.status == EmergencyStatus.resolved) {
          setState(() => _isIncidentResolved = true);
        } else if (fresh.status == EmergencyStatus.cancelled) {
          setState(() => _isIncidentCancelled = true);
        } else if (fresh.latitude != _victimPosition.latitude || fresh.longitude != _victimPosition.longitude) {
          setState(() {
            _victimPosition = LatLng(fresh.latitude, fresh.longitude);
            _recalculateDistance();
          });
        }
      }
    });
  }

  void _recalculateDistance() {
    if (_responderPosition != null) {
      _liveDistanceMeters = _locationService.calculateDistance(
        _responderPosition!.latitude,
        _responderPosition!.longitude,
        _victimPosition.latitude,
        _victimPosition.longitude,
      );
    }
  }

  /// Centers the camera on the emergency victim
  void _centerOnVictim() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_victimPosition, 16.5),
    );
  }

  /// Fits both the responder and the emergency victim within the map viewport
  void _fitBothInView() {
    if (_responderPosition == null || _mapController == null) {
      _centerOnVictim();
      return;
    }

    final respLatLng = LatLng(_responderPosition!.latitude, _responderPosition!.longitude);
    final southWest = LatLng(
      min(_victimPosition.latitude, respLatLng.latitude),
      min(_victimPosition.longitude, respLatLng.longitude),
    );
    final northEast = LatLng(
      max(_victimPosition.latitude, respLatLng.latitude),
      max(_victimPosition.longitude, respLatLng.longitude),
    );

    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70),
    );
  }

  /// Copies exact GPS coordinates to clipboard for 911 / 112 / radio relay
  void _copyCoordinates() {
    final text = '${_victimPosition.latitude.toStringAsFixed(6)}, ${_victimPosition.longitude.toStringAsFixed(6)}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied coordinates: $text'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Launches native turn-by-turn navigation or Google Maps directions
  Future<void> _openDirections() async {
    final lat = _victimPosition.latitude;
    final lng = _victimPosition.longitude;

    // 1. Launch Android Native turn-by-turn navigation directly
    final navUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    // 2. Web fallback
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');

    try {
      if (await canLaunchUrl(navUri)) {
        await launchUrl(navUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final emergencyVm = context.watch<EmergencyViewModel>();

    String title;
    Color alertColor;
    switch (widget.incident.emergencyType) {
      case EmergencyType.medical:
        title = l10n.medicalEmergency;
        alertColor = AppColors.medical;
        break;
      case EmergencyType.fire:
        title = l10n.fireEmergency;
        alertColor = AppColors.fire;
        break;
      case EmergencyType.accident:
        title = l10n.accidentEmergency;
        alertColor = AppColors.accident;
        break;
      case EmergencyType.sos:
        title = l10n.sos;
        alertColor = AppColors.sos;
        break;
    }

    final distanceStr = _liveDistanceMeters != null
        ? _locationService.formatDistance(_liveDistanceMeters!)
        : '${widget.distanceMeters} m';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        backgroundColor: alertColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_location_outlined),
            tooltip: 'Copy Victim Coordinates',
            onPressed: _copyCoordinates,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Alert Info Card with Live Coordinates & Distance
            Container(
              color: alertColor.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: alertColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: alertColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              l10n.reportedAgo(widget.minutesAgo),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Live distance pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: alertColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: alertColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.near_me, size: 14, color: alertColor),
                            const SizedBox(width: 4),
                            Text(
                              distanceStr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: alertColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Exact GPS Coordinates Row with 1-Tap Copy
                  InkWell(
                    onTap: _copyCoordinates,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.pin_drop, size: 15, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Victim GPS: ${_victimPosition.latitude.toStringAsFixed(6)}°, ${_victimPosition.longitude.toStringAsFixed(6)}°',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Icon(Icons.copy, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          const Text('Copy', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Incident Status Banners
            if (_isIncidentResolved)
              Container(
                width: double.infinity,
                color: AppColors.success,
                padding: const EdgeInsets.all(12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The person in distress has marked this incident as SAFE.',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else if (_isIncidentCancelled)
              Container(
                width: double.infinity,
                color: Colors.grey.shade700,
                padding: const EdgeInsets.all(12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'This emergency incident was cancelled.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              )
            else if (_hasAccepted)
              Container(
                width: double.infinity,
                color: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_run, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'You responded "I\'M COMING". Requester is notified.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),

            // Live Interactive Google Map Preview
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _victimPosition,
                      zoom: 15.5,
                    ),
                    onMapCreated: (c) => _mapController = c,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false, // Custom buttons below
                    zoomControlsEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('incident_victim'),
                        position: _victimPosition,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        infoWindow: InfoWindow(
                          title: '$title (Victim)',
                          snippet: '${_victimPosition.latitude.toStringAsFixed(6)}, ${_victimPosition.longitude.toStringAsFixed(6)}',
                        ),
                      ),
                    },
                    polylines: _responderPosition != null
                        ? {
                            Polyline(
                              polylineId: const PolylineId('responder_to_victim_path'),
                              points: [
                                LatLng(_responderPosition!.latitude, _responderPosition!.longitude),
                                _victimPosition,
                              ],
                              color: alertColor,
                              width: 4,
                              patterns: [PatternItem.dash(18), PatternItem.gap(10)],
                            ),
                          }
                        : {},
                    circles: {
                      Circle(
                        circleId: const CircleId('victim_search_zone'),
                        center: _victimPosition,
                        radius: 100, // 100m target proximity assist zone
                        strokeWidth: 2,
                        strokeColor: alertColor.withOpacity(0.8),
                        fillColor: alertColor.withOpacity(0.12),
                      ),
                    },
                  ),

                  // Floating Map Action Buttons: Focus Victim & Fit Both
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'center_victim_fab',
                          backgroundColor: Colors.white,
                          foregroundColor: alertColor,
                          tooltip: 'Focus on Victim',
                          onPressed: _centerOnVictim,
                          child: const Icon(Icons.location_searching),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'fit_both_fab',
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          tooltip: 'Fit Both in View',
                          onPressed: _fitBothInView,
                          child: const Icon(Icons.zoom_out_map),
                        ),
                      ],
                    ),
                  ),

                  // Live Tracking Badge at bottom of map
                  Positioned(
                    bottom: 10,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.radar, color: Colors.greenAccent, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Live GPS Tracking Active',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Helper Action Buttons: I'M COMING, OPEN DIRECTIONS, CAN'T HELP
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (!_hasAccepted && !_isIncidentResolved && !_isIncidentCancelled) ...[
                    // I'M COMING
                    ElevatedButton.icon(
                      onPressed: () async {
                        await emergencyVm.respondAsHelper(widget.incident.id);
                        if (mounted) setState(() => _hasAccepted = true);
                      },
                      icon: const Icon(Icons.directions_run),
                      label: Text(l10n.imComing),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // OPEN DIRECTIONS (Google Maps Direct Navigation)
                  OutlinedButton.icon(
                    onPressed: _openDirections,
                    icon: const Icon(Icons.navigation_outlined),
                    label: Text(l10n.openDirections),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: alertColor, width: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // CLOSE / CAN'T HELP
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      (_isIncidentResolved || _isIncidentCancelled) ? 'Close' : l10n.cantHelp,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

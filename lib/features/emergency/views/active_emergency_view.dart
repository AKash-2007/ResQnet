import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/emergency_incident_model.dart';
import '../view_models/emergency_view_model.dart';

class ActiveEmergencyView extends StatefulWidget {
  const ActiveEmergencyView({super.key});

  @override
  State<ActiveEmergencyView> createState() => _ActiveEmergencyViewState();
}

class _ActiveEmergencyViewState extends State<ActiveEmergencyView> {
  String _formatElapsedTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final emergencyVm = context.watch<EmergencyViewModel>();
    final incident = emergencyVm.activeIncident;

    if (incident == null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Return to Home'),
          ),
        ),
      );
    }

    String title;
    Color alertColor;
    switch (incident.emergencyType) {
      case EmergencyType.medical:
        title = l10n.medicalEmergencyActive;
        alertColor = AppColors.medical;
        break;
      case EmergencyType.fire:
        title = l10n.fireEmergencyActive;
        alertColor = AppColors.fire;
        break;
      case EmergencyType.accident:
        title = l10n.accidentEmergencyActive;
        alertColor = AppColors.accident;
        break;
      case EmergencyType.sos:
        title = l10n.sosActive;
        alertColor = AppColors.sos;
        break;
    }

    final currentPosition = LatLng(incident.latitude, incident.longitude);

    return WillPopScope(
      onWillPop: () async => false, // Prevent accidental dismissal during active emergency
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: alertColor,
          foregroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              if (incident.isDemo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Stats Card: Elapsed time, Notified, Responding
              Container(
                color: alertColor.withOpacity(0.08),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Elapsed Time
                    Column(
                      children: [
                        Text(
                          _formatElapsedTime(emergencyVm.secondsElapsed),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.timeElapsed,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Container(height: 36, width: 1, color: Colors.grey.withOpacity(0.3)),
                    // Helpers Notified
                    Column(
                      children: [
                        Text(
                          '${incident.helpersNotifiedCount}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.helpersNotified,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Container(height: 36, width: 1, color: Colors.grey.withOpacity(0.3)),
                    // Helpers Responding
                    Column(
                      children: [
                        Text(
                          '${incident.helpersRespondingCount}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: incident.helpersRespondingCount > 0 ? AppColors.success : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.helpersResponding,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Helper Response Banner
              if (incident.helpersRespondingCount > 0)
                Container(
                  width: double.infinity,
                  color: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_run, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.helpersCountResponding(incident.helpersRespondingCount),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              // Interactive Google Map View
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: currentPosition,
                        zoom: 15.5,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('emergency_location'),
                          position: currentPosition,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          infoWindow: InfoWindow(
                            title: title,
                            snippet: l10n.currentLocation,
                          ),
                        ),
                        if (incident.helpersRespondingCount > 0) ...[
                          Marker(
                            markerId: const MarkerId('helper_1'),
                            position: LatLng(currentPosition.latitude + 0.002, currentPosition.longitude + 0.002),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                            infoWindow: const InfoWindow(title: 'Responding Helper 1'),
                          ),
                          if (incident.helpersRespondingCount > 1)
                            Marker(
                              markerId: const MarkerId('helper_2'),
                              position: LatLng(currentPosition.latitude - 0.002, currentPosition.longitude + 0.001),
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                              infoWindow: const InfoWindow(title: 'Responding Helper 2'),
                            ),
                        ],
                      },
                      circles: {
                        Circle(
                          circleId: const CircleId('radius_ring'),
                          center: currentPosition,
                          radius: 1000,
                          strokeWidth: 2,
                          strokeColor: alertColor.withOpacity(0.5),
                          fillColor: alertColor.withOpacity(0.08),
                        ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),

                    // Floating GPS Info Chip
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.my_location, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${l10n.currentLocation}: ${incident.latitude.toStringAsFixed(4)}, ${incident.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // UPDATE LOCATION
                    OutlinedButton.icon(
                      onPressed: emergencyVm.isLoading ? null : () => emergencyVm.updateLocation(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.updateLocation),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        side: BorderSide(color: alertColor),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // MARK AS SAFE
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: emergencyVm.isLoading
                                ? null
                                : () async {
                                    final nav = Navigator.of(context);
                                    await emergencyVm.markAsSafe();
                                    nav.pop();
                                  },
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(l10n.markAsSafe),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // CANCEL ALERT
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: emergencyVm.isLoading
                                ? null
                                : () async {
                                    final nav = Navigator.of(context);
                                    await emergencyVm.cancelEmergency();
                                    nav.pop();
                                  },
                            icon: const Icon(Icons.close),
                            label: Text(
                              incident.emergencyType == EmergencyType.sos ? l10n.cancelSos : l10n.cancelAlert,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

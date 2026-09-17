import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/emergency_alert_listener_service.dart';
import '../../core/services/fcm_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/view_models/auth_view_model.dart';
import '../emergency/views/helper_alert_view.dart';
import '../home/views/home_dashboard_view.dart';
import '../activity/views/activity_view.dart';
import '../map/views/map_view.dart';
import '../profile/views/profile_view.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  StreamSubscription<IncomingAlertEvent>? _alertSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAlertListeners();
    });
  }

  void _initAlertListeners() {
    final authVm = context.read<AuthViewModel>();
    final user = authVm.currentUser;
    if (user != null) {
      // 1. Register device push token with backend
      FcmService().registerDeviceToken();

      // 2. Connect to live WebSocket community broadcast ONLY IF available to help
      final listener = EmergencyAlertListenerService();
      if (user.availableToHelp) {
        listener.startListening(userId: user.id);
      } else {
        listener.stopListening();
      }

      // 3. Listen for incoming emergencies to display HelperAlertView
      _alertSubscription?.cancel();
      _alertSubscription = listener.alertStream.listen((event) {
        if (!mounted) return;
        // STRICT: Never pop up for the requester themselves
        if (event.incident.requesterId == user.id) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HelperAlertView(
              incident: event.incident,
              distanceMeters: event.distanceMeters,
              minutesAgo: event.minutesAgo,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    super.dispose();
  }

  final List<Widget> _views = const [
    HomeDashboardView(),
    ActivityView(),
    MapView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentIndex = idx);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.emergency_outlined),
            selectedIcon: const Icon(Icons.emergency),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.navActivity,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

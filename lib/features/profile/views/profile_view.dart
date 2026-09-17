import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/native/native_bridge_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../auth/views/login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final LocationService _locationService = LocationService();
  bool _locationPermitted = false;
  bool _gpsHardwareEnabled = true;
  bool _notificationPermitted = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final loc = await _locationService.hasPermission();
    final gps = await _locationService.isLocationServiceEnabled();
    final notif = await NativeBridgeService.checkNotificationChannelStatus();
    if (mounted) {
      setState(() {
        _locationPermitted = loc;
        _gpsHardwareEnabled = gps;
        _notificationPermitted = notif;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final granted = await _locationService.requestPermission();
    if (!granted) {
      final deniedForever = await _locationService.isPermissionDeniedForever();
      if (deniedForever) {
        await _locationService.openAppSettings();
      }
    }
    await _checkPermissions();
  }

  Future<void> _openGpsSettings() async {
    await _locationService.openLocationSettings();
    await _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authVm = context.watch<AuthViewModel>();
    final user = authVm.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProfile),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // User Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'U').toUpperCase(),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'ResQnet Member',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              'Gender: ${user?.gender ?? "Not specified"}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Available to Help Toggle
            Card(
              child: SwitchListTile(
                title: Text(l10n.availableToHelp, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(l10n.availableToHelpDesc),
                value: user?.availableToHelp ?? false,
                activeColor: AppColors.nearby,
                onChanged: (val) => authVm.toggleAvailableToHelp(val),
              ),
            ),
            const SizedBox(height: 20),

            // Settings & Preferences Section
            Text('PREFERENCES', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).hintColor)),
            const SizedBox(height: 8),

            // Language Selector
            Card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                trailing: DropdownButton<String>(
                  value: authVm.currentLocale.languageCode,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                    DropdownMenuItem(value: 'ta', child: Text(l10n.tamil)),
                  ],
                  onChanged: (val) {
                    if (val != null) authVm.setLanguage(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Theme Mode
            Card(
              child: ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(l10n.theme),
                trailing: DropdownButton<ThemeMode>(
                  value: authVm.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (val) {
                    if (val != null) authVm.setThemeMode(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Demo Mode Switch
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.developer_mode),
                title: Text(l10n.demoMode),
                subtitle: const Text('Simulate nearby helpers locally (Turn OFF for live real-world devices)'),
                value: AppConfig.demoMode,
                onChanged: (val) {
                  setState(() => AppConfig.demoMode = val);
                },
              ),
            ),
            const SizedBox(height: 8),

            // Server Host Configuration (e.g. 10.0.2.2:8000 or 192.168.x.x:8000)
            Card(
              child: ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: const Text('Backend Server Host'),
                subtitle: Text(AppConfig.activeHost),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () {
                  final controller = TextEditingController(text: AppConfig.activeHost);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Configure Backend Host'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter your FastAPI host and port.\n'
                            '• Android Emulator: 10.0.2.2:8000\n'
                            '• Physical phones on Wi-Fi: <Your-PC-IP>:8000',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Host:Port',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () {
                            authVm.setServerHost(controller.text);
                            Navigator.of(ctx).pop();
                            setState(() {});
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Permissions Section
            Text('PERMISSIONS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).hintColor)),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: Icon(
                  _locationPermitted ? Icons.location_on : Icons.location_off,
                  color: _locationPermitted ? Colors.green : Colors.red,
                ),
                title: Text(l10n.locationStatus),
                subtitle: Text(_locationPermitted ? l10n.enabled : l10n.locationPermissionRequired),
                trailing: _locationPermitted
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : TextButton(
                        onPressed: _requestLocationPermission,
                        child: const Text('Enable'),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: Icon(
                  _gpsHardwareEnabled ? Icons.gps_fixed : Icons.gps_off,
                  color: _gpsHardwareEnabled ? Colors.green : Colors.orange,
                ),
                title: const Text('Device GPS (Hardware)'),
                subtitle: Text(_gpsHardwareEnabled ? 'Active & Receiving Satellites' : 'Disabled on Device'),
                trailing: _gpsHardwareEnabled
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : TextButton(
                        onPressed: _openGpsSettings,
                        child: const Text('Turn ON'),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: Icon(
                  _notificationPermitted ? Icons.notifications_active : Icons.notifications_off,
                  color: _notificationPermitted ? Colors.blue : Colors.red,
                ),
                title: Text(l10n.notificationStatus),
                subtitle: Text(_notificationPermitted ? l10n.enabled : l10n.notificationPermissionRequired),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 24),

            // Logout & Delete Account
            OutlinedButton.icon(
              onPressed: () async {
                final nav = Navigator.of(context);
                await authVm.logout();
                nav.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.deleteAccount),
                    content: const Text('Are you sure you want to delete your account? All emergency history will be removed permanently.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.cancel)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await authVm.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginView()),
                              (route) => false,
                            );
                          }
                        },
                        child: Text(l10n.deleteAccount),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_forever, color: AppColors.error),
              label: Text(l10n.deleteAccount, style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

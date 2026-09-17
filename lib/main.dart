import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/native/native_bridge_service.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/auth/view_models/auth_view_model.dart';
import 'features/auth/views/login_view.dart';
import 'features/emergency/view_models/emergency_view_model.dart';
import 'features/nearby/view_models/nearby_view_model.dart';
import 'features/navigation/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Android native emergency notification channels
  await NativeBridgeService.setupNotificationChannels();

  runApp(const ResQnetApp());
}

class ResQnetApp extends StatelessWidget {
  const ResQnetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
        ChangeNotifierProvider<EmergencyViewModel>(create: (_) => EmergencyViewModel()),
        ChangeNotifierProvider<NearbyViewModel>(create: (_) => NearbyViewModel()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authVm, _) {
          return MaterialApp(
            title: 'ResQnet',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: authVm.themeMode,
            locale: authVm.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('ta'), // Tamil
            ],
            home: const AppEntryGate(),
          );
        },
      ),
    );
  }
}

class AppEntryGate extends StatelessWidget {
  const AppEntryGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    if (authVm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authVm.isAuthenticated) {
      return const MainScaffold();
    }

    return const LoginView();
  }
}

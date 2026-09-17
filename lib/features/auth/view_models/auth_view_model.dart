import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/services/location_sync_service.dart';
import '../../../core/services/emergency_alert_listener_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorageService _storage;
  final LocationSyncService _locationSyncService;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  AuthViewModel({
    ApiClient? apiClient,
    SecureStorageService? storage,
    LocationSyncService? locationSyncService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? SecureStorageService(),
        _locationSyncService = locationSyncService ?? LocationSyncService() {
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    // Load custom server host if previously configured
    final host = await _storage.getServerHost();
    if (host != null && host.isNotEmpty) {
      AppConfig.customServerHost = host;
    }

    final lang = await _storage.getLanguage();
    if (lang != null && (lang == 'en' || lang == 'ta')) {
      _currentLocale = Locale(lang);
    }

    final theme = await _storage.getThemeMode();
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (theme == 'light') {
      _themeMode = ThemeMode.light;
    }

    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      if (AppConfig.demoMode) {
        _currentUser = const UserModel(
          id: 'demo-user-101',
          email: 'helper@resqnet.org',
          fullName: 'Community Helper',
          gender: 'Other',
          availableToHelp: true,
        );
        notifyListeners();
        return;
      }

      try {
        final res = await _apiClient.get('/users/me');
        if (res != null && res is Map<String, dynamic>) {
          _currentUser = UserModel.fromJson(res);
          if (_currentUser!.availableToHelp) {
            _locationSyncService.startPeriodicSync();
          }
          notifyListeners();
        }
      } catch (_) {
        // Token expired or server unreachable
        await _storage.clearTokens();
        _currentUser = null;
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (AppConfig.demoMode) {
        await Future.delayed(const Duration(milliseconds: 600));
        _currentUser = UserModel(
          id: 'demo-user-101',
          email: email,
          fullName: email.split('@').first.toUpperCase(),
          gender: 'Male',
          availableToHelp: true,
        );
        await _storage.saveTokens(accessToken: 'demo-access-token', refreshToken: 'demo-refresh-token');
        _isLoading = false;
        notifyListeners();
        return true;
      }

      final res = await _apiClient.post(
        '/auth/login',
        body: {'email': email.trim(), 'password': password},
        requiresAuth: false,
      );

      if (res != null && res is Map<String, dynamic>) {
        final accessToken = res['access_token'] as String;
        final refreshToken = res['refresh_token'] as String;
        await _storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

        // Fetch user profile
        final userRes = await _apiClient.get('/users/me');
        _currentUser = UserModel.fromJson(userRes as Map<String, dynamic>);
        if (_currentUser!.availableToHelp) {
          _locationSyncService.startPeriodicSync();
        }
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

  Future<bool> register({
    required String fullName,
    required String email,
    required String gender,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      _errorMessage = "Passwords do not match.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (AppConfig.demoMode) {
        await Future.delayed(const Duration(milliseconds: 600));
        _currentUser = UserModel(
          id: 'demo-user-101',
          email: email,
          fullName: fullName,
          gender: gender,
          availableToHelp: true,
        );
        await _storage.saveTokens(accessToken: 'demo-access-token', refreshToken: 'demo-refresh-token');
        _isLoading = false;
        notifyListeners();
        return true;
      }

      final res = await _apiClient.post(
        '/auth/register',
        body: {
          'full_name': fullName.trim(),
          'email': email.trim(),
          'gender': gender,
          'password': password,
        },
        requiresAuth: false,
      );

      if (res != null) {
        // Automatically login on registration
        return await login(email, password);
      }
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> toggleAvailableToHelp(bool value) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(availableToHelp: value);
    await _storage.saveAvailableToHelp(value);
    notifyListeners();

    if (value) {
      _locationSyncService.startPeriodicSync();
      EmergencyAlertListenerService().startListening(userId: _currentUser!.id);
    } else {
      _locationSyncService.stopPeriodicSync();
      EmergencyAlertListenerService().stopListening();
    }

    if (!AppConfig.demoMode) {
      try {
        await _apiClient.patch('/helpers/availability', body: {'available_to_help': value});
      } catch (_) {}
    }
  }

  Future<void> setServerHost(String host) async {
    AppConfig.customServerHost = host.trim();
    await _storage.saveServerHost(host.trim());
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _currentLocale = Locale(langCode);
    await _storage.saveLanguage(langCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final modeStr = mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.light ? 'light' : 'system');
    await _storage.saveThemeMode(modeStr);
    notifyListeners();
  }

  Future<void> logout() async {
    _locationSyncService.stopPeriodicSync();
    EmergencyAlertListenerService().stopListening();
    if (!AppConfig.demoMode) {
      try {
        await _apiClient.post('/auth/logout');
      } catch (_) {}
    }
    await _storage.clearTokens();
    _currentUser = null;
    notifyListeners();
  }
}

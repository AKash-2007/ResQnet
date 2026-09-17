import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/demo_service.dart';
import '../models/nearby_stats_model.dart';

class NearbyViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final LocationService _locationService;
  final DemoService _demoService;

  NearbyStatsModel? _stats;
  NearbyStatsModel? get stats => _stats;

  int _selectedRadius = 1000;
  int get selectedRadius => _selectedRadius;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NearbyViewModel({
    ApiClient? apiClient,
    LocationService? locationService,
    DemoService? demoService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _locationService = locationService ?? LocationService(),
        _demoService = demoService ?? DemoService() {
    loadNearbyStats();
  }

  Future<void> setRadius(int radiusMeters) async {
    _selectedRadius = radiusMeters;
    notifyListeners();
    await loadNearbyStats();
  }

  Future<void> loadNearbyStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      _stats = _demoService.getDemoNearbyStats(radiusMeters: _selectedRadius);
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final pos = await _locationService.getCurrentLocation();
      final lat = pos?.latitude ?? 12.9716;
      final lng = pos?.longitude ?? 77.5946;

      final res = await _apiClient.get(
        '/nearby/stats?latitude=$lat&longitude=$lng&radius_meters=$_selectedRadius',
      );

      if (res != null && res is Map<String, dynamic>) {
        _stats = NearbyStatsModel.fromJson(res);
      }
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

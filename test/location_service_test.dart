import 'package:flutter_test/flutter_test.dart';
import 'package:resqnet/core/services/location_service.dart';

void main() {
  group('LocationService Tests', () {
    final locationService = LocationService();

    test('formatDistance accurately formats meters and kilometers', () {
      expect(locationService.formatDistance(350), '350 m');
      expect(locationService.formatDistance(999), '999 m');
      expect(locationService.formatDistance(1000), '1.0 km');
      expect(locationService.formatDistance(1500), '1.5 km');
      expect(locationService.formatDistance(2340), '2.3 km');
    });

    test('calculateDistance calculates geodesic distance between coordinates', () {
      // Distance between Bangalore (12.9716, 77.5946) and Chennai (13.0827, 80.2707) is ~290 km
      final distance = locationService.calculateDistance(12.9716, 77.5946, 13.0827, 80.2707);
      expect(distance, greaterThan(280000));
      expect(distance, lessThan(310000));
    });

    test('calculateDistance between identical points is zero', () {
      final distance = locationService.calculateDistance(12.9716, 77.5946, 12.9716, 77.5946);
      expect(distance, 0.0);
    });
  });
}

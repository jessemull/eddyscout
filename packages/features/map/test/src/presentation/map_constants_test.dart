import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapRegionCenter averages curated launch coordinates', () {
    final center = mapRegionCenter();
    expect(kLaunchPoints, isNotEmpty);
    var lat = 0.0;
    var lon = 0.0;
    for (final p in kLaunchPoints) {
      lat += p.latitude;
      lon += p.longitude;
    }
    final n = kLaunchPoints.length;
    expect(center.coordinates.lat, closeTo(lat / n, 1e-9));
    expect(center.coordinates.lng, closeTo(lon / n, 1e-9));
  });
}

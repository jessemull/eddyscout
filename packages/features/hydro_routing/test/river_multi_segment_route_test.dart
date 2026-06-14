import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mergeRouteSegments', () {
    test('joins polylines and sums length', () {
      final merged = mergeRouteSegments([
        RouteResult.success(
              polylineLonLat: [
                [-122.6, 45.5],
                [-122.55, 45.52],
              ],
              lengthMeters: 1000,
            )
            as RouteSuccess,
        RouteResult.success(
              polylineLonLat: [
                [-122.55, 45.52],
                [-122.5, 45.54],
              ],
              lengthMeters: 2000,
            )
            as RouteSuccess,
      ]);

      expect(merged, isNotNull);
      expect(merged!.polylineLonLat, hasLength(3));
      expect(merged.lengthMeters, 3000);
    });
  });
}

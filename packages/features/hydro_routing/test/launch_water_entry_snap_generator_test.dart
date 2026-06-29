import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_water_entry_snap_generator.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LaunchWaterEntrySnapGenerator', () {
    test('reports snap distance for launch on graph', () {
      const json = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "test"},
      "geometry": {"type": "LineString", "coordinates": [[0, 0], [0, 0.01]]}
    }
  ]
}
''';
      final planner = RiverRoutePlanner.fromGeoJson(json);
      final launch = LaunchPoint(
        id: 'near',
        name: 'Near',
        latitude: 0.0,
        longitude: 0.0,
        shortNote: 'Test',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final rows = planner.generateLaunchWaterEntrySnaps([launch]);

      expect(rows, hasLength(1));
      expect(rows.single.launchId, 'near');
      expect(rows.single.snapMeters, lessThan(1));
      expect(rows.single.vertexIndex, isNotNull);
    });

    test('violations excludes allowlisted launches', () {
      final graph = RiverLineGraph.forTesting(
        lat: [45.0],
        lon: [-122.0],
        adj: [[]],
      );
      final launch = LaunchPoint(
        id: 'far',
        name: 'Far',
        latitude: 45.1,
        longitude: -122.0,
        shortNote: 'Test',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final violations = LaunchWaterEntrySnapGenerator.violations(
        graph: graph,
        catalog: [launch],
        allowlist: {'far'},
      );

      expect(violations, isEmpty);
    });
  });
}

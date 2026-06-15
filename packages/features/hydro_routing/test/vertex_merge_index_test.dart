import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/vertex_merge_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VertexMergeIndex', () {
    test('finds vertex in same cell within merge radius', () {
      final index = VertexMergeIndex(mergeMeters: 20, refLatitude: 45.0);
      final lat = [45.0];
      final lon = [-122.0];
      index.add(0, lat[0], lon[0]);

      expect(index.findExisting(lat, lon, 45.0, -122.0), 0);
      expect(
        index.findExisting(lat, lon, 45.00005, -122.00005),
        0,
      );
    });

    test('finds vertex in adjacent cell within merge radius', () {
      final index = VertexMergeIndex(mergeMeters: 15, refLatitude: 45.0);
      final lat = [45.0, 45.0];
      final lon = [-122.0, -122.0001];
      index.add(0, lat[0], lon[0]);
      index.add(1, lat[1], lon[1]);

      final mergedLon = -122.00005;
      expect(
        haversineMeters(lat[0], lon[0], lat[0], mergedLon),
        lessThanOrEqualTo(15),
      );
      expect(index.findExisting(lat, lon, lat[0], mergedLon), 0);
    });

    test('does not match beyond merge radius', () {
      final index = VertexMergeIndex(mergeMeters: 5, refLatitude: 45.0);
      final lat = [45.0];
      final lon = [-122.0];
      index.add(0, lat[0], lon[0]);

      expect(index.findExisting(lat, lon, 45.01, -122.0), isNull);
    });

    test('returns lowest index when multiple vertices match', () {
      final index = VertexMergeIndex(mergeMeters: 500, refLatitude: 45.0);
      final lat = [45.0, 45.0, 45.0];
      final lon = [-122.0, -122.0, -122.0];
      index.add(0, lat[0], lon[0]);
      index.add(1, lat[1], lon[1]);
      index.add(2, lat[2], lon[2]);

      expect(index.findExisting(lat, lon, 45.0, -122.0), 0);
    });
  });
}

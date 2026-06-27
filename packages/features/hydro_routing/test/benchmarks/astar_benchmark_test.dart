@Tags(['benchmark'])
library;

import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph_binary_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dijkstra_reference.dart';
import '../helpers/synthetic_grid_features.dart';
import '../helpers/synthetic_grid_graph.dart';

void main() {
  group('A* benchmarks', () {
    test(
      'full route computation (snap + anchors) under 200 ms at 50k nodes',
      () {
        final graph = buildSyntheticGridGraph(50000);
        expect(graph.vertexCount, greaterThanOrEqualTo(49000));

        final last = graph.vertexCount - 1;
        final sw = Stopwatch()..start();
        final result = graph.route(
          graph.latitudeAt(0),
          graph.longitudeAt(0),
          graph.latitudeAt(last),
          graph.longitudeAt(last),
          maxSnapMeters: 50000,
        );
        sw.stop();

        expect(result, isA<RouteSuccess>());
        expect(sw.elapsedMilliseconds, lessThan(200));
      },
    );

    test('A* core pathfinding under 200 ms at 50k nodes', () {
      final graph = buildSyntheticGridGraph(50000);
      expect(graph.vertexCount, greaterThanOrEqualTo(49000));

      final last = graph.vertexCount - 1;
      final sw = Stopwatch()..start();
      final path = graph.astarForTesting(0, last);
      sw.stop();

      expect(path, isNotNull);
      expect(sw.elapsedMilliseconds, lessThan(200));
    });

    test('route computation scales at 5k and 20k nodes', () {
      for (final target in [5000, 20000]) {
        final graph = buildSyntheticGridGraph(target);
        final last = graph.vertexCount - 1;
        expect(dijkstraReference(graph, 0, last), isNotNull);
        final sw = Stopwatch()..start();
        final result = graph.route(
          graph.latitudeAt(0),
          graph.longitudeAt(0),
          graph.latitudeAt(last),
          graph.longitudeAt(last),
          maxSnapMeters: 50000,
        );
        sw.stop();
        expect(result, isA<RouteSuccess>());
        expect(sw.elapsedMilliseconds, lessThan(200));
      }
    });

    test('graph build from features under 1 s at 50k nodes', () {
      final features = buildSyntheticGridFeatures(50000);
      final sw = Stopwatch()..start();
      final graph = RiverLineGraph.fromFeatures(
        features,
        riverSystemName: 'bench',
      );
      sw.stop();

      expect(graph.vertexCount, greaterThanOrEqualTo(49000));
      expect(sw.elapsedMilliseconds, lessThan(1000));
    });

    test('binary decode cold load under 500 ms at 50k nodes', () {
      final graph = buildSyntheticGridGraph(50000);
      final bytes = encodeRiverLineGraph(graph);
      final sw = Stopwatch()..start();
      final decoded = RiverLineGraph.fromBinary(bytes);
      sw.stop();

      expect(decoded.vertexCount, graph.vertexCount);
      expect(sw.elapsedMilliseconds, lessThan(500));
    });

    test('indexed snap under 200 ms for 1000 queries at 50k nodes', () {
      final graph = buildSyntheticGridGraph(50000);
      final sw = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        graph.nearestSnapIndexedForTesting(
          graph.latitudeAt(i % graph.vertexCount),
          graph.longitudeAt(i % graph.vertexCount),
          900,
        );
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(200));
    });
  });
}

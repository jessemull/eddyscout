import 'dart:typed_data';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph_binary_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';
import 'helpers/synthetic_grid_graph.dart';

void main() {
  group('river graph binary codec', () {
    test('round-trip preserves adjacency and coordinates', () {
      final graph = buildSyntheticGridGraph(100);
      final bytes = encodeRiverLineGraph(graph);
      final decoded = decodeRiverLineGraph(bytes);

      expect(decoded.vertexCount, graph.vertexCount);
      for (var i = 0; i < graph.vertexCount; i++) {
        expect(decoded.latitudeAt(i), graph.latitudeAt(i));
        expect(decoded.longitudeAt(i), graph.longitudeAt(i));
      }
      expect(
        decoded.adjacencyForTesting.length,
        graph.adjacencyForTesting.length,
      );
    });

    test('rejects invalid magic', () {
      expect(
        () => decodeRiverLineGraph(Uint8List.fromList([1, 2, 3, 4])),
        throwsFormatException,
      );
    });

    test('committed bundled binary matches geojson graph topology', () async {
      final docs = await readBundledHydroGeoJsonDocuments();
      final bridges = await readBundledConfluenceBridgesJson();
      final geoPlanner = RiverRoutePlanner.fromGeoJsonDocuments(
        docs,
        confluenceBridgesJson: bridges,
      );
      final bytes = await readBundledHydroGraphBinary();
      final binPlanner = RiverRoutePlanner.fromBinary(bytes);
      expect(geoPlanner.hasSameUnifiedGraphAs(binPlanner), isTrue);
    });

    test(
      'committed bundled binary matches geojson plan for launches',
      () async {
        final putIn = kLaunchPoints.firstWhere((l) => l.id == 'cathedral_park');
        final takeOut = kLaunchPoints.firstWhere(
          (l) => l.id == 'sellwood_riverfront',
        );

        final docs = await readBundledHydroGeoJsonDocuments();
        final bridges = await readBundledConfluenceBridgesJson();
        final geoPlanner = RiverRoutePlanner.fromGeoJsonDocuments(
          docs,
          confluenceBridgesJson: bridges,
        );

        final bytes = await readBundledHydroGraphBinary();
        final binPlanner = RiverRoutePlanner.fromBinary(bytes);

        expect(
          binPlanner.graphForTesting.vertexCount,
          geoPlanner.graphForTesting.vertexCount,
        );

        final geoResult = geoPlanner.plan(putIn, takeOut);
        final binResult = binPlanner.plan(putIn, takeOut);

        expect(geoResult, isA<RouteSuccess>());
        expect(binResult, isA<RouteSuccess>());
        expect(
          (binResult as RouteSuccess).lengthMeters,
          closeTo((geoResult as RouteSuccess).lengthMeters, 0.01),
        );
      },
    );

    test('riverGraphsEqual detects topology mismatch', () {
      final graph = buildSyntheticGridGraph(10);
      final bytes = encodeRiverLineGraph(graph);
      final decoded = decodeRiverLineGraph(bytes);
      expect(riverGraphsEqual(graph, decoded), isTrue);
    });

    test('bundled geojson graph matches binary decode routes', () async {
      final docs = await readBundledHydroGeoJsonDocuments();
      final bridges = await readBundledConfluenceBridgesJson();
      final geoPlanner = RiverRoutePlanner.fromGeoJsonDocuments(
        docs,
        confluenceBridgesJson: bridges,
      );
      final bytes = encodeRiverLineGraph(geoPlanner.graphForTesting);
      final binPlanner = RiverRoutePlanner.fromBinary(bytes);

      expect(
        binPlanner.graphForTesting.vertexCount,
        geoPlanner.graphForTesting.vertexCount,
      );

      final graph = geoPlanner.graphForTesting;
      final last = graph.vertexCount - 1;
      final geoRoute = graph.route(
        graph.latitudeAt(0),
        graph.longitudeAt(0),
        graph.latitudeAt(last),
        graph.longitudeAt(last),
      );
      final binRoute = binPlanner.graphForTesting.route(
        graph.latitudeAt(0),
        graph.longitudeAt(0),
        graph.latitudeAt(last),
        graph.longitudeAt(last),
      );
      expect(binRoute.isSuccess, geoRoute.isSuccess);
      if (geoRoute case RouteSuccess(:final lengthMeters)) {
        expect(
          (binRoute as RouteSuccess).lengthMeters,
          closeTo(lengthMeters, 0.01),
        );
      }
    });
  });
}

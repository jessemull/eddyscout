import 'dart:typed_data';

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

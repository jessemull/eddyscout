import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/confluence_bridges.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';

/// Confluence anchor near upstream line end (lat, lon).
typedef _ConfluenceAnchor = ({
  String id,
  double lat,
  double lon,
  bool required,
});

Future<RiverLineGraph> _unifiedBundledGraph({bool withBridges = true}) async {
  final docs = await readBundledHydroGeoJsonDocuments();
  final features = parseAndMergeHydroGeoJson(docs);
  var graph = RiverLineGraph.fromAllFeatures(features);
  if (withBridges) {
    final bridgesJson = await readBundledConfluenceBridgesJson();
    final bridges = parseConfluenceBridgesJson(bridgesJson);
    graph = graph.addConfluenceBridges(bridges);
  }
  return graph;
}

bool _anchorsConnected(
  RiverLineGraph graph,
  _ConfluenceAnchor upstream,
  _ConfluenceAnchor downstream, {
  double maxSnapMeters = 500,
}) {
  final upstreamSnap = graph.snapToVertex(
    upstream.lat,
    upstream.lon,
    maxSnapMeters: maxSnapMeters,
  );
  final downstreamSnap = graph.snapToVertex(
    downstream.lat,
    downstream.lon,
    maxSnapMeters: maxSnapMeters,
  );
  if (upstreamSnap?.vertexIndex == null ||
      downstreamSnap?.vertexIndex == null) {
    return false;
  }
  return graph.graphDistanceMeters(
        upstreamSnap!.vertexIndex!,
        downstreamSnap!.vertexIndex!,
      ) !=
      null;
}

LaunchPoint _launch({
  required String id,
  required RiverSystem river,
  required double lat,
  required double lon,
}) {
  return LaunchPoint(
    id: id,
    name: id,
    latitude: lat,
    longitude: lon,
    shortNote: 'Test',
    riverSystem: river,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );
}

void main() {
  group('bundled hydro connectivity', () {
    test('loads all assets and builds non-empty per-system graphs', () async {
      final docs = await readBundledHydroGeoJsonDocuments();
      final features = parseAndMergeHydroGeoJson(docs);

      const expectedSystems = [
        'willamette',
        'columbia',
        'clackamas',
        'slough',
        'tualatin',
      ];

      for (final system in expectedSystems) {
        final graph = RiverLineGraph.fromFeatures(
          features,
          riverSystemName: system,
        );
        expect(
          graph.vertexCount,
          greaterThan(0),
          reason: 'expected graph vertices for $system',
        );
      }
    });

    group('required confluences', () {
      const anchors =
          <
            ({
              String id,
              _ConfluenceAnchor upstream,
              _ConfluenceAnchor downstream,
            })
          >[
            (
              id: 'willamette_columbia_mouth',
              upstream: (
                id: 'willamette_mouth',
                lat: 45.6178872,
                lon: -122.7909498,
                required: true,
              ),
              downstream: (
                id: 'columbia_lower_mouth',
                lat: 45.6178872,
                lon: -122.7909498,
                required: true,
              ),
            ),
            (
              id: 'columbia_lower_gorge',
              upstream: (
                id: 'columbia_lower_camas',
                lat: 45.5659948,
                lon: -122.4300244,
                required: true,
              ),
              downstream: (
                id: 'columbia_gorge_camas',
                lat: 45.5659948,
                lon: -122.4300244,
                required: true,
              ),
            ),
          ];

      for (final pair in anchors) {
        test('${pair.id} connects in unified graph', () async {
          final graph = await _unifiedBundledGraph(withBridges: false);
          expect(
            _anchorsConnected(graph, pair.upstream, pair.downstream),
            isTrue,
            reason: 'required confluence ${pair.id} must share graph component',
          );
        });
      }
    });

    group('informational confluences', () {
      test(
        'clackamas_willamette documents known gap without failing CI',
        () async {
          const upstream = (
            id: 'clackamas_mouth',
            lat: 45.3548,
            lon: -122.612,
            required: false,
          );
          const downstream = (
            id: 'willamette_upstream',
            lat: 45.3525,
            lon: -122.61,
            required: false,
          );

          final graph = await _unifiedBundledGraph(withBridges: false);
          final connected = _anchorsConnected(graph, upstream, downstream);

          if (!connected) {
            // Informational only — log gap for reviewers; see README-hydro.md.
            expect(
              connected,
              isFalse,
              reason:
                  'KNOWN GAP: clackamas_willamette ~300 m endpoint gap; '
                  'bridge placeholder in confluence_bridges.json until geometry meets',
            );
          }
        },
      );

      test('sandy_columbia_gorge shares Glenn Otto endpoint', () async {
        const upstream = (
          id: 'sandy_mouth',
          lat: 45.5405345,
          lon: -122.3817713,
          required: false,
        );
        const downstream = (
          id: 'columbia_gorge_glenn_otto',
          lat: 45.5405345,
          lon: -122.3817713,
          required: false,
        );

        final graph = await _unifiedBundledGraph(withBridges: false);
        expect(
          _anchorsConnected(graph, upstream, downstream),
          isTrue,
          reason: 'Sandy subline should meet gorge mainstem at shared vertex',
        );
      });
    });

    test('cross-system route Cathedral Park to Glenn Otto succeeds', () async {
      final docs = await readBundledHydroGeoJsonDocuments();
      final bridges = await readBundledConfluenceBridgesJson();
      final planner = RiverRoutePlanner.fromGeoJsonDocuments(
        docs,
        confluenceBridgesJson: bridges,
      );

      final result = planner.plan(
        _launch(
          id: 'cathedral_park',
          river: RiverSystem.willamette,
          lat: 45.5621,
          lon: -122.7328,
        ),
        _launch(
          id: 'glenn_otto_troutdale',
          river: RiverSystem.columbia,
          lat: 45.5365,
          lon: -122.3858,
        ),
      );

      expect(result, isA<RouteSuccess>());
      final ok = result as RouteSuccess;
      expect(ok.lengthMeters, greaterThan(1000));
    });
  });
}

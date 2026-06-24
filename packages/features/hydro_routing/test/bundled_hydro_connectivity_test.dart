import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/confluence_bridges.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/bundled_hydro_assets.dart';

/// Matches [RiverLineGraph] default merge threshold and geometry CI gate.
const _kConfluenceMergeSnapMeters = 12.0;

/// Confluence anchor near line endpoint (lat, lon).
typedef _ConfluenceAnchor = ({
  String id,
  double lat,
  double lon,
});

_ConfluenceAnchor _anchorFromJson(
  String id,
  List<dynamic> lonLat,
) {
  return (
    id: id,
    lat: (lonLat[1] as num).toDouble(),
    lon: (lonLat[0] as num).toDouble(),
  );
}

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
  double maxSnapMeters = _kConfluenceMergeSnapMeters,
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
  final upstreamIndex = upstreamSnap?.vertexIndex;
  final downstreamIndex = downstreamSnap?.vertexIndex;
  if (upstreamIndex == null || downstreamIndex == null) {
    return false;
  }
  return graph.graphDistanceMeters(upstreamIndex, downstreamIndex) != null;
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
      test('all required pairs connect in unified graph', () async {
        final auditPairs = await readConfluenceAuditPairs();
        final requiredPairs = auditPairs.where(
          (pair) => pair['required'] == true,
        );

        final graph = await _unifiedBundledGraph(withBridges: false);
        for (final pair in requiredPairs) {
          final id = pair['id'] as String;
          final upstream = _anchorFromJson(
            '${id}_upstream',
            pair['upstream_anchor'] as List<dynamic>,
          );
          final downstream = _anchorFromJson(
            '${id}_downstream',
            pair['downstream_anchor'] as List<dynamic>,
          );
          expect(
            _anchorsConnected(graph, upstream, downstream),
            isTrue,
            reason: 'required confluence $id must share graph component',
          );
        }
      });
    });

    group('informational confluences', () {
      test(
        'clackamas_willamette has known endpoint gap',
        () async {
          final auditPairs = await readConfluenceAuditPairs();
          final pair = auditPairs.firstWhere(
            (row) => row['id'] == 'clackamas_willamette',
          );
          final upstream = _anchorFromJson(
            'clackamas_mouth',
            pair['upstream_anchor'] as List<dynamic>,
          );
          final downstream = _anchorFromJson(
            'willamette_upstream',
            pair['downstream_anchor'] as List<dynamic>,
          );

          final graph = await _unifiedBundledGraph(withBridges: false);
          expect(
            _anchorsConnected(graph, upstream, downstream),
            isFalse,
            reason:
                'KNOWN GAP: clackamas_willamette ~300 m endpoint gap; '
                'bridge placeholder in confluence_bridges.json until geometry meets',
          );
        },
      );

      test('sandy_columbia_gorge shares Glenn Otto endpoint', () async {
        final auditPairs = await readConfluenceAuditPairs();
        final pair = auditPairs.firstWhere(
          (row) => row['id'] == 'sandy_columbia_gorge',
        );
        final upstream = _anchorFromJson(
          'sandy_mouth',
          pair['upstream_anchor'] as List<dynamic>,
        );
        final downstream = _anchorFromJson(
          'columbia_gorge_glenn_otto',
          pair['downstream_anchor'] as List<dynamic>,
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

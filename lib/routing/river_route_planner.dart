import 'package:flutter/services.dart';

import '../data/launch_models.dart';
import '../debug/map_debug_log.dart';
import 'river_geojson.dart';
import 'river_graph.dart';
import 'route_result.dart';

/// Loads bundled hydro GeoJSON and plans routes between launches.
class RiverRoutePlanner {
  RiverRoutePlanner._(this._graphsByRiver);

  final Map<String, RiverLineGraph> _graphsByRiver;

  /// Loads `assets/hydro/willamette_waterway.geojson` and builds per-river graphs.
  static Future<RiverRoutePlanner> load() async {
    final raw = await rootBundle.loadString('assets/hydro/willamette_waterway.geojson');
    final features = parseHydroGeoJson(raw);
    final graphs = <String, RiverLineGraph>{};
    final systems = <String>{};
    for (final f in features) {
      if (f.riverSystemKey != null) {
        systems.add(f.riverSystemKey!);
      }
    }
    for (final name in systems) {
      final g = RiverLineGraph.fromFeatures(features, riverSystemName: name);
      if (g.vertexCount > 0) {
        graphs[name] = g;
      }
    }
    mapDebugLog(
      'RiverRoutePlanner.load: graphCount=${graphs.length} keys=${graphs.keys.toList()}',
    );
    for (final e in graphs.entries) {
      mapDebugLog('  river "${e.key}" vertexCount=${e.value.vertexCount}');
    }
    return RiverRoutePlanner._(graphs);
  }

  RouteResult plan(LaunchPoint putIn, LaunchPoint takeOut) {
    if (putIn.id == takeOut.id) {
      return const RouteFailure('Choose two different launches.');
    }
    if (putIn.riverSystem != takeOut.riverSystem) {
      return const RouteFailure(
        'Pick two launches on the same river system for river routing.',
      );
    }
    final key = putIn.riverSystem.name;
    final graph = _graphsByRiver[key];
    if (graph == null) {
      return RouteFailure(
        'No bundled river line for "${putIn.riverSystem.name}" yet — routing is only available where hydro GeoJSON exists.',
      );
    }
    return graph.route(
      putIn.latitude,
      putIn.longitude,
      takeOut.latitude,
      takeOut.longitude,
    );
  }
}

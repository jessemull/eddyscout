import 'package:eddyscout_core/eddyscout_core.dart';

import 'package:eddyscout_hydro_routing/src/data/hydro_debug_log.dart';
import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';

/// Loads bundled hydro GeoJSON and plans routes between launches.
class RiverRoutePlanner {
  /// Builds graphs from raw GeoJSON text (asset loaded by the app shell).
  factory RiverRoutePlanner.fromGeoJson(String raw) {
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
    hydroDebugLog(
      'RiverRoutePlanner.fromGeoJson: graphCount=${graphs.length} '
      'keys=${graphs.keys.toList()}',
    );
    for (final e in graphs.entries) {
      hydroDebugLog('  river "${e.key}" vertexCount=${e.value.vertexCount}');
    }
    return RiverRoutePlanner._(graphs);
  }

  RiverRoutePlanner._(this._graphsByRiver);

  final Map<String, RiverLineGraph> _graphsByRiver;

  /// Plans a river-line path between [putIn] and [takeOut] on the same system.
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
        'No bundled river line for "${putIn.riverSystem.name}" yet — '
        'routing is only available where hydro GeoJSON exists.',
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

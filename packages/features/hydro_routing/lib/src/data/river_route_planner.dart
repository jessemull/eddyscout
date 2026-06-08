import 'package:eddyscout_core/eddyscout_core.dart';

import 'package:eddyscout_hydro_routing/src/data/hydro_debug_log.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_geojson_merge.dart';
import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:eddyscout_hydro_routing/src/domain/planned_route.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';

/// Loads bundled hydro GeoJSON and plans routes between launches.
class RiverRoutePlanner {
  /// Builds graphs from raw GeoJSON text (single bundled document).
  factory RiverRoutePlanner.fromGeoJson(String raw) {
    return RiverRoutePlanner.fromGeoJsonDocuments([raw]);
  }

  /// Builds graphs from one or more bundled GeoJSON documents.
  factory RiverRoutePlanner.fromGeoJsonDocuments(List<String> rawDocs) {
    final features = parseAndMergeHydroGeoJson(rawDocs);
    return RiverRoutePlanner._fromFeatures(features);
  }

  /// Builds graphs from parsed hydro line features.
  factory RiverRoutePlanner._fromFeatures(List<HydroLineFeature> features) {
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
      return const RouteFailure(code: RouteFailureCode.sameLaunch);
    }
    if (putIn.riverSystem != takeOut.riverSystem) {
      return const RouteFailure(code: RouteFailureCode.differentSystem);
    }
    final key = putIn.riverSystem.name;
    final graph = _graphsByRiver[key];
    if (graph == null) {
      return RouteFailure(
        code: RouteFailureCode.noBundledLine,
        riverSystemName: putIn.riverSystem.name,
      );
    }
    return graph.route(
      putIn.latitude,
      putIn.longitude,
      takeOut.latitude,
      takeOut.longitude,
    );
  }

  /// Plans once and returns both [RouteResult] and optional [PlannedRoute].
  ({RouteResult result, PlannedRoute? planned}) planLaunches(
    LaunchPoint putIn,
    LaunchPoint takeOut,
  ) {
    final result = plan(putIn, takeOut);
    return (
      result: result,
      planned: _plannedRouteFromSuccess(result, putIn, takeOut),
    );
  }

  /// Returns a stable [PlannedRoute] on success, or null on routing failure.
  PlannedRoute? planRoute(LaunchPoint putIn, LaunchPoint takeOut) {
    return planLaunches(putIn, takeOut).planned;
  }

  PlannedRoute? _plannedRouteFromSuccess(
    RouteResult result,
    LaunchPoint putIn,
    LaunchPoint takeOut,
  ) {
    if (result is! RouteSuccess) {
      return null;
    }
    return PlannedRoute(
      putInLaunchId: putIn.id,
      takeOutLaunchId: takeOut.id,
      riverSystem: putIn.riverSystem,
      polylineLonLat: result.polylineLonLat,
      lengthMeters: result.lengthMeters,
      reachId: result.reachId,
    );
  }
}

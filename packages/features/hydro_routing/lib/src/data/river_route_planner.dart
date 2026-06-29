import 'dart:typed_data';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/confluence_bridges.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_debug_log.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_geojson_merge.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_water_entry_snap_generator.dart';
import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph_binary_codec.dart';
import 'package:eddyscout_hydro_routing/src/domain/planned_route_hydro.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';
import 'package:meta/meta.dart';

/// Loads bundled hydro GeoJSON and plans routes between launches.
class RiverRoutePlanner {
  /// Builds a planner from raw GeoJSON text (single bundled document).
  factory RiverRoutePlanner.fromGeoJson(
    String raw, {
    double mergeVertexMeters = 12,
    String? confluenceBridgesJson,
  }) {
    return RiverRoutePlanner.fromGeoJsonDocuments(
      [raw],
      mergeVertexMeters: mergeVertexMeters,
      confluenceBridgesJson: confluenceBridgesJson,
    );
  }

  /// Builds a planner from one or more bundled GeoJSON documents.
  factory RiverRoutePlanner.fromGeoJsonDocuments(
    List<String> rawDocs, {
    double mergeVertexMeters = 12,
    String? confluenceBridgesJson,
  }) {
    final features = parseAndMergeHydroGeoJson(rawDocs);
    final bridges = parseConfluenceBridgesJson(confluenceBridgesJson);
    return RiverRoutePlanner._fromFeatures(
      features,
      mergeVertexMeters: mergeVertexMeters,
      confluenceBridges: bridges,
    );
  }

  /// Builds a planner from parsed hydro line features.
  factory RiverRoutePlanner._fromFeatures(
    List<HydroLineFeature> features, {
    double mergeVertexMeters = 12,
    List<ConfluenceBridge> confluenceBridges = const [],
  }) {
    var graph = RiverLineGraph.fromAllFeatures(
      features,
      mergeVertexMeters: mergeVertexMeters,
    );
    graph = graph.addConfluenceBridges(confluenceBridges);
    hydroDebugLog(
      'RiverRoutePlanner.fromGeoJson: unified vertexCount=${graph.vertexCount} '
      'bridgeCount=${confluenceBridges.length}',
    );
    return RiverRoutePlanner._(graph);
  }

  /// Builds a planner from precomputed binary graph bytes.
  ///
  /// Confluence bridges must already be baked into the binary asset.
  factory RiverRoutePlanner.fromBinary(Uint8List bytes) {
    final graph = RiverLineGraph.fromBinary(bytes);
    hydroDebugLog(
      'RiverRoutePlanner.fromBinary: vertexCount=${graph.vertexCount}',
    );
    return RiverRoutePlanner._(graph);
  }

  RiverRoutePlanner._(this._graph);

  final RiverLineGraph _graph;

  /// Returns a failure when [launch] does not snap to bundled geometry.
  RouteFailure? validateLaunchSnap(LaunchPoint launch) {
    return validateCoordinateSnap(
      launch.routingLatitude,
      launch.routingLongitude,
    );
  }

  /// Returns a failure when raw coordinates do not snap to bundled geometry.
  RouteFailure? validateCoordinateSnap(double lat, double lon) {
    final result = _graph.route(lat, lon, lat, lon);
    if (result is RouteFailure) {
      if (result.code == RouteFailureCode.takeOutTooFar) {
        return const RouteFailure(code: RouteFailureCode.putInTooFar);
      }
      return result;
    }
    return null;
  }

  /// Returns a failure when no route exists between [from] and [to].
  RouteFailure? validateSegment(LaunchPoint from, LaunchPoint to) {
    final result = plan(from, to);
    return result is RouteFailure ? result : null;
  }

  /// Returns a failure when [stop] does not snap to bundled geometry.
  RouteFailure? validateStop(RoutePlanningStop stop) {
    return validateCoordinateSnap(stop.routingLatitude, stop.routingLongitude);
  }

  /// Returns a failure when [from] and [to] cannot be routed together.
  RouteFailure? validateSegmentStops(
    RoutePlanningStop from,
    RoutePlanningStop to,
  ) {
    if (from.sameStopAs(to)) {
      return const RouteFailure(code: RouteFailureCode.sameLaunch);
    }
    final result = planBetween(
      from.routingLatitude,
      from.routingLongitude,
      to.routingLatitude,
      to.routingLongitude,
    );
    return result is RouteFailure ? result : null;
  }

  /// Snaps [lat]/[lon] to the nearest bundled hydro geometry point.
  WaterwaySnapPoint? snapToWaterway(
    double lat,
    double lon, {
    double maxSnapMeters = 900,
  }) {
    final snap = _graph.nearestSnapResult(
      lat,
      lon,
      maxSnapMeters: maxSnapMeters,
    );
    if (snap == null) {
      return null;
    }
    return WaterwaySnapPoint(
      latitude: snap.lat,
      longitude: snap.lon,
      distanceMeters: snap.distanceMeters,
      reachId: snap.reachId,
    );
  }

  /// Underlying graph for tests and offline encoders.
  @visibleForTesting
  RiverLineGraph get graphForTesting => _graph;

  /// Vertex count in the unified routing graph.
  int get unifiedGraphVertexCount => _graph.vertexCount;

  /// Serializes the unified graph for bundled binary assets.
  Uint8List encodeUnifiedGraphBinary({
    RiverGraphBinaryMetadata metadata = const RiverGraphBinaryMetadata(),
  }) => encodeRiverLineGraph(_graph, metadata: metadata);

  /// Whether [other] was built from the same unified graph topology.
  bool hasSameUnifiedGraphAs(RiverRoutePlanner other) =>
      riverGraphsEqual(_graph, other._graph);

  /// Build-time water-entry snap rows for [catalog] launches.
  List<LaunchWaterEntrySnapRow> generateLaunchWaterEntrySnaps(
    List<LaunchPoint> catalog,
  ) => LaunchWaterEntrySnapGenerator.generate(graph: _graph, catalog: catalog);

  /// Returns launches exceeding the water-entry snap threshold.
  List<LaunchWaterEntrySnapRow> launchWaterEntrySnapViolations({
    required List<LaunchPoint> catalog,
    Set<String> allowlist = const {},
    double maxSnapMeters = kLaunchWaterEntrySnapMaxMeters,
    bool waterEntryOnly = false,
  }) => LaunchWaterEntrySnapGenerator.violations(
    graph: _graph,
    catalog: catalog,
    allowlist: allowlist,
    maxSnapMeters: maxSnapMeters,
    waterEntryOnly: waterEntryOnly,
  );

  /// Plans a river-line path between [putIn] and [takeOut].
  RouteResult plan(LaunchPoint putIn, LaunchPoint takeOut) {
    if (putIn.id == takeOut.id) {
      return const RouteFailure(code: RouteFailureCode.sameLaunch);
    }
    return planBetween(
      putIn.routingLatitude,
      putIn.routingLongitude,
      takeOut.routingLatitude,
      takeOut.routingLongitude,
      putIn: putIn,
      takeOut: takeOut,
    );
  }

  /// Plans a river-line path between two coordinate pairs.
  RouteResult planBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    LaunchPoint? putIn,
    LaunchPoint? takeOut,
  }) {
    if (lat1 == lat2 && lon1 == lon2) {
      return const RouteFailure(code: RouteFailureCode.sameLaunch);
    }
    if (_graph.vertexCount == 0) {
      return const RouteFailure(code: RouteFailureCode.noRiverGeometryLoaded);
    }

    final result = _graph.route(lat1, lon1, lat2, lon2);

    if (result is! RouteFailure) {
      return result;
    }

    if (putIn == null || takeOut == null) {
      return result;
    }

    return _mapDisconnectFailure(
      result,
      putIn: putIn,
      takeOut: takeOut,
    );
  }

  /// Plans all consecutive [stops] and returns segment successes.
  Result<List<RouteSuccess>, RouteFailure> planStops(
    List<RoutePlanningStop> stops,
  ) {
    if (stops.length < 2) {
      return const Result.failure(
        RouteFailure(code: RouteFailureCode.sameLaunch),
      );
    }
    final successes = <RouteSuccess>[];
    for (var i = 0; i < stops.length - 1; i++) {
      final from = stops[i];
      final to = stops[i + 1];
      if (from.sameStopAs(to)) {
        return const Result.failure(
          RouteFailure(code: RouteFailureCode.sameLaunch),
        );
      }
      final result = planBetween(
        from.routingLatitude,
        from.routingLongitude,
        to.routingLatitude,
        to.routingLongitude,
        putIn: from.catalogLaunch,
        takeOut: to.catalogLaunch,
      );
      if (result case final RouteFailure failure) {
        return Result.failure(failure);
      }
      successes.add(result as RouteSuccess);
    }
    return Result.success(successes);
  }

  RouteFailure _mapDisconnectFailure(
    RouteFailure failure, {
    required LaunchPoint putIn,
    required LaunchPoint takeOut,
  }) {
    if (putIn.riverSystem == takeOut.riverSystem) {
      return failure;
    }

    return switch (failure.code) {
      RouteFailureCode.disconnectedReach ||
      RouteFailureCode.noConnectedPath => RouteFailure(
        code: RouteFailureCode.differentSystem,
        putInReachId: failure.putInReachId,
        takeOutReachId: failure.takeOutReachId,
      ),
      _ => failure,
    };
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
    return plannedRouteFromRouteSuccess(
      result,
      putIn: putIn,
      takeOut: takeOut,
    );
  }
}

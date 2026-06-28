import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Hydro-backed [MapRoutePlanner] for widget tests that exercise live routing.
final class TestHydroMapRoutePlanner implements MapRoutePlanner {
  const TestHydroMapRoutePlanner(this._ref);

  final Ref _ref;

  @override
  Future<Result<WaterwaySnapPoint, RoutePlanningFailure>> snapToWaterway(
    double latitude,
    double longitude,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final snap = planner.snapToWaterway(latitude, longitude);
    if (snap == null) {
      return const Result.failure(
        RoutePlanningFailure(code: RouteFailureCode.putInTooFar),
      );
    }
    return Result.success(snap);
  }

  @override
  Future<Result<RouteGeometrySnapshot?, RoutePlanningFailure>> planMultiSegment(
    List<RoutePlanningStop> stops,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final planResult = planMultiSegmentStops(planner, stops);
    return switch (planResult) {
      Success(:final value) => Result.success(mergeRouteSegments(value)),
      Failure(:final error) => Result.failure(
        routePlanningFailureFrom(error),
      ),
    };
  }

  @override
  Future<Result<void, RoutePlanningFailure>> validateStop(
    RoutePlanningStop stop,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final failure = planner.validateStop(stop);
    if (failure != null) {
      return Result.failure(routePlanningFailureFrom(failure));
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void, RoutePlanningFailure>> validateSegmentStops(
    RoutePlanningStop from,
    RoutePlanningStop to,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final failure = planner.validateSegmentStops(from, to);
    if (failure != null) {
      return Result.failure(routePlanningFailureFrom(failure));
    }
    return const Result.success(null);
  }
}

/// Wires [mapRoutePlannerProvider] to hydro for tests that load bundled graphs.
Override testHydroMapRoutePlannerOverride() {
  return mapRoutePlannerProvider.overrideWith((ref) async {
    await ref.read(riverRoutePlannerProvider.future);
    return TestHydroMapRoutePlanner(ref);
  });
}

/// Wires [mapGpxServiceProvider] to hydro for GPX import/export widget tests.
Override testHydroMapGpxServiceOverride() {
  return mapGpxServiceProvider.overrideWith(
    (ref) async => const TestHydroMapGpxService(),
  );
}

/// Hydro-backed [MapGpxService] for map widget tests.
final class TestHydroMapGpxService implements MapGpxService {
  const TestHydroMapGpxService();

  @override
  Result<String, GpxFailure> serialize(PlannedRoute route) =>
      GpxCodec.serialize(route);

  @override
  Result<PlannedRoute, GpxFailure> parse(String gpxXml) =>
      GpxCodec.parse(gpxXml);

  @override
  PlannedRoute snapLaunchEndpoints({
    required PlannedRoute route,
    required List<LaunchPoint> catalog,
  }) => LaunchEndpointSnapper.snapEndpoints(route: route, catalog: catalog);

  @override
  bool isEntirelyOutsidePnw(List<GpxPoint> points) =>
      GpxBounds.isEntirelyOutsidePnw(points);
}

/// Standard hydro-backed map provider overrides for routing snackbar tests.
List<Override> testHydroMapProviderOverrides({
  required HydroGeoJsonLoader hydroLoader,
}) {
  return [
    hydroGeoJsonLoaderProvider.overrideWithValue(hydroLoader),
    testHydroMapRoutePlannerOverride(),
    testHydroMapGpxServiceOverride(),
  ];
}

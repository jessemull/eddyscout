import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../launch_lookup.dart';
import '../map_planning_provider.dart';
import 'map_debug_log.dart';
import 'mapbox_map_camera_mixin.dart';
import 'mapbox_map_controller_shared.dart';
import 'mapbox_map_markers_mixin.dart';
import 'mapbox_map_route_mixin.dart';
import 'mapbox_map_style_mixin.dart';

part 'mapbox_map_controller.g.dart';

/// Owns Mapbox map lifecycle: markers, route line, camera, and launch taps.
@Riverpod(keepAlive: true)
final class MapboxMapController extends _$MapboxMapController
    with
        MapboxMapControllerBase,
        MapboxMapStyleMixin,
        MapboxMapRouteMixin,
        MapboxMapCameraMixin,
        MapboxMapMarkersMixin {
  @override
  Ref get mapControllerRef => ref;

  @override
  void build() {
    alive = true;
    ref
      ..onDispose(() {
        alive = false;
        tapCancelable?.cancel();
      })
      ..listen(riverRoutePlannerProvider, (previous, next) {
        final planning = ref.read(routePlanningProvider);
        if (planning.waypoints.length < 2) {
          return;
        }
        final wasPending = previous == null || !previous.hasValue;
        if (wasPending && next.hasValue) {
          unawaited(_runRoute());
        }
      });
  }

  Future<void> onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    mapDebugLog('onMapCreated (initial camera from MapWidget viewport)');
    await mapDebugLogMapboxSnapshot(
      mapboxMap,
      'onMapCreated',
      includeGestures: true,
    );
  }

  void onStyleLoaded() {
    if (!mapDiagnosticsLogged) {
      mapDiagnosticsLogged = true;
      mapDebugLogLaunchPairsWithin(400);
    }
    unawaited(installLaunchMarkersIfNeeded(onLaunchCircleTap));
  }

  void onLaunchCircleTap(CircleAnnotation annotation) {
    final raw = annotation.customData?['launchId'];
    if (raw is! String) {
      return;
    }
    final launch = ref.readLaunchPointIfExists(raw);
    if (launch == null) {
      return;
    }

    final planning = ref.read(routePlanningProvider);
    if (!planning.planningMode) {
      ui.onLaunchPlaceSelected?.call(launch);
      return;
    }

    _handlePlanningTap(launch);
  }

  Future<void> dismissPlanningSession() async {
    ref.read(routePlanningProvider.notifier).resetToBrowse();
    await _afterExitPlanning();
  }

  Future<void> clearPlanningSelection() async {
    mapDebugLog('_clearPlanningSelection');
    ref.read(routePlanningProvider.notifier).clearSelection();
    await clearRouteLine();
    final map = mapboxMap;
    if (map != null) {
      await fitViewportToAllLaunches(map);
      await mapDebugLogMapboxSnapshot(map, '_clearPlanningSelection done');
    }
  }

  void _handlePlanningTap(LaunchPoint launch) {
    final result = ref
        .read(routePlanningProvider.notifier)
        .handleLaunchTap(launch);
    switch (result) {
      case RoutePlanningTapResult.putInSelected:
        unawaited(clearRouteLine());
      case RoutePlanningTapResult.takeOutSelected:
        unawaited(_runRoute());
      case RoutePlanningTapResult.sameAsPutIn:
        ui.showSnackBar?.call(ui.pickDifferentTakeOutMessage);
      case null:
        break;
    }
  }

  Future<void> _runRoute() async {
    final planning = ref.read(routePlanningProvider);
    final waypoints = planning.waypoints;
    if (waypoints.length < 2) {
      return;
    }

    final planner = await _resolveRoutePlanner();
    if (planner == null || !alive) {
      return;
    }

    final planResult = planMultiSegmentRoute(planner, waypoints);
    if (!alive) {
      return;
    }

    if (planResult case Failure(:final error)) {
      mapDebugLog('plan FAILED multi-segment: ${error.code}');
      ref
          .read(routePlanningProvider.notifier)
          .setActiveGeometry(
            geometry: null,
            routeLengthKm: null,
          );
      unawaited(clearRouteLine());
      ui.showSnackBar?.call(error);
      return;
    }

    final segments =
        (planResult as Success<List<RouteSuccess>, RouteFailure>).value;
    final geometry = mergeRouteSegments(segments);
    if (geometry == null) {
      return;
    }
    mapDebugLog(
      'plan OK ${waypoints.length} stops '
      'lengthM=${geometry.lengthMeters.toStringAsFixed(0)}',
    );
    mapDebugLogRoutePolyline('planner output', geometry.polylineLonLat);
    ref
        .read(routePlanningProvider.notifier)
        .setActiveGeometry(
          geometry: geometry,
          routeLengthKm: geometry.lengthMeters / 1000.0,
        );
    await drawRouteLine(geometry.polylineLonLat);
    await fitCameraToRoute(geometry.polylineLonLat);
  }

  /// Applies an imported GPX route to planning state and the map line.
  Future<void> applyImportedRoute(PlannedRoute route) async {
    if (!alive) {
      return;
    }
    ref.read(routePlanningProvider.notifier).applyImportedRoute(route);
    final polyline = route.toPolylineLonLat();
    if (polyline.length >= 2) {
      await drawRouteLine(polyline);
      await fitCameraToRoute(polyline);
    }
  }

  Future<void> _afterExitPlanning() async {
    await clearRouteLine();
    final map = mapboxMap;
    if (map != null) {
      await fitViewportToAllLaunches(map);
      await mapDebugLogMapboxSnapshot(map, 'afterExitPlanning');
    }
  }

  /// Recomputes and draws the route for the current planning waypoints.
  Future<void> rerunActiveRoute() => _runRoute();

  /// Draws a saved or imported route polyline and fits the camera.
  Future<void> displayPlannedRoute(List<List<double>> polyline) async {
    if (!alive || polyline.length < 2) {
      return;
    }
    await drawRouteLine(polyline);
    if (mapboxMap == null) {
      // Map tab may have just become visible after shell branch switch.
      await Future<void>.delayed(Duration.zero);
      await drawRouteLine(polyline);
    }
    await fitCameraToRoute(polyline);
  }

  /// Waits for bundled hydro graphs when still loading; surfaces load errors.
  Future<RiverRoutePlanner?> _resolveRoutePlanner() async {
    final plannerAsync = ref.read(riverRoutePlannerProvider);
    if (plannerAsync.hasValue) {
      return plannerAsync.requireValue;
    }
    if (plannerAsync.hasError) {
      if (alive) {
        final failure = hydroAppFailureFrom(plannerAsync.error);
        ui.showSnackBar?.call(failure ?? ui.riverDataLoadFailedMessage);
      }
      return null;
    }
    try {
      return await ref.read(riverRoutePlannerProvider.future);
    } on Object catch (error) {
      if (alive) {
        final failure = hydroAppFailureFrom(error);
        ui.showSnackBar?.call(failure ?? ui.riverDataLoadFailedMessage);
      }
      return null;
    }
  }
}

import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
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
@riverpod
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
        if (planning.putIn == null || planning.takeOut == null) {
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
      ui.openLaunchDetail?.call(launch);
      return;
    }

    _handlePlanningTap(launch);
  }

  void togglePlanningMode() {
    final wasPlanning = ref.read(routePlanningProvider).planningMode;
    ref.read(routePlanningProvider.notifier).togglePlanningMode();
    if (wasPlanning) {
      unawaited(_afterExitPlanning());
    }
  }

  /// Invokes the snackbar callback bound from the map screen
  /// (widget tests only).
  @visibleForTesting
  void showSnackBarForTest(Object message) {
    ui.showSnackBar?.call(message);
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
    final put = planning.putIn;
    final take = planning.takeOut;
    final plannerAsync = ref.watch(riverRoutePlannerProvider);
    if (put == null || take == null) {
      return;
    }
    ref.read(routePlanningProvider.notifier).setComputingRoute();
    if (plannerAsync.hasError) {
      ref.read(routePlanningProvider.notifier).revertFromComputingRoute();
      if (alive) {
        final failure = hydroAppFailureFrom(plannerAsync.error);
        ui.showSnackBar?.call(failure ?? ui.riverDataLoadFailedMessage);
      }
      return;
    }
    if (!plannerAsync.hasValue) {
      ref.read(routePlanningProvider.notifier).revertFromComputingRoute();
      if (alive) {
        ui.showSnackBar?.call(ui.riverDataLoadingMessage);
      }
      return;
    }
    final planner = plannerAsync.requireValue;

    final result = planner.plan(put, take);
    if (!alive) {
      return;
    }

    if (result is RouteFailure) {
      mapDebugLog(
        'plan FAILED ${put.id} -> ${take.id}: '
        '${result.code}(${result.riverSystemName ?? ''})',
      );
      ref
          .read(routePlanningProvider.notifier)
          .setRouteFailure(putIn: put, takeOut: take, failure: result);
      unawaited(clearRouteLine());
      ui.showSnackBar?.call(result);
      return;
    }

    final ok = result as RouteSuccess;
    mapDebugLog(
      'plan OK ${put.id} -> ${take.id} '
      'lengthM=${ok.lengthMeters.toStringAsFixed(0)}',
    );
    mapDebugLogRoutePolyline('planner output', ok.polylineLonLat);
    mapDebugLogRouteSegmentMeters(ok.polylineLonLat);
    ref
        .read(routePlanningProvider.notifier)
        .setPlannedRoute(
          polylineLonLat: ok.polylineLonLat,
          routeLengthKm: ok.lengthMeters / 1000.0,
          routeOrigin: RouteOrigin.planner,
          putIn: put,
          takeOut: take,
          phase: RoutePlanningPhase.routeReady,
          routeReachId: ok.reachId,
        );
    await drawRouteLine(ok.polylineLonLat);
    await fitCameraToRoute(ok.polylineLonLat);
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
}

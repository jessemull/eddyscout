import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../launch_lookup.dart';
import '../map_planning_provider.dart';
import '../map_session_provider.dart';
import '../map_sheet_provider.dart';
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
        selectionTapCancelable?.cancel();
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
    await _prepareNewMapSurface(mapboxMap);
    mapDebugLog('onMapCreated (initial camera from MapWidget viewport)');
    await mapDebugLogMapboxSnapshot(
      mapboxMap,
      'onMapCreated',
      includeGestures: true,
    );
  }

  Future<void> _prepareNewMapSurface(MapboxMap mapboxMap) async {
    tapCancelable?.cancel();
    tapCancelable = null;
    selectionTapCancelable?.cancel();
    selectionTapCancelable = null;
    markersInstalled = false;
    launchCircleManager = null;
    selectionAnnotation = null;
    selectionManager = null;
    ref.read(mapInteractiveProvider.notifier).resetInteractive();
    this.mapboxMap = mapboxMap;
    mapboxMap.setOnMapTapListener(onMapContentTap);
    await setMapGesturesEnabled(mapboxMap, enabled: false);
  }

  /// Map surface tap — resolves nearest launch marker under the finger.
  void onMapContentTap(MapContentGestureContext context) {
    if (context.gestureState != GestureState.ended) {
      return;
    }
    unawaited(_handleMapContentTap(context));
  }

  Future<void> _handleMapContentTap(MapContentGestureContext context) async {
    if (!alive || !ref.read(mapInteractiveProvider)) {
      return;
    }
    final launch = await nearestLaunchAtTap(context.touchPosition);
    if (launch == null) {
      return;
    }
    _handleLaunchSelected(launch);
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
    _handleLaunchSelected(launch);
  }

  void _handleLaunchSelected(LaunchPoint launch) {
    final sheet = ref.read(mapSheetVisibilityStateProvider);
    if (sheet == MapSheetVisibility.planningEdit) {
      _handlePlanningTap(launch);
      return;
    }
    ui.onLaunchPlaceSelected?.call(launch);
  }

  /// Clears the selected-launch highlight ring.
  Future<void> clearLaunchHighlight() => highlightLaunch(null);

  /// Centers the camera and draws the selected-launch highlight ring.
  Future<void> focusLaunch(LaunchPoint launch) async {
    await flyToLaunch(launch);
    await highlightLaunch(launch, onSelectionTap: onLaunchCircleTap);
  }

  Future<void> dismissPlanningSession() async {
    ref.read(routePlanningProvider.notifier).resetToBrowse();
    await clearLaunchHighlight();
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
        unawaited(flyToLaunch(launch));
        unawaited(
          highlightLaunch(launch, onSelectionTap: onLaunchCircleTap),
        );
      case RoutePlanningTapResult.takeOutSelected:
        unawaited(_runRoute());
        unawaited(flyToLaunch(launch));
        unawaited(
          highlightLaunch(launch, onSelectionTap: onLaunchCircleTap),
        );
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
    if (_shouldFitCameraAfterRoute()) {
      await fitCameraToRoute(geometry.polylineLonLat);
    }
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

  bool _shouldFitCameraAfterRoute() {
    final visibility = ref.read(mapSheetVisibilityStateProvider);
    return visibility == MapSheetVisibility.planningPreview;
  }

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

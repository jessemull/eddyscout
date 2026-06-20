import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/map_route_planner.dart';
import '../../domain/map_route_planner_provider.dart';
import '../launch_lookup.dart';
import '../map_constants.dart';
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
      ..listen(mapRoutePlannerProvider, (previous, next) {
        final planning = ref.read(routePlanningProvider);
        if (planning.waypoints.length < 2) {
          return;
        }
        final wasPending = previous == null || !previous.hasValue;
        if (wasPending && next.hasValue) {
          unawaited(_runRoute());
        }
      })
      ..listen(routePlanningProvider, (previous, next) {
        final prevPoints = previous?.polylineLonLat?.length ?? 0;
        final nextPoints = next.polylineLonLat?.length ?? 0;
        if (prevPoints >= 2 && nextPoints < 2) {
          unawaited(clearRouteLine());
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
    mapboxMap
      ..removeInteraction(kMapContentTapInteractionId)
      ..addInteraction(
        TapInteraction.onMap(onMapContentTap),
        interactionID: kMapContentTapInteractionId,
      );
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

  /// Invalidates in-flight [_runRoute] work and clears the map line.
  ///
  /// Call before leaving planning edit (back arrow) so a late planner result
  /// cannot redraw the route after the user exits.
  Future<void> abandonPlanningRouteLine() async {
    bumpRouteLineGeneration();
    await clearRouteLine();
  }

  Future<void> _runRoute() async {
    final routeGeneration = routeLineGeneration;
    final planning = ref.read(routePlanningProvider);
    final waypoints = planning.waypoints;
    if (waypoints.length < 2) {
      return;
    }
    final waypointIds = waypoints.map((w) => w.id).toList(growable: false);

    final planner = await _resolveMapRoutePlanner();
    if (planner == null ||
        !_canApplyRouteResult(
          routeGeneration: routeGeneration,
          waypointIds: waypointIds,
        )) {
      return;
    }

    final planResult = await planner.planMultiSegment(waypoints);
    if (!alive) {
      return;
    }

    if (planResult case Failure(:final error)) {
      mapDebugLog('plan FAILED multi-segment: $error');
      if (!_canApplyRouteResult(
        routeGeneration: routeGeneration,
        waypointIds: waypointIds,
      )) {
        return;
      }
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

    final geometry =
        (planResult as Success<RouteGeometrySnapshot?, Object>).value;
    if (geometry == null ||
        !_canApplyRouteResult(
          routeGeneration: routeGeneration,
          waypointIds: waypointIds,
        )) {
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
    if (!_canApplyRouteResult(
      routeGeneration: routeGeneration,
      waypointIds: waypointIds,
    )) {
      return;
    }
    await drawRouteLine(geometry.polylineLonLat);
    if (!isRouteLineGenerationCurrent(routeGeneration)) {
      return;
    }
    if (_shouldFitCameraAfterRoute()) {
      await fitCameraToRoute(geometry.polylineLonLat);
    }
  }

  /// Applies an imported GPX route to planning state and the map line.
  Future<void> applyImportedRoute(PlannedRoute route) async {
    if (!alive) {
      return;
    }
    final lengthMeters = route.resolvedLengthMeters;
    final polyline = route.toPolylineLonLat();
    ref
        .read(routePlanningProvider.notifier)
        .applyImportedWaypoints(
          waypoints: [
            if (route.putIn != null) route.putIn!,
            if (route.takeOut != null && route.takeOut!.id != route.putIn?.id)
              route.takeOut!,
          ],
          geometry: polyline.length >= 2
              ? RouteGeometrySnapshot(
                  polylineLonLat: polyline,
                  lengthMeters: lengthMeters ?? 0,
                  computedAt: DateTime.now(),
                )
              : null,
          routeLengthKm: lengthMeters != null ? lengthMeters / 1000.0 : null,
          routeOrigin: route.origin,
        );
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

  bool _matchesPlannedWaypoints(List<String> waypointIds) {
    final current = ref.read(routePlanningProvider).waypoints;
    if (current.length != waypointIds.length) {
      return false;
    }
    for (var i = 0; i < waypointIds.length; i++) {
      if (current[i].id != waypointIds[i]) {
        return false;
      }
    }
    return true;
  }

  bool _shouldShowRouteOnMap() {
    final sheet = ref.read(mapSheetVisibilityStateProvider);
    return sheet == MapSheetVisibility.planningEdit ||
        sheet == MapSheetVisibility.planningPreview;
  }

  bool _canApplyRouteResult({
    required int routeGeneration,
    required List<String> waypointIds,
  }) {
    if (!alive ||
        !isRouteLineGenerationCurrent(routeGeneration) ||
        !_matchesPlannedWaypoints(waypointIds) ||
        !_shouldShowRouteOnMap()) {
      return false;
    }
    return true;
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
  Future<MapRoutePlanner?> _resolveMapRoutePlanner() async {
    final plannerAsync = ref.read(mapRoutePlannerProvider);
    if (plannerAsync.hasValue) {
      return plannerAsync.requireValue;
    }
    if (plannerAsync.hasError) {
      if (alive) {
        final failure = appFailureFrom(plannerAsync.error);
        ui.showSnackBar?.call(failure ?? ui.riverDataLoadFailedMessage);
      }
      return null;
    }
    try {
      return await ref.read(mapRoutePlannerProvider.future);
    } on Object catch (error) {
      if (alive) {
        final failure = appFailureFrom(error);
        ui.showSnackBar?.call(failure ?? ui.riverDataLoadFailedMessage);
      }
      return null;
    }
  }
}

import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/map_route_planner.dart';
import '../../domain/map_route_planner_provider.dart';
import '../launch_lookup.dart';
import '../map_constants.dart';
import '../map_planning_pick_stop_provider.dart';
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
        longTapCancelable?.cancel();
        selectionTapCancelable?.cancel();
      })
      ..listen(mapRoutePlannerProvider, (previous, next) {
        final planning = ref.read(routePlanningProvider);
        if (planning.stops.length < 2) {
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
        unawaited(syncPlanningSnapMarkers(next.stops));
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
    longTapCancelable?.cancel();
    longTapCancelable = null;
    waterEntryTapCancelable?.cancel();
    waterEntryTapCancelable = null;
    selectionTapCancelable?.cancel();
    selectionTapCancelable = null;
    markersInstalled = false;
    launchCircleManager = null;
    planningSnapManager = null;
    waterEntryCircleManager = null;
    waterEntryConnectorManager = null;
    selectionAnnotation = null;
    selectionWaterEntryAnnotation = null;
    selectionManager = null;
    ref.read(mapInteractiveProvider.notifier).resetInteractive();
    this.mapboxMap = mapboxMap;
    mapboxMap
      ..removeInteraction(kMapContentTapInteractionId)
      ..removeInteraction(kMapLongTapInteractionId)
      ..addInteraction(
        TapInteraction.onMap(onMapContentTap),
        interactionID: kMapContentTapInteractionId,
      )
      ..addInteraction(
        LongTapInteraction.onMap(onMapLongPress),
        interactionID: kMapLongTapInteractionId,
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

  /// Map long-press — adds a hydro-snapped custom stop during planning edit.
  void onMapLongPress(MapContentGestureContext context) {
    if (context.gestureState != GestureState.ended) {
      return;
    }
    unawaited(_handleMapLongPress(context));
  }

  Future<void> _handleMapContentTap(MapContentGestureContext context) async {
    if (!alive || !ref.read(mapInteractiveProvider)) {
      return;
    }
    if (ref.read(mapPlanningPickStopActiveProvider) &&
        ref.read(mapSheetVisibilityStateProvider) ==
            MapSheetVisibility.planningEdit) {
      await _handlePlanningMapPick(context);
      return;
    }
    final launch = await nearestLaunchAtTap(context.touchPosition);
    if (launch == null) {
      return;
    }
    _handleLaunchSelected(launch);
  }

  Future<void> _handleMapLongPress(MapContentGestureContext context) async {
    if (!alive || !ref.read(mapInteractiveProvider)) {
      return;
    }
    if (ref.read(mapSheetVisibilityStateProvider) !=
        MapSheetVisibility.planningEdit) {
      return;
    }
    await _handlePlanningMapPick(context);
  }

  Future<void> _handlePlanningMapPick(MapContentGestureContext context) async {
    final launch = await nearestLaunchAtTap(context.touchPosition);
    if (launch != null) {
      return;
    }
    final map = mapboxMap;
    if (map == null) {
      return;
    }
    try {
      final point = await map.coordinateForPixel(context.touchPosition);
      final coords = point.coordinates;
      final result = await tryAddPlanningSnapStop(
        coords.lat.toDouble(),
        coords.lng.toDouble(),
      );
      if (result != null) {
        ref.read(mapPlanningPickStopActiveProvider.notifier).exit();
      }
    } on Object catch (e, st) {
      mapDebugLog('_handlePlanningMapPick failed: $e\n$st');
    }
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

  /// Centers the camera on a planning stop.
  Future<void> focusStop(RoutePlanningStop stop) async {
    if (stop case CatalogRoutePlanningStop(:final launch)) {
      await focusLaunch(launch);
      return;
    }
    await flyToCoordinate(
      latitude: stop.routingLatitude,
      longitude: stop.routingLongitude,
    );
  }

  Future<void> dismissPlanningSession() async {
    ref.read(routePlanningProvider.notifier).resetToBrowse();
    await clearLaunchHighlight();
    await clearPlanningSnapMarkers();
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
    await clearPlanningSnapMarkers();
    final map = mapboxMap;
    if (map != null) {
      await fitViewportToAllLaunches(map);
      await mapDebugLogMapboxSnapshot(map, '_clearPlanningSelection done');
    }
  }

  void _handlePlanningTap(LaunchPoint launch) {
    unawaited(tryAddPlanningWaypoint(launch));
  }

  /// Validates hydro routing, then adds [launch] to the active plan when valid.
  Future<RoutePlanningTapResult?> tryAddPlanningWaypoint(
    LaunchPoint launch,
  ) async {
    return tryAddPlanningStop(RoutePlanningStop.catalog(launch));
  }

  /// Snaps a map coordinate and adds it as a custom planning stop when valid.
  Future<RoutePlanningTapResult?> tryAddPlanningSnapStop(
    double latitude,
    double longitude,
  ) async {
    final planning = ref.read(routePlanningProvider);
    if (!planning.planningMode && planning.stops.isEmpty) {
      return null;
    }

    final planner = await _resolveMapRoutePlanner();
    if (planner == null) {
      return null;
    }

    final snapResult = await planner.snapToWaterway(latitude, longitude);
    if (snapResult case Failure(:final error)) {
      ui.showSnackBar?.call(error);
      return null;
    }
    final snap = (snapResult as Success<WaterwaySnapPoint, Object>).value;
    final stopIndex = planning.stops.length + 1;
    final defaultLabel =
        ui.customStopLabel?.call(stopIndex) ??
        '${snap.latitude.toStringAsFixed(4)}, '
            '${snap.longitude.toStringAsFixed(4)}';

    final stop = RoutePlanningStop.snap(
      id: generatePlanningSnapId(),
      latitude: snap.latitude,
      longitude: snap.longitude,
      label: defaultLabel,
      reachId: snap.reachId,
    );

    return tryAddPlanningStop(stop);
  }

  /// Validates hydro routing, then adds [stop] to the active plan when valid.
  Future<RoutePlanningTapResult?> tryAddPlanningStop(
    RoutePlanningStop stop,
  ) async {
    final planning = ref.read(routePlanningProvider);
    if (!planning.planningMode && planning.stops.isEmpty) {
      return null;
    }

    final duplicate = _duplicatePlanningTapResult(planning.stops, stop);
    if (duplicate != null) {
      if (duplicate == RoutePlanningTapResult.sameAsPutIn) {
        ui.showSnackBar?.call(ui.pickDifferentTakeOutMessage);
      }
      return duplicate;
    }

    final planner = await _resolveMapRoutePlanner();
    if (planner == null) {
      return null;
    }

    final validation = planning.stops.isEmpty
        ? await planner.validateStop(stop)
        : await planner.validateSegmentStops(planning.stops.last, stop);
    if (validation case Failure(:final error)) {
      ui.showSnackBar?.call(error);
      return null;
    }

    final result = ref.read(routePlanningProvider.notifier).addStop(stop);
    if (result == null) {
      return null;
    }

    switch (result) {
      case RoutePlanningTapResult.putInSelected:
        await clearRouteLine();
        await focusStop(stop);
      case RoutePlanningTapResult.takeOutSelected:
        await _runRoute(rollbackLastStopOnFailure: true);
        await focusStop(stop);
      case RoutePlanningTapResult.sameAsPutIn:
        ui.showSnackBar?.call(ui.pickDifferentTakeOutMessage);
    }
    await syncPlanningSnapMarkers(ref.read(routePlanningProvider).stops);
    return result;
  }

  RoutePlanningTapResult? _duplicatePlanningTapResult(
    List<RoutePlanningStop> stops,
    RoutePlanningStop stop,
  ) {
    if (stops.isNotEmpty && stops.last.sameStopAs(stop)) {
      return RoutePlanningTapResult.sameAsPutIn;
    }
    if (stops.length == 1 && stops.first.sameStopAs(stop)) {
      return RoutePlanningTapResult.sameAsPutIn;
    }
    return null;
  }

  /// Invalidates in-flight [_runRoute] work and clears the map line.
  ///
  /// Call before leaving planning edit (back arrow) so a late planner result
  /// cannot redraw the route after the user exits.
  Future<void> abandonPlanningRouteLine() async {
    bumpRouteLineGeneration();
    await clearRouteLine();
    await clearPlanningSnapMarkers();
  }

  Future<void> rerunActiveRoute() => _runRoute();

  Future<void> _runRoute({bool rollbackLastStopOnFailure = false}) async {
    final routeGeneration = routeLineGeneration;
    final planning = ref.read(routePlanningProvider);
    final stops = planning.stops;
    if (stops.length < 2) {
      return;
    }
    final stopIds = stops.map((stop) => stop.stopId).toList(growable: false);

    final planner = await _resolveMapRoutePlanner();
    if (planner == null ||
        !_canApplyRouteResult(
          routeGeneration: routeGeneration,
          stopIds: stopIds,
        )) {
      return;
    }

    final planResult = await planner.planMultiSegment(stops);
    if (!alive) {
      return;
    }

    if (planResult case Failure(:final error)) {
      mapDebugLog('plan FAILED multi-segment: $error');
      if (!_canApplyRouteResult(
        routeGeneration: routeGeneration,
        stopIds: stopIds,
      )) {
        return;
      }
      ref
          .read(routePlanningProvider.notifier)
          .setActiveGeometry(
            geometry: null,
            routeLengthKm: null,
          );
      if (rollbackLastStopOnFailure) {
        ref.read(routePlanningProvider.notifier).removeLastStop();
      }
      unawaited(clearRouteLine());
      ui.showSnackBar?.call(error);
      return;
    }

    final geometry =
        (planResult as Success<RouteGeometrySnapshot?, Object>).value;
    if (geometry == null ||
        !_canApplyRouteResult(
          routeGeneration: routeGeneration,
          stopIds: stopIds,
        )) {
      return;
    }
    mapDebugLog(
      'plan OK ${stops.length} stops '
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
      stopIds: stopIds,
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

  bool _shouldFitCameraAfterRoute() {
    final visibility = ref.read(mapSheetVisibilityStateProvider);
    return visibility == MapSheetVisibility.planningPreview;
  }

  bool _matchesPlannedStops(List<String> stopIds) {
    final current = ref.read(routePlanningProvider).stops;
    if (current.length != stopIds.length) {
      return false;
    }
    for (var i = 0; i < stopIds.length; i++) {
      if (current[i].stopId != stopIds[i]) {
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
    required List<String> stopIds,
  }) {
    if (!alive ||
        !isRouteLineGenerationCurrent(routeGeneration) ||
        !_matchesPlannedStops(stopIds) ||
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

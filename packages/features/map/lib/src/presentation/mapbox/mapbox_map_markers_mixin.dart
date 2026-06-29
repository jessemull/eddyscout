import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/launch_tap_hit_test.dart';
import '../map_constants.dart';
import '../map_session_provider.dart';
import 'map_debug_log.dart';
import 'mapbox_map_camera_mixin.dart';
import 'mapbox_map_controller_shared.dart';
import 'mapbox_map_route_mixin.dart';
import 'mapbox_map_style_mixin.dart';

/// Launch circle annotations and first-time style setup.
///
/// Access pins use [LaunchPoint.latitude]/[LaunchPoint.longitude]. When a
/// catalog launch sets optional water-entry coordinates and
/// [LaunchPointCoordinates.hasDistinctWaterEntry] is true, this mixin also
/// draws a smaller water-entry circle plus a connector line to the access pin.
/// Both annotation layers share the same tap handler so planning taps resolve
/// to the launch id regardless of which circle is hit. Water-entry visuals are
/// omitted until catalog seeds exist; routing still uses water entry when set.
mixin MapboxMapMarkersMixin
    on
        MapboxMapControllerBase,
        MapboxMapStyleMixin,
        MapboxMapRouteMixin,
        MapboxMapCameraMixin {
  /// Installs launch markers once per map session after style load.
  Future<void> installLaunchMarkersIfNeeded(
    void Function(CircleAnnotation) onLaunchTap,
  ) async {
    final mapboxMap = this.mapboxMap;
    if (mapboxMap == null || !alive) {
      if (!alive && mapboxMap != null) {
        mapDebugLog(
          '_installLaunchMarkersIfNeeded skipped (controller disposed)',
        );
      }
      return;
    }
    if (markersInstalled && tapCancelable != null) {
      return;
    }
    try {
      await configureStandardStyleMap(mapboxMap);
      await ensureRouteLineStyle(mapboxMap);

      if (!markersInstalled) {
        final distinctLaunches = kLaunchPoints
            .where((launch) => launch.hasDistinctWaterEntry)
            .toList();

        final connectorManager =
            waterEntryConnectorManager ??
            await mapboxMap.annotations.createPolylineAnnotationManager();
        waterEntryConnectorManager = connectorManager;
        if (distinctLaunches.isNotEmpty) {
          await connectorManager.createMulti(
            distinctLaunches
                .map(
                  (launch) => PolylineAnnotationOptions(
                    geometry: LineString(
                      coordinates: [
                        Position(
                          launch.accessLongitude,
                          launch.accessLatitude,
                        ),
                        Position(
                          launch.routingLongitude,
                          launch.routingLatitude,
                        ),
                      ],
                    ),
                    lineColor: kMapWaterEntryConnectorColor,
                    lineWidth: kMapWaterEntryConnectorWidth,
                    lineOpacity: 0.85,
                  ),
                )
                .toList(),
          );
        }

        final accessManager =
            launchCircleManager ??
            await mapboxMap.annotations.createCircleAnnotationManager();
        launchCircleManager = accessManager;
        await accessManager.createMulti(
          kLaunchPoints
              .map(
                (launch) => CircleAnnotationOptions(
                  geometry: Point(
                    coordinates: Position(
                      launch.accessLongitude,
                      launch.accessLatitude,
                    ),
                  ),
                  circleRadius: 10,
                  circleColor: kMapMarkerColor,
                  circleStrokeWidth: 2,
                  circleStrokeColor: kMapMarkerStroke,
                  customData: <String, Object>{'launchId': launch.id},
                ),
              )
              .toList(),
        );

        final waterManager =
            waterEntryCircleManager ??
            await mapboxMap.annotations.createCircleAnnotationManager();
        waterEntryCircleManager = waterManager;
        if (distinctLaunches.isNotEmpty) {
          // Secondary tap target on the channel; semantics follow launch id.
          await waterManager.createMulti(
            distinctLaunches
                .map(
                  (launch) => CircleAnnotationOptions(
                    geometry: Point(
                      coordinates: Position(
                        launch.routingLongitude,
                        launch.routingLatitude,
                      ),
                    ),
                    circleRadius: kMapWaterEntryCircleRadius,
                    circleColor: kMapWaterEntryMarkerColor,
                    circleStrokeWidth: 2,
                    circleStrokeColor: kMapWaterEntryMarkerStroke,
                    customData: <String, Object>{'launchId': launch.id},
                  ),
                )
                .toList(),
          );
        }

        markersInstalled = true;
        mapDebugLog(
          '_installLaunchMarkersIfNeeded OK '
          'launches=${kLaunchPoints.length} '
          'connectors=${distinctLaunches.length} '
          'waterEntry=${distinctLaunches.length}',
        );

        await fitViewportToAllLaunches(mapboxMap);
      } else {
        mapDebugLog('_installLaunchMarkersIfNeeded rebind tapEvents');
      }

      final accessManager = launchCircleManager;
      if (accessManager != null) {
        tapCancelable?.cancel();
        tapCancelable = accessManager.tapEvents(onTap: onLaunchTap);
      }
      final waterManager = waterEntryCircleManager;
      if (waterManager != null) {
        waterEntryTapCancelable?.cancel();
        waterEntryTapCancelable = waterManager.tapEvents(onTap: onLaunchTap);
      }
      if (alive) {
        mapControllerRef
            .read(mapInteractiveProvider.notifier)
            .markInteractive();
        await setMapGesturesEnabled(mapboxMap, enabled: true);
      }
    } on Object catch (e, st) {
      mapDebugLog('_installLaunchMarkersIfNeeded failed: $e\n$st');
    }
  }

  Future<void> setMapGesturesEnabled(
    MapboxMap map, {
    required bool enabled,
  }) async {
    try {
      await map.gestures.updateSettings(
        GesturesSettings(
          scrollEnabled: enabled,
          pinchToZoomEnabled: enabled,
          rotateEnabled: enabled,
          pitchEnabled: enabled,
          doubleTapToZoomInEnabled: enabled,
          doubleTouchToZoomOutEnabled: enabled,
          quickZoomEnabled: enabled,
        ),
      );
    } on Object catch (e, st) {
      mapDebugLog('setMapGesturesEnabled failed: $e\n$st');
    }
  }

  /// Resolves a screen tap to the nearest curated launch marker.
  Future<LaunchPoint?> nearestLaunchAtTap(ScreenCoordinate tap) async {
    final map = mapboxMap;
    if (map == null || !alive) {
      return null;
    }
    return nearestLaunchAtScreenPoint(
      launches: kLaunchPoints,
      tap: tap,
      launchToPixel: (launch) => map.pixelForCoordinate(
        Point(
          coordinates: Position(
            launch.accessLongitude,
            launch.accessLatitude,
          ),
        ),
      ),
    );
  }

  /// Draws or clears a highlighted ring on the selected launch pin.
  Future<void> highlightLaunch(
    LaunchPoint? launch, {
    void Function(CircleAnnotation annotation)? onSelectionTap,
  }) async {
    final map = mapboxMap;
    if (map == null || !alive) {
      return;
    }
    try {
      selectionManager ??= await map.annotations
          .createCircleAnnotationManager();
      final manager = selectionManager;
      if (manager == null) {
        return;
      }
      final existing = selectionAnnotation;
      if (existing != null) {
        await manager.delete(existing);
        selectionAnnotation = null;
      }
      final existingWaterEntry = selectionWaterEntryAnnotation;
      if (existingWaterEntry != null) {
        await manager.delete(existingWaterEntry);
        selectionWaterEntryAnnotation = null;
      }
      if (launch == null) {
        return;
      }
      selectionAnnotation = await manager.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              launch.accessLongitude,
              launch.accessLatitude,
            ),
          ),
          circleRadius: 18,
          circleColor: kMapSelectedMarkerFill,
          circleStrokeWidth: 3,
          circleStrokeColor: kMapSelectedMarkerStroke,
          customData: <String, Object>{'launchId': launch.id},
        ),
      );
      if (launch.hasDistinctWaterEntry) {
        selectionWaterEntryAnnotation = await manager.create(
          CircleAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                launch.routingLongitude,
                launch.routingLatitude,
              ),
            ),
            circleRadius: 14,
            circleColor: kMapSelectedMarkerFill,
            circleStrokeWidth: 2,
            circleStrokeColor: kMapWaterEntryMarkerColor,
            customData: <String, Object>{'launchId': launch.id},
          ),
        );
      }
      if (onSelectionTap != null && selectionTapCancelable == null) {
        selectionTapCancelable = manager.tapEvents(onTap: onSelectionTap);
      }
    } on Object catch (e, st) {
      mapDebugLog('highlightLaunch failed: $e\n$st');
    }
  }

  /// Draws or clears markers for user-dropped snap stops during planning.
  Future<void> syncPlanningSnapMarkers(List<RoutePlanningStop> stops) async {
    final map = mapboxMap;
    if (map == null || !alive) {
      return;
    }
    try {
      planningSnapManager ??= await map.annotations
          .createCircleAnnotationManager();
      final manager = planningSnapManager;
      if (manager == null) {
        return;
      }
      await manager.deleteAll();
      final snapStops = stops.whereType<SnapRoutePlanningStop>().toList();
      if (snapStops.isEmpty) {
        return;
      }
      await manager.createMulti(
        snapStops
            .map(
              (stop) => CircleAnnotationOptions(
                geometry: Point(
                  coordinates: Position(stop.longitude, stop.latitude),
                ),
                circleRadius: 12,
                circleColor: kMapPlanningSnapMarkerColor,
                circleStrokeWidth: 2,
                circleStrokeColor: kMapPlanningSnapMarkerStroke,
                customData: <String, Object>{'snapStopId': stop.id},
              ),
            )
            .toList(),
      );
    } on Object catch (e, st) {
      mapDebugLog('syncPlanningSnapMarkers failed: $e\n$st');
    }
  }

  /// Removes all planning snap stop markers from the map.
  Future<void> clearPlanningSnapMarkers() async {
    final manager = planningSnapManager;
    if (manager == null) {
      return;
    }
    try {
      await manager.deleteAll();
    } on Object catch (e, st) {
      mapDebugLog('clearPlanningSnapMarkers failed: $e\n$st');
    }
  }
}

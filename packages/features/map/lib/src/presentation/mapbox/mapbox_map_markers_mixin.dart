import 'package:eddyscout_map/src/data/launch_points.dart';
import 'package:eddyscout_map/src/presentation/map_constants.dart';
import 'package:eddyscout_map/src/presentation/map_session_provider.dart';
import 'package:eddyscout_map/src/presentation/mapbox/map_debug_log.dart';
import 'package:eddyscout_map/src/presentation/mapbox/mapbox_map_camera_mixin.dart';
import 'package:eddyscout_map/src/presentation/mapbox/mapbox_map_controller_shared.dart';
import 'package:eddyscout_map/src/presentation/mapbox/mapbox_map_route_mixin.dart';
import 'package:eddyscout_map/src/presentation/mapbox/mapbox_map_style_mixin.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Launch circle annotations and first-time style setup.
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
    if (markersInstalled || mapboxMap == null || !alive) {
      if (!alive && mapboxMap != null) {
        mapDebugLog(
          '_installLaunchMarkersIfNeeded skipped (controller disposed)',
        );
      }
      return;
    }
    try {
      await configureStandardStyleMap(mapboxMap);
      await ensureRouteLineStyle(mapboxMap);

      final circleManager = await mapboxMap.annotations
          .createCircleAnnotationManager();

      final options = kLaunchPoints
          .map(
            (p) => CircleAnnotationOptions(
              geometry: Point(coordinates: Position(p.longitude, p.latitude)),
              circleRadius: 10,
              circleColor: kMapMarkerColor,
              circleStrokeWidth: 2,
              circleStrokeColor: kMapMarkerStroke,
              customData: <String, Object>{'launchId': p.id},
            ),
          )
          .toList();

      await circleManager.createMulti(options);
      markersInstalled = true;
      mapDebugLog(
        '_installLaunchMarkersIfNeeded OK markers=${kLaunchPoints.length}',
      );

      await fitViewportToAllLaunches(mapboxMap);

      tapCancelable?.cancel();
      tapCancelable = circleManager.tapEvents(onTap: onLaunchTap);
    } on Object catch (e, st) {
      mapDebugLog('_installLaunchMarkersIfNeeded failed: $e\n$st');
    } finally {
      if (alive) {
        mapControllerRef
            .read(mapInteractiveProvider.notifier)
            .markInteractive();
      }
    }
  }
}

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../map_constants.dart';
import 'map_debug_log.dart';
import 'mapbox_map_controller_shared.dart';

/// Standard style projection and camera bounds for the launch map.
mixin MapboxMapStyleMixin on MapboxMapControllerBase {
  /// Configures mercator projection and camera limits after style load.
  Future<void> configureStandardStyleMap(MapboxMap map) async {
    await mapDebugLogMapboxSnapshot(map, 'configureStandardStyleMap (before)');
    try {
      await map.style.setProjection(
        StyleProjection(name: StyleProjectionName.mercator),
      );
      mapDebugLog('setProjection(mercator) OK');
    } on Object catch (e, st) {
      mapDebugLog('setProjection(mercator) failed: $e\n$st');
    }
    await reassertMapCameraLimits(map);
    await mapDebugLogMapboxSnapshot(map, 'configureStandardStyleMap (after)');
  }

  /// Expands camera bounds to world extent with zoom/pitch clamps.
  Future<void> relaxCameraBounds(MapboxMap map) async {
    try {
      await map.setBounds(
        CameraBoundsOptions(
          bounds: CoordinateBounds(
            southwest: Point(coordinates: Position(-180, -85.05112878)),
            northeast: Point(coordinates: Position(180, 85.05112878)),
            infiniteBounds: true,
          ),
          minZoom: kMapMinZoom,
          maxZoom: kMapMaxZoom,
          minPitch: kMapMinPitch,
          maxPitch: kMapMaxPitch,
        ),
      );
      mapDebugLog(
        'setBounds(world + zoom $kMapMinZoom..$kMapMaxZoom '
        'pitch $kMapMinPitch..$kMapMaxPitch) OK',
      );
    } on Object catch (e, st) {
      mapDebugLog('setBounds failed: $e\n$st');
    }
  }

  /// Re-applies constrain mode and world bounds after camera moves.
  Future<void> reassertMapCameraLimits(MapboxMap map) async {
    try {
      await map.setConstrainMode(ConstrainMode.NONE);
      mapDebugLog('setConstrainMode(NONE) OK (reassert after camera)');
    } on Object catch (e, st) {
      mapDebugLog('setConstrainMode(reassert) failed: $e\n$st');
    }
    await relaxCameraBounds(map);
  }
}

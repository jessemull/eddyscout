import 'dart:async' show unawaited;

import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/screens/map/map_constants.dart';
import 'package:eddyscout/screens/map/map_planning_overlay.dart';
import 'package:eddyscout/screens/map/map_ui_callbacks.dart';
import 'package:eddyscout/screens/map/map_ui_callbacks_provider.dart';
import 'package:eddyscout/screens/map/mapbox_map_controller.dart';
import 'package:eddyscout/screens/map_planning_provider.dart';
import 'package:eddyscout/screens/map_session_provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(mapUiCallbacksProvider.notifier).state = MapUiCallbacks(
      showSnackBar: (message) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      openLaunchDetail: (launch) {
        if (!context.mounted) {
          return;
        }
        LaunchDetailRoute(launchId: launch.id).push<void>(context);
      },
    );
    final map = ref.read(mapboxMapControllerProvider.notifier);

    final planning = ref.watch(routePlanningProvider);
    final mapInteractive = ref.watch(mapInteractiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EddyScout'),
        actions: [
          IconButton(
            tooltip: planning.planningMode
                ? 'Exit route planning'
                : 'Plan river route',
            onPressed: map.togglePlanningMode,
            icon: Icon(planning.planningMode ? Icons.close : Icons.alt_route),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: !mapInteractive,
            child: MapWidget(
              key: const ValueKey<String>('eddyscout_map'),
              // TLHC_HC avoids Android texture/surface bugs with Mapbox (experimental).
              // ignore: experimental_member_use
              androidHostingMode: AndroidPlatformViewHostingMode.TLHC_HC,
              viewport: kInitialMapViewport,
              mapOptions: MapOptions(
                pixelRatio: MediaQuery.devicePixelRatioOf(context),
              ),
              onMapCreated: map.onMapCreated,
              onStyleLoadedListener: (_) => map.onStyleLoaded(),
              onCameraChangeListener: kDebugMode
                  ? map.onDebugCameraChanged
                  : null,
              onZoomListener: kDebugMode ? map.onDebugMapZoomEnded : null,
            ),
          ),
          if (mapInteractive)
            Positioned(
              left: 8,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 120,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Zoom in',
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          unawaited(map.nudgeZoomBy(kMapChromeZoomStep)),
                    ),
                    const Divider(height: 1),
                    IconButton(
                      tooltip: 'Zoom out',
                      icon: const Icon(Icons.remove),
                      onPressed: () =>
                          unawaited(map.nudgeZoomBy(-kMapChromeZoomStep)),
                    ),
                    const Divider(height: 1),
                    IconButton(
                      tooltip: 'Show all launches',
                      icon: const Icon(Icons.zoom_out_map),
                      onPressed: () => unawaited(map.fitRegionFromChrome()),
                    ),
                  ],
                ),
              ),
            ),
          if (planning.planningMode)
            MapPlanningOverlay(
              putIn: planning.putIn,
              takeOut: planning.takeOut,
              routeLengthKm: planning.routeLengthKm,
              onClear: () => unawaited(map.clearPlanningSelection()),
              onDone: map.togglePlanningMode,
            ),
        ],
      ),
    );
  }
}

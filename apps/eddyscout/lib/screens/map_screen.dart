import 'dart:async' show unawaited;

import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/screens/map/map_constants.dart';
import 'package:eddyscout/screens/map/map_planning_overlay.dart';
import 'package:eddyscout/screens/map/map_ui_callbacks.dart';
import 'package:eddyscout/screens/map/mapbox_map_controller.dart';
import 'package:eddyscout/screens/map_planning_provider.dart';
import 'package:eddyscout/screens/map_session_provider.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.mapSlot});

  /// Replaces [MapWidget] in widget tests (avoids Mapbox platform views).
  @visibleForTesting
  final Widget? mapSlot;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Riverpod forbids modifying providers during build/initState; bind after frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindUiCallbacks());
  }

  void _bindUiCallbacks() {
    if (!mounted) {
      return;
    }
    final l10n = context.l10n;
    ref
        .read(mapboxMapControllerProvider.notifier)
        .bindUiCallbacks(
          MapUiCallbacks(
            pickDifferentTakeOutMessage: l10n.mapPickDifferentTakeOut,
            riverDataLoadingMessage: l10n.mapRiverDataLoading,
            riverDataLoadFailedMessage: l10n.mapRiverDataUnavailable,
            showSnackBar: (message) {
              if (!context.mounted) {
                return;
              }
              final localized = switch (message) {
                RouteFailure(:final code, :final riverSystemName) =>
                  _localizedRouteFailure(
                    l10n: l10n,
                    code: code,
                    riverSystemName: riverSystemName,
                  ),
                ParseFailure() => l10n.mapRiverDataReadFailed,
                AssetLoadFailure() => l10n.mapRiverDataUnavailable,
                String() => message,
                _ => l10n.launchDetailUnavailable,
              };
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(localized)));
            },
            openLaunchDetail: (launch) {
              if (!context.mounted) {
                return;
              }
              unawaited(
                LaunchDetailRoute(launchId: launch.id).push<void>(context),
              );
            },
          ),
        );
  }

  String _localizedRouteFailure({
    required AppLocalizations l10n,
    required RouteFailureCode code,
    required String? riverSystemName,
  }) => switch (code) {
    RouteFailureCode.sameLaunch => l10n.mapRouteFailureSameLaunch,
    RouteFailureCode.differentSystem => l10n.mapRouteFailureDifferentSystem,
    RouteFailureCode.noBundledLine => l10n.mapRouteFailureNoBundledLine(
      riverSystemName ?? '',
    ),
    RouteFailureCode.noRiverGeometryLoaded => l10n.mapRouteFailureNoData,
    RouteFailureCode.putInTooFar => l10n.mapRouteFailurePutInTooFar,
    RouteFailureCode.takeOutTooFar => l10n.mapRouteFailureTakeOutTooFar,
    RouteFailureCode.noConnectedPath => l10n.mapRouteFailureNoConnectedPath,
  };

  @override
  Widget build(BuildContext context) {
    // Keep controller alive while this screen is mounted; autoDispose was
    // disposing it before async launch-marker install finished.
    ref.watch(mapboxMapControllerProvider);
    final map = ref.read(mapboxMapControllerProvider.notifier);

    final planning = ref.watch(routePlanningProvider);
    final mapInteractive = ref.watch(mapInteractiveProvider);

    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapScreenTitle),
        actions: [
          Semantics(
            button: true,
            label: planning.planningMode
                ? l10n.mapExitPlanningTooltip
                : l10n.mapPlanRouteTooltip,
            child: IconButton(
              tooltip: planning.planningMode
                  ? l10n.mapExitPlanningTooltip
                  : l10n.mapPlanRouteTooltip,
              onPressed: map.togglePlanningMode,
              icon: Icon(planning.planningMode ? Icons.close : Icons.alt_route),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: !mapInteractive,
            child:
                widget.mapSlot ??
                MapWidget(
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
              left: Spacing.sm,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 120,
              child: Semantics(
                container: true,
                label: l10n.mapZoomControlsSemantics,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.mapZoomInLabel,
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            unawaited(map.nudgeZoomBy(kMapChromeZoomStep)),
                      ),
                      const Divider(height: 1),
                      IconButton(
                        tooltip: l10n.mapZoomOutLabel,
                        icon: const Icon(Icons.remove),
                        onPressed: () =>
                            unawaited(map.nudgeZoomBy(-kMapChromeZoomStep)),
                      ),
                      const Divider(height: 1),
                      IconButton(
                        tooltip: l10n.mapShowAllLaunchesLabel,
                        icon: const Icon(Icons.zoom_out_map),
                        onPressed: () => unawaited(map.fitRegionFromChrome()),
                      ),
                    ],
                  ),
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

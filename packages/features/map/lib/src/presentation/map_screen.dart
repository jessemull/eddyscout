import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'map_constants.dart';
import 'map_planning_overlay.dart';
import 'map_planning_provider.dart';
import 'map_route_failure_l10n.dart';
import 'map_session_provider.dart';
import 'map_ui_callbacks.dart';
import 'mapbox/mapbox_map_controller.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.mapSlot,
    this.onOpenLaunchDetail,
    @visibleForTesting this.forceZoomChromeForTest = false,
  });

  /// Replaces [MapWidget] in widget tests (avoids Mapbox platform views).
  @visibleForTesting
  final Widget? mapSlot;

  /// Shows zoom chrome while [mapSlot] is set (widget tests only).
  @visibleForTesting
  final bool forceZoomChromeForTest;

  /// Opens launch detail for a tapped pin when not in route-planning mode.
  final void Function(LaunchPoint launch)? onOpenLaunchDetail;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool get _usesMapStub => widget.mapSlot != null;

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
              final localized = localizeMapPlannerMessage(
                l10n: l10n,
                message: message,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(localized)));
            },
            openLaunchDetail: (launch) {
              if (!context.mounted) {
                return;
              }
              widget.onOpenLaunchDetail?.call(launch);
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final planning = ref.watch(routePlanningProvider);
    final mapInteractive = ref.watch(mapInteractiveProvider);

    // Keep controller alive while this screen is mounted; autoDispose was
    // disposing it before async launch-marker install finished.
    ref.watch(mapboxMapControllerProvider);
    final mapController = ref.read(mapboxMapControllerProvider.notifier);

    final l10n = context.l10n;
    final mapChild = _usesMapStub
        ? widget.mapSlot!
        : _liveMapWidget(mapController);
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
              onPressed: mapController.togglePlanningMode,
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
            child: mapChild,
          ),
          if (mapInteractive &&
              (!_usesMapStub || widget.forceZoomChromeForTest))
            _MapZoomChrome(
              bottomPadding: MediaQuery.viewPaddingOf(context).bottom + 120,
              controller: mapController,
              semanticsLabel: l10n.mapZoomControlsSemantics,
              zoomInLabel: l10n.mapZoomInLabel,
              zoomOutLabel: l10n.mapZoomOutLabel,
              showAllLaunchesLabel: l10n.mapShowAllLaunchesLabel,
            ),
          if (planning.planningMode)
            MapPlanningOverlay(
              putIn: planning.putIn,
              takeOut: planning.takeOut,
              routeLengthKm: planning.routeLengthKm,
              onClear: () => unawaited(mapController.clearPlanningSelection()),
              onDone: mapController.togglePlanningMode,
            ),
        ],
      ),
    );
  }

  Widget _liveMapWidget(MapboxMapController controller) => MapWidget(
    key: const ValueKey<String>('eddyscout_map'),
    // TLHC_HC avoids Android texture/surface bugs with Mapbox (experimental).
    // ignore: experimental_member_use
    androidHostingMode: AndroidPlatformViewHostingMode.TLHC_HC,
    viewport: kInitialMapViewport,
    mapOptions: MapOptions(
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    ),
    onMapCreated: controller.onMapCreated,
    onStyleLoadedListener: (_) => controller.onStyleLoaded(),
    onCameraChangeListener: kDebugMode ? controller.onDebugCameraChanged : null,
    onZoomListener: kDebugMode ? controller.onDebugMapZoomEnded : null,
  );
}

class _MapZoomChrome extends StatelessWidget {
  const _MapZoomChrome({
    required this.bottomPadding,
    required this.controller,
    required this.semanticsLabel,
    required this.zoomInLabel,
    required this.zoomOutLabel,
    required this.showAllLaunchesLabel,
  });

  final double bottomPadding;
  final MapboxMapController controller;
  final String semanticsLabel;
  final String zoomInLabel;
  final String zoomOutLabel;
  final String showAllLaunchesLabel;

  @override
  Widget build(BuildContext context) => Positioned(
    left: Spacing.sm,
    bottom: bottomPadding,
    child: Semantics(
      container: true,
      label: semanticsLabel,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: zoomInLabel,
              icon: const Icon(Icons.add),
              onPressed: () =>
                  unawaited(controller.nudgeZoomBy(kMapChromeZoomStep)),
            ),
            const Divider(height: 1),
            IconButton(
              tooltip: zoomOutLabel,
              icon: const Icon(Icons.remove),
              onPressed: () =>
                  unawaited(controller.nudgeZoomBy(-kMapChromeZoomStep)),
            ),
            const Divider(height: 1),
            IconButton(
              tooltip: showAllLaunchesLabel,
              icon: const Icon(Icons.zoom_out_map),
              onPressed: () => unawaited(controller.fitRegionFromChrome()),
            ),
          ],
        ),
      ),
    ),
  );
}

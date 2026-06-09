import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'map_bottom_sheet_host.dart';
import 'map_constants.dart';
import 'map_floating_controls.dart';
import 'map_planning_provider.dart';
import 'map_route_failure_l10n.dart';
import 'map_search_field.dart';
import 'map_search_overlay.dart';
import 'map_search_provider.dart';
import 'map_session_provider.dart';
import 'map_sheet_provider.dart';
import 'map_ui_callbacks.dart';
import 'mapbox/mapbox_map_controller.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.mapSlot,
    this.onOpenLaunchDetail,
    this.onSaveRoute,
    @visibleForTesting this.forceZoomChromeForTest = false,
  });

  /// Replaces [MapWidget] in widget tests (avoids Mapbox platform views).
  @visibleForTesting
  final Widget? mapSlot;

  /// Shows zoom chrome while [mapSlot] is set (widget tests only).
  @visibleForTesting
  final bool forceZoomChromeForTest;

  /// Opens launch detail from the place sheet.
  final void Function(LaunchPoint launch)? onOpenLaunchDetail;

  /// Opens the save-route flow when planning has a valid route.
  final VoidCallback? onSaveRoute;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  bool get _usesMapStub => widget.mapSlot != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bindUiCallbacks();
    });
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
            onLaunchPlaceSelected: _handleLaunchPlaceSelected,
          ),
        );
  }

  void _handleLaunchPlaceSelected(LaunchPoint launch) {
    ref.read(mapPlaceSelectionProvider.notifier).pickLaunch(launch);
    ref.read(routePlanningProvider.notifier).selectPlace(launch);
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlacePeek();
    unawaited(
      ref.read(mapboxMapControllerProvider.notifier).flyToLaunch(launch),
    );
  }

  void _handleSearchLaunchSelected(LaunchPoint launch) {
    _handleLaunchPlaceSelected(launch);
  }

  void _startPlanPaddle(LaunchPoint launch) {
    ref.read(routePlanningProvider.notifier).startPlanPaddle(launch);
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningExpanded();
  }

  Future<void> _closeSheet() async {
    ref.read(mapSheetVisibilityStateProvider.notifier).hide();
    ref.read(mapPlaceSelectionProvider.notifier).clear();
    await ref
        .read(mapboxMapControllerProvider.notifier)
        .dismissPlanningSession();
  }

  Future<void> _clearRoute() async {
    await ref
        .read(mapboxMapControllerProvider.notifier)
        .clearPlanningSelection();
    final start = ref.read(routePlanningProvider).putIn;
    if (start != null) {
      ref.read(routePlanningProvider.notifier).startPlanPaddle(start);
      ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningExpanded();
    } else {
      await _closeSheet();
    }
  }

  void _showAddStopHint() {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.mapRouteAddStopHint)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(riverRoutePlannerProvider);

    final planning = ref.watch(routePlanningProvider);
    final mapInteractive = ref.watch(mapInteractiveProvider);
    final sheetVisibility = ref.watch(mapSheetVisibilityStateProvider);
    final selectedLaunch = ref.watch(mapPlaceSelectionProvider);
    final searchOpen = ref.watch(mapSearchOverlayVisibleProvider);

    ref.watch(mapboxMapControllerProvider);
    final mapController = ref.read(mapboxMapControllerProvider.notifier);

    final mapChild = _usesMapStub
        ? widget.mapSlot!
        : _liveMapWidget(mapController);

    final sheetPadding = sheetVisibility == MapSheetVisibility.hidden
        ? MediaQuery.viewPaddingOf(context).bottom + 72
        : MediaQuery.sizeOf(context).height * 0.28;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: !mapInteractive,
            child: mapChild,
          ),
          MapSearchField(
            onTap: () {
              ref.read(mapSearchOverlayVisibleProvider.notifier).show();
            },
          ),
          if (mapInteractive &&
              (!_usesMapStub || widget.forceZoomChromeForTest))
            MapFloatingControls(
              bottomPadding: sheetPadding,
              controller: mapController,
              showZoomChrome: true,
            ),
          if (sheetVisibility != MapSheetVisibility.hidden && !searchOpen)
            MapBottomSheetHost(
              visibility: sheetVisibility,
              selectedLaunch: selectedLaunch,
              waypoints: planning.waypoints,
              routeLengthKm: planning.routeLengthKm,
              canSave:
                  planning.hasRunnableRoute && planning.activeGeometry != null,
              onPlanPaddle: () {
                final launch = selectedLaunch;
                if (launch != null) {
                  _startPlanPaddle(launch);
                }
              },
              onViewConditions: () {
                final launch = selectedLaunch;
                if (launch != null) {
                  widget.onOpenLaunchDetail?.call(launch);
                }
              },
              onClose: () => unawaited(_closeSheet()),
              onClear: () => unawaited(_clearRoute()),
              onSave: () => widget.onSaveRoute?.call(),
              onAddStopHint: _showAddStopHint,
            ),
          if (searchOpen)
            MapSearchOverlay(
              onLaunchSelected: _handleSearchLaunchSelected,
            ),
        ],
      ),
    );
  }

  Widget _liveMapWidget(MapboxMapController controller) => MapWidget(
    key: const ValueKey<String>('eddyscout_map'),
    // Mapbox Android texture hosting — see mapbox_maps_flutter docs.
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

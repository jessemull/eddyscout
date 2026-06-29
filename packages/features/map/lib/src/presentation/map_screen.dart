import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../domain/map_route_planner_provider.dart';
import '../domain/map_trip_duration.dart';
import 'map_constants.dart';
import 'map_floating_controls.dart';
import 'map_place_peek_bar.dart';
import 'map_planning_pick_stop_banner.dart';
import 'map_planning_pick_stop_provider.dart';
import 'map_planning_provider.dart';
import 'map_route_failure_l10n.dart';
import 'map_route_planning_chrome.dart';
import 'map_route_preview_bar.dart';
import 'map_search_field.dart';
import 'map_search_provider.dart';
import 'map_session_provider.dart';
import 'map_sheet_provider.dart';
import 'map_ui_callbacks.dart';
import 'mapbox/mapbox_map_controller.dart';
import 'paddle_speed_provider.dart';
import 'trips_from_here/nearby_launches_provider.dart';
import 'trips_from_here/nearby_trips_search_overlay.dart';
import 'trips_from_here/nearby_trips_search_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.mapSlot,
    this.onOpenLaunchDetail,
    this.onSaveRoute,
    this.routeGoNoGoSection,
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

  /// Route go/no-go rollup injected from the app shell (conditions feature).
  final Widget? routeGoNoGoSection;

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
            customStopLabel: l10n.mapRouteCustomStopLabel,
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
    ref.read(mapSearchExpandedProvider.notifier).collapse();
    ref.read(mapPlaceSelectionProvider.notifier).pickLaunch(launch);
    ref.read(routePlanningProvider.notifier).selectPlace(launch);
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlacePeek();
    _scheduleFocusLaunch(launch);
  }

  void _scheduleFocusLaunch(LaunchPoint launch) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_focusLaunchOnMap(launch));
    });
  }

  Future<void> _focusLaunchOnMap(LaunchPoint launch) async {
    await ref.read(mapboxMapControllerProvider.notifier).focusLaunch(launch);
  }

  void _handleSearchLaunchSelected(LaunchPoint launch) {
    final sheet = ref.read(mapSheetVisibilityStateProvider);
    final searchContext = ref.read(mapSearchContextStateProvider);
    if (sheet == MapSheetVisibility.planningEdit ||
        searchContext == MapSearchContext.addStop) {
      _addStopFromSearch(launch);
      return;
    }
    _handleLaunchPlaceSelected(launch);
  }

  void _addStopFromSearch(LaunchPoint launch) {
    unawaited(_addStopFromSearchAsync(launch));
  }

  Future<void> _addStopFromSearchAsync(LaunchPoint launch) async {
    final result = await ref
        .read(mapboxMapControllerProvider.notifier)
        .tryAddPlanningWaypoint(launch);
    if (result == null) {
      return;
    }
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningEdit();
    ref.read(mapSearchExpandedProvider.notifier).collapse();
    _scheduleFocusLaunch(launch);
  }

  void _beginPlanningEditSession() {
    ref.read(mapSearchContextStateProvider.notifier).setAddStop();
    ref.read(mapSearchExpandedProvider.notifier).collapse();
  }

  void _startPlanPaddle(LaunchPoint launch) {
    unawaited(_startPlanPaddleAsync(launch));
  }

  Future<void> _startPlanPaddleAsync(LaunchPoint launch) async {
    final planner = await ref.read(mapRoutePlannerProvider.future);
    final validation = await planner.validateStop(
      RoutePlanningStop.catalog(launch),
    );
    if (!mounted) {
      return;
    }
    if (validation case Failure(:final error)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizeMapPlannerMessage(l10n: context.l10n, message: error),
          ),
        ),
      );
      return;
    }
    ref.read(routePlanningProvider.notifier).startPlanPaddle(launch);
    _beginPlanningEditSession();
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningEdit();
    _scheduleFocusLaunch(launch);
  }

  void _handlePlanToDestination({
    required LaunchPoint putIn,
    required LaunchPoint takeOut,
  }) {
    unawaited(_handlePlanToDestinationAsync(putIn: putIn, takeOut: takeOut));
  }

  Future<void> _handlePlanToDestinationAsync({
    required LaunchPoint putIn,
    required LaunchPoint takeOut,
  }) async {
    final planner = await ref.read(mapRoutePlannerProvider.future);
    final putInValidation = await planner.validateStop(
      RoutePlanningStop.catalog(putIn),
    );
    if (!mounted) {
      return;
    }
    if (putInValidation case Failure(:final error)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizeMapPlannerMessage(l10n: context.l10n, message: error),
          ),
        ),
      );
      return;
    }
    final segmentValidation = await planner.validateSegmentStops(
      RoutePlanningStop.catalog(putIn),
      RoutePlanningStop.catalog(takeOut),
    );
    if (!mounted) {
      return;
    }
    if (segmentValidation case Failure(:final error)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizeMapPlannerMessage(l10n: context.l10n, message: error),
          ),
        ),
      );
      return;
    }
    ref
        .read(routePlanningProvider.notifier)
        .startPlanFromHereTo(
          putIn: putIn,
          takeOut: takeOut,
        );
    ref.read(mapPlaceSelectionProvider.notifier).pickLaunch(putIn);
    _beginPlanningEditSession();
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningEdit();
    unawaited(
      ref.read(mapboxMapControllerProvider.notifier).rerunActiveRoute(),
    );
    _scheduleFocusLaunch(takeOut);
  }

  void _openSuggestedTripsSearch(LaunchPoint origin) {
    ref.read(nearbyTripsSearchOriginProvider.notifier).open(origin);
  }

  void _closeSuggestedTripsSearch() {
    ref.read(nearbyTripsSearchOriginProvider.notifier).close();
  }

  void _handleNearbyTripsLaunchSelected(LaunchPoint destination) {
    final origin = ref.read(nearbyTripsSearchOriginProvider);
    if (origin == null) {
      return;
    }
    _closeSuggestedTripsSearch();
    _handlePlanToDestination(putIn: origin, takeOut: destination);
  }

  void _resumePendingTripsFromHereRoute() {
    final planning = ref.read(routePlanningProvider);
    if (planning.stops.length < 2) {
      return;
    }
    _beginPlanningEditSession();
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningEdit();
    unawaited(
      ref.read(mapboxMapControllerProvider.notifier).rerunActiveRoute(),
    );
    final takeOut = planning.takeOut;
    if (takeOut != null) {
      unawaited(
        ref.read(mapboxMapControllerProvider.notifier).focusStop(takeOut),
      );
    }
  }

  void _resetBrowseSearchAndHideSheet() {
    ref.read(mapSearchContextStateProvider.notifier).setBrowse();
    ref.read(mapSearchExpandedProvider.notifier).collapse();
    ref.read(mapSheetVisibilityStateProvider.notifier).hide();
    ref.read(mapPlaceSelectionProvider.notifier).clear();
  }

  Future<void> _closePlacePeek() async {
    _resetBrowseSearchAndHideSheet();
    ref.read(routePlanningProvider.notifier).resetToBrowse();
    await ref.read(mapboxMapControllerProvider.notifier).clearRouteLine();
    await ref.read(mapboxMapControllerProvider.notifier).clearLaunchHighlight();
  }

  Future<void> _exitPlanningToPlacePeek() async {
    ref.read(mapPlanningPickStopActiveProvider.notifier).exit();
    ref.read(mapPlanningInlineAddStopProvider.notifier).hide();
    ref.read(mapSearchExpandedProvider.notifier).collapse();
    final putInLaunch = ref.read(routePlanningProvider).putIn?.catalogLaunch;
    final mapController = ref.read(mapboxMapControllerProvider.notifier);
    await mapController.abandonPlanningRouteLine();
    if (putInLaunch != null) {
      ref.read(mapPlaceSelectionProvider.notifier).pickLaunch(putInLaunch);
      ref.read(routePlanningProvider.notifier).selectPlace(putInLaunch);
    } else {
      ref.read(routePlanningProvider.notifier).resetToBrowse();
    }
    await mapController.clearLaunchHighlight();
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlacePeek();
  }

  void _enterPlanningPickStopMode() {
    ref.read(mapSearchExpandedProvider.notifier).collapse();
    ref.read(mapPlanningPickStopActiveProvider.notifier).enter();
  }

  void _exitPlanningPickStopMode() {
    ref.read(mapPlanningPickStopActiveProvider.notifier).exit();
  }

  Future<void> _backFromPlanningEdit() async {
    if (ref.read(mapPlanningPickStopActiveProvider)) {
      _exitPlanningPickStopMode();
      return;
    }
    await _exitPlanningToPlacePeek();
  }

  void _returnToPlanningEditFromPreview() {
    _beginPlanningEditSession();
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningEdit();
  }

  Future<void> _reorderStop(int oldIndex, int newIndex) async {
    final planningNotifier = ref.read(routePlanningProvider.notifier);
    final previousStops = ref.read(routePlanningProvider).stops;
    planningNotifier.reorderStops(oldIndex, newIndex);
    if (!ref.read(routePlanningProvider).hasRunnableRoute) {
      return;
    }
    await ref.read(mapboxMapControllerProvider.notifier).rerunActiveRoute();
    if (!ref.read(routePlanningProvider).canFinishPlanning) {
      planningNotifier.restoreStops(previousStops);
      await ref.read(mapboxMapControllerProvider.notifier).rerunActiveRoute();
    }
  }

  Future<void> _finishPlanningEdit() async {
    if (!ref.read(routePlanningProvider).canFinishPlanning) {
      return;
    }
    ref.read(mapPlanningPickStopActiveProvider.notifier).exit();
    ref.read(mapSheetVisibilityStateProvider.notifier).showPlanningPreview();
    final polyline = ref.read(routePlanningProvider).polylineLonLat;
    if (polyline != null && polyline.length >= 2) {
      await ref
          .read(mapboxMapControllerProvider.notifier)
          .fitCameraToRoute(polyline);
    }
  }

  Future<void> _removeStop(int index) async {
    ref.read(routePlanningProvider.notifier).removeStop(index);
    final planning = ref.read(routePlanningProvider);
    if (planning.stops.length >= 2) {
      await ref.read(mapboxMapControllerProvider.notifier).rerunActiveRoute();
    } else {
      await ref.read(mapboxMapControllerProvider.notifier).clearRouteLine();
    }
  }

  Future<void> _resetFromRoutePreview() async {
    _resetBrowseSearchAndHideSheet();
    await ref
        .read(mapboxMapControllerProvider.notifier)
        .dismissPlanningSession();
  }

  String? _tripTimeLabel(AppLocalizations l10n, double? routeLengthKm) {
    final speedKmh = ref.watch(effectivePaddleSpeedKmhProvider);
    final minutes = estimateTripDurationMinutes(
      distanceKm: routeLengthKm,
      speedKmh: speedKmh,
    );
    if (minutes == null) {
      return null;
    }
    return l10n.mapRouteTripTime(minutes);
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(mapRoutePlannerProvider)
      ..listen(tripsFromHereRoutePendingProvider, (previous, next) {
        if (!next) {
          return;
        }
        ref.read(tripsFromHereRoutePendingProvider.notifier).clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _resumePendingTripsFromHereRoute();
        });
      });

    final planning = ref.watch(routePlanningProvider);
    final mapInteractive = ref.watch(mapInteractiveProvider);
    final sheetVisibility = ref.watch(mapSheetVisibilityStateProvider);
    final pickStopActive = ref.watch(mapPlanningPickStopActiveProvider);
    final selectedLaunch = ref.watch(mapPlaceSelectionProvider);
    final searchExpanded = ref.watch(mapSearchExpandedProvider);
    final searchQuery = ref.watch(mapSearchQueryProvider);
    ref
      ..watch(mapSearchLaunchHitsProvider)
      ..watch(mapSearchPlaceHitsProvider(searchQuery.trim()))
      ..watch(mapboxMapControllerProvider);
    final mapController = ref.read(mapboxMapControllerProvider.notifier);
    final l10n = context.l10n;

    final trimmedSearchQuery = searchQuery.trim();
    final nearbyTripsOrigin = ref.watch(nearbyTripsSearchOriginProvider);
    final showNearbyTripsSearch = nearbyTripsOrigin != null;
    final showBrowseFullScreenSearch =
        sheetVisibility == MapSheetVisibility.hidden &&
        ref.watch(mapBrowseSearchFullScreenProvider);
    final showPlanningFullScreenSearch =
        searchExpanded && trimmedSearchQuery.isNotEmpty;
    final showFullScreenSearch =
        showBrowseFullScreenSearch ||
        showPlanningFullScreenSearch ||
        showNearbyTripsSearch;

    final mapChild = _usesMapStub
        ? widget.mapSlot!
        : _liveMapWidget(mapController);

    final controlsBottomPadding = switch (sheetVisibility) {
      MapSheetVisibility.planningPreview =>
        widget.routeGoNoGoSection == null
            ? kMapPlanningPreviewBottomPadding
            : kMapPlanningPreviewWithGoNoGoBottomPadding,
      MapSheetVisibility.placePeek => kPlacePeekChromeBottomPadding,
      _ => MediaQuery.viewPaddingOf(context).bottom + 72,
    };

    final showBrowseSearchField =
        sheetVisibility == MapSheetVisibility.hidden && !showFullScreenSearch;

    final interceptPlanningBack =
        (sheetVisibility == MapSheetVisibility.planningEdit ||
            sheetVisibility == MapSheetVisibility.planningPreview) &&
        !showFullScreenSearch;

    return PopScope(
      canPop: !interceptPlanningBack && !showNearbyTripsSearch,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && pickStopActive) {
          _exitPlanningPickStopMode();
          return;
        }
        if (!didPop && showNearbyTripsSearch) {
          _closeSuggestedTripsSearch();
          return;
        }
        if (didPop || !interceptPlanningBack) {
          return;
        }
        if (sheetVisibility == MapSheetVisibility.planningPreview) {
          _returnToPlanningEditFromPreview();
        } else {
          unawaited(_backFromPlanningEdit());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            mapChild,
            if (sheetVisibility == MapSheetVisibility.planningEdit &&
                !showFullScreenSearch &&
                !pickStopActive)
              Positioned(
                top: MediaQuery.viewPaddingOf(context).top + Spacing.sm,
                left: Spacing.md,
                right: Spacing.md,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: MapRoutePlanningChrome(
                    stops: planning.stops,
                    routeLengthKm: planning.routeLengthKm,
                    canFinishPlanning: planning.canFinishPlanning,
                    onBack: () => unawaited(_backFromPlanningEdit()),
                    onDone: () => unawaited(_finishPlanningEdit()),
                    onRemoveStop: (index) => unawaited(_removeStop(index)),
                    onReorderStop: (oldIndex, newIndex) =>
                        unawaited(_reorderStop(oldIndex, newIndex)),
                    onChooseOnMap: _enterPlanningPickStopMode,
                  ),
                ),
              ),
            if (sheetVisibility == MapSheetVisibility.planningEdit &&
                pickStopActive &&
                !showFullScreenSearch)
              Positioned(
                top: MediaQuery.viewPaddingOf(context).top + Spacing.sm,
                left: Spacing.md,
                right: Spacing.md,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: MapPlanningPickStopBanner(
                    onCancel: _exitPlanningPickStopMode,
                  ),
                ),
              ),
            if (sheetVisibility == MapSheetVisibility.placePeek &&
                selectedLaunch != null &&
                !showFullScreenSearch)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MapPlacePeekBar(
                  launch: selectedLaunch,
                  onPlanPaddle: () => _startPlanPaddle(selectedLaunch),
                  onViewConditions: () =>
                      widget.onOpenLaunchDetail?.call(selectedLaunch),
                  onDismiss: () => unawaited(_closePlacePeek()),
                  onOpenSuggestedTrips: () =>
                      _openSuggestedTripsSearch(selectedLaunch),
                ),
              ),
            if (sheetVisibility == MapSheetVisibility.planningPreview &&
                !showFullScreenSearch)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MapRoutePreviewBar(
                  tripTimeLabel: _tripTimeLabel(l10n, planning.routeLengthKm),
                  routeLengthKm: planning.routeLengthKm,
                  canSave:
                      planning.hasRunnableRoute &&
                      planning.activeGeometry != null,
                  goNoGoSection: widget.routeGoNoGoSection,
                  onBack: _returnToPlanningEditFromPreview,
                  onDismiss: () => unawaited(_resetFromRoutePreview()),
                  onStart: () => unawaited(_resetFromRoutePreview()),
                  onSave: () => widget.onSaveRoute?.call(),
                ),
              ),
            if (nearbyTripsOrigin case final origin?)
              Positioned.fill(
                child: NearbyTripsSearchOverlay(
                  originLaunch: origin,
                  onLaunchSelected: _handleNearbyTripsLaunchSelected,
                  onClose: _closeSuggestedTripsSearch,
                ),
              )
            else if (showBrowseFullScreenSearch || showPlanningFullScreenSearch)
              Positioned.fill(
                child: MapFullScreenSearchOverlay(
                  onLaunchSelected: _handleSearchLaunchSelected,
                ),
              ),
            if (showBrowseSearchField)
              Positioned(
                top: MediaQuery.viewPaddingOf(context).top + Spacing.sm,
                left: Spacing.md,
                right: Spacing.md,
                child: const MapBrowseSearchField(),
              ),
            if (mapInteractive &&
                (!_usesMapStub || widget.forceZoomChromeForTest)) ...[
              if (!_usesMapStub || widget.forceZoomChromeForTest)
                Positioned(
                  left: Spacing.sm,
                  bottom: controlsBottomPadding,
                  child: MapZoomControls(controller: mapController),
                ),
              Positioned(
                right: Spacing.sm,
                bottom: controlsBottomPadding,
                child: const MapLocateControl(),
              ),
            ],
          ],
        ),
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

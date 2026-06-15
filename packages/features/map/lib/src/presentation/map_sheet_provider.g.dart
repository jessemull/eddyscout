// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_sheet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Currently selected launch for the place peek sheet.

@ProviderFor(MapPlaceSelection)
final mapPlaceSelectionProvider = MapPlaceSelectionProvider._();

/// Currently selected launch for the place peek sheet.
final class MapPlaceSelectionProvider
    extends $NotifierProvider<MapPlaceSelection, LaunchPoint?> {
  /// Currently selected launch for the place peek sheet.
  MapPlaceSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapPlaceSelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapPlaceSelectionHash();

  @$internal
  @override
  MapPlaceSelection create() => MapPlaceSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchPoint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchPoint?>(value),
    );
  }
}

String _$mapPlaceSelectionHash() => r'c540c482c1137f6744ca19eed5fc1f78116953f1';

/// Currently selected launch for the place peek sheet.

abstract class _$MapPlaceSelection extends $Notifier<LaunchPoint?> {
  LaunchPoint? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LaunchPoint?, LaunchPoint?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LaunchPoint?, LaunchPoint?>,
              LaunchPoint?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Controls which map chrome variant is shown.

@ProviderFor(MapSheetVisibilityState)
final mapSheetVisibilityStateProvider = MapSheetVisibilityStateProvider._();

/// Controls which map chrome variant is shown.
final class MapSheetVisibilityStateProvider
    extends $NotifierProvider<MapSheetVisibilityState, MapSheetVisibility> {
  /// Controls which map chrome variant is shown.
  MapSheetVisibilityStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSheetVisibilityStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSheetVisibilityStateHash();

  @$internal
  @override
  MapSheetVisibilityState create() => MapSheetVisibilityState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapSheetVisibility value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapSheetVisibility>(value),
    );
  }
}

String _$mapSheetVisibilityStateHash() =>
    r'b6bfd56778f91da05708cd90c9844020e44c54c2';

/// Controls which map chrome variant is shown.

abstract class _$MapSheetVisibilityState extends $Notifier<MapSheetVisibility> {
  MapSheetVisibility build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MapSheetVisibility, MapSheetVisibility>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapSheetVisibility, MapSheetVisibility>,
              MapSheetVisibility,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

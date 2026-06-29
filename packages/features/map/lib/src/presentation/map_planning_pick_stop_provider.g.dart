// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_planning_pick_stop_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether route planning is in full-map "choose on map" snap-stop mode.

@ProviderFor(MapPlanningPickStopActive)
final mapPlanningPickStopActiveProvider = MapPlanningPickStopActiveProvider._();

/// Whether route planning is in full-map "choose on map" snap-stop mode.
final class MapPlanningPickStopActiveProvider
    extends $NotifierProvider<MapPlanningPickStopActive, bool> {
  /// Whether route planning is in full-map "choose on map" snap-stop mode.
  MapPlanningPickStopActiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapPlanningPickStopActiveProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapPlanningPickStopActiveHash();

  @$internal
  @override
  MapPlanningPickStopActive create() => MapPlanningPickStopActive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mapPlanningPickStopActiveHash() =>
    r'ba7eb12796ac281076bf9a0a820d0f31a0a55a26';

/// Whether route planning is in full-map "choose on map" snap-stop mode.

abstract class _$MapPlanningPickStopActive extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

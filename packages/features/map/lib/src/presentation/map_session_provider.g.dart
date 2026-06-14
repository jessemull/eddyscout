// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the Mapbox map finished style setup and launch markers are ready.
///
/// False blocks gestures until Mercator + launch fit completes.

@ProviderFor(MapInteractive)
final mapInteractiveProvider = MapInteractiveProvider._();

/// Whether the Mapbox map finished style setup and launch markers are ready.
///
/// False blocks gestures until Mercator + launch fit completes.
final class MapInteractiveProvider
    extends $NotifierProvider<MapInteractive, bool> {
  /// Whether the Mapbox map finished style setup and launch markers are ready.
  ///
  /// False blocks gestures until Mercator + launch fit completes.
  MapInteractiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapInteractiveProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapInteractiveHash();

  @$internal
  @override
  MapInteractive create() => MapInteractive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mapInteractiveHash() => r'8bd70a1d58281bdf95c1a9cce9a47f199cb9b466';

/// Whether the Mapbox map finished style setup and launch markers are ready.
///
/// False blocks gestures until Mercator + launch fit completes.

abstract class _$MapInteractive extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Increments when the map tab becomes active again (bottom nav).
///
/// Map route chrome listens to redraw saved/planned lines after offstage tabs.

@ProviderFor(MapTabResumed)
final mapTabResumedProvider = MapTabResumedProvider._();

/// Increments when the map tab becomes active again (bottom nav).
///
/// Map route chrome listens to redraw saved/planned lines after offstage tabs.
final class MapTabResumedProvider
    extends $NotifierProvider<MapTabResumed, int> {
  /// Increments when the map tab becomes active again (bottom nav).
  ///
  /// Map route chrome listens to redraw saved/planned lines after offstage tabs.
  MapTabResumedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapTabResumedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapTabResumedHash();

  @$internal
  @override
  MapTabResumed create() => MapTabResumed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$mapTabResumedHash() => r'3a6283ac505606f13bb7b2c2213fe32bac01e671';

/// Increments when the map tab becomes active again (bottom nav).
///
/// Map route chrome listens to redraw saved/planned lines after offstage tabs.

abstract class _$MapTabResumed extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

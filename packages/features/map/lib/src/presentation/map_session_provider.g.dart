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
        isAutoDispose: true,
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

String _$mapInteractiveHash() => r'97efb5bc18bb308fb9bab4b915afe52891a47a14';

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

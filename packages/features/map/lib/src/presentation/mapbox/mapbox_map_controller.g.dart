// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapbox_map_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns Mapbox map lifecycle: markers, route line, camera, and launch taps.

@ProviderFor(MapboxMapController)
final mapboxMapControllerProvider = MapboxMapControllerProvider._();

/// Owns Mapbox map lifecycle: markers, route line, camera, and launch taps.
final class MapboxMapControllerProvider
    extends $NotifierProvider<MapboxMapController, void> {
  /// Owns Mapbox map lifecycle: markers, route line, camera, and launch taps.
  MapboxMapControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapboxMapControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapboxMapControllerHash();

  @$internal
  @override
  MapboxMapController create() => MapboxMapController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$mapboxMapControllerHash() =>
    r'34d45fb37d7b5c53637c33b8e3d91eaa8bbcd358';

/// Owns Mapbox map lifecycle: markers, route line, camera, and launch taps.

abstract class _$MapboxMapController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_gpx_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Override in the app shell with a hydro-backed [MapGpxService].

@ProviderFor(mapGpxService)
final mapGpxServiceProvider = MapGpxServiceProvider._();

/// Override in the app shell with a hydro-backed [MapGpxService].

final class MapGpxServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<MapGpxService>,
          MapGpxService,
          FutureOr<MapGpxService>
        >
    with $FutureModifier<MapGpxService>, $FutureProvider<MapGpxService> {
  /// Override in the app shell with a hydro-backed [MapGpxService].
  MapGpxServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: disableProviderRetry,
        name: r'mapGpxServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapGpxServiceHash();

  @$internal
  @override
  $FutureProviderElement<MapGpxService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MapGpxService> create(Ref ref) {
    return mapGpxService(ref);
  }
}

String _$mapGpxServiceHash() => r'b10b8cdba02f21994f382b48b75b1ebd0c27164b';

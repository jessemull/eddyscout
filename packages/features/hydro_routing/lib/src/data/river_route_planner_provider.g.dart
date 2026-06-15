// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'river_route_planner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Override in the app shell with rootBundle.loadString for hydro assets.

@ProviderFor(hydroGeoJsonLoader)
final hydroGeoJsonLoaderProvider = HydroGeoJsonLoaderProvider._();

/// Override in the app shell with rootBundle.loadString for hydro assets.

final class HydroGeoJsonLoaderProvider
    extends
        $FunctionalProvider<
          HydroGeoJsonLoader,
          HydroGeoJsonLoader,
          HydroGeoJsonLoader
        >
    with $Provider<HydroGeoJsonLoader> {
  /// Override in the app shell with rootBundle.loadString for hydro assets.
  HydroGeoJsonLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hydroGeoJsonLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hydroGeoJsonLoaderHash();

  @$internal
  @override
  $ProviderElement<HydroGeoJsonLoader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HydroGeoJsonLoader create(Ref ref) {
    return hydroGeoJsonLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HydroGeoJsonLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HydroGeoJsonLoader>(value),
    );
  }
}

String _$hydroGeoJsonLoaderHash() =>
    r'e246a42633ff5334c84bf4dff226085f28424bfa';

/// Bundled hydro graphs for river routing between launches.

@ProviderFor(riverRoutePlanner)
final riverRoutePlannerProvider = RiverRoutePlannerProvider._();

/// Bundled hydro graphs for river routing between launches.

final class RiverRoutePlannerProvider
    extends
        $FunctionalProvider<
          AsyncValue<RiverRoutePlanner>,
          RiverRoutePlanner,
          FutureOr<RiverRoutePlanner>
        >
    with
        $FutureModifier<RiverRoutePlanner>,
        $FutureProvider<RiverRoutePlanner> {
  /// Bundled hydro graphs for river routing between launches.
  RiverRoutePlannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: disableProviderRetry,
        name: r'riverRoutePlannerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$riverRoutePlannerHash();

  @$internal
  @override
  $FutureProviderElement<RiverRoutePlanner> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RiverRoutePlanner> create(Ref ref) {
    return riverRoutePlanner(ref);
  }
}

String _$riverRoutePlannerHash() => r'e7707107e22a7eff927dec2e03f7d88379d9af22';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_router_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App route list supplied by the composition root via [ProviderScope]
/// override.

@ProviderFor(routes)
final routesProvider = RoutesProvider._();

/// App route list supplied by the composition root via [ProviderScope]
/// override.

final class RoutesProvider
    extends
        $FunctionalProvider<List<RouteBase>, List<RouteBase>, List<RouteBase>>
    with $Provider<List<RouteBase>> {
  /// App route list supplied by the composition root via [ProviderScope]
  /// override.
  RoutesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routesHash();

  @$internal
  @override
  $ProviderElement<List<RouteBase>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<RouteBase> create(Ref ref) {
    return routes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RouteBase> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RouteBase>>(value),
    );
  }
}

String _$routesHash() => r'b86f9d40304d426df93f8ecaf59e9c07f66a1e01';

/// Mapbox token for routing gates; override in tests via [ProviderContainer].

@ProviderFor(mapboxAccessToken)
final mapboxAccessTokenProvider = MapboxAccessTokenProvider._();

/// Mapbox token for routing gates; override in tests via [ProviderContainer].

final class MapboxAccessTokenProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Mapbox token for routing gates; override in tests via [ProviderContainer].
  MapboxAccessTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapboxAccessTokenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapboxAccessTokenHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return mapboxAccessToken(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$mapboxAccessTokenHash() => r'f7f030f8aa6b6c2da96bd4f8b85c323b1d3bc237';

/// Application [GoRouter] with typed routes and platform/token redirects.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// Application [GoRouter] with typed routes and platform/token redirects.

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Application [GoRouter] with typed routes and platform/token redirects.
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'd92c20df188f96aa7a603b836696bf24a6ee5895';

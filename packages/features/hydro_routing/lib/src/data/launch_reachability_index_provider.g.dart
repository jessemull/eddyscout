// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_reachability_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Override in the app shell with rootBundle.loadString for the index asset.

@ProviderFor(launchReachabilityIndexLoader)
final launchReachabilityIndexLoaderProvider =
    LaunchReachabilityIndexLoaderProvider._();

/// Override in the app shell with rootBundle.loadString for the index asset.

final class LaunchReachabilityIndexLoaderProvider
    extends
        $FunctionalProvider<
          LaunchReachabilityIndexLoader,
          LaunchReachabilityIndexLoader,
          LaunchReachabilityIndexLoader
        >
    with $Provider<LaunchReachabilityIndexLoader> {
  /// Override in the app shell with rootBundle.loadString for the index asset.
  LaunchReachabilityIndexLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchReachabilityIndexLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchReachabilityIndexLoaderHash();

  @$internal
  @override
  $ProviderElement<LaunchReachabilityIndexLoader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LaunchReachabilityIndexLoader create(Ref ref) {
    return launchReachabilityIndexLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchReachabilityIndexLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchReachabilityIndexLoader>(
        value,
      ),
    );
  }
}

String _$launchReachabilityIndexLoaderHash() =>
    r'fd4a8e82084c6e7950fca17b63d68b991d7ed259';

/// Pre-computed launch reachability index (graph distance bands).

@ProviderFor(launchReachabilityIndex)
final launchReachabilityIndexProvider = LaunchReachabilityIndexProvider._();

/// Pre-computed launch reachability index (graph distance bands).

final class LaunchReachabilityIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<LaunchReachabilityIndex>,
          LaunchReachabilityIndex,
          FutureOr<LaunchReachabilityIndex>
        >
    with
        $FutureModifier<LaunchReachabilityIndex>,
        $FutureProvider<LaunchReachabilityIndex> {
  /// Pre-computed launch reachability index (graph distance bands).
  LaunchReachabilityIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: disableProviderRetry,
        name: r'launchReachabilityIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchReachabilityIndexHash();

  @$internal
  @override
  $FutureProviderElement<LaunchReachabilityIndex> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LaunchReachabilityIndex> create(Ref ref) {
    return launchReachabilityIndex(ref);
  }
}

String _$launchReachabilityIndexHash() =>
    r'7086c858ab46cafd423e945d6c9f58f1dd2292e4';

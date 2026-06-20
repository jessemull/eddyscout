// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_suggested_trips_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Override in the app shell with rootBundle.loadString for the index asset.

@ProviderFor(launchSuggestedTripsIndexLoader)
final launchSuggestedTripsIndexLoaderProvider =
    LaunchSuggestedTripsIndexLoaderProvider._();

/// Override in the app shell with rootBundle.loadString for the index asset.

final class LaunchSuggestedTripsIndexLoaderProvider
    extends
        $FunctionalProvider<
          LaunchSuggestedTripsIndexLoader,
          LaunchSuggestedTripsIndexLoader,
          LaunchSuggestedTripsIndexLoader
        >
    with $Provider<LaunchSuggestedTripsIndexLoader> {
  /// Override in the app shell with rootBundle.loadString for the index asset.
  LaunchSuggestedTripsIndexLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchSuggestedTripsIndexLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchSuggestedTripsIndexLoaderHash();

  @$internal
  @override
  $ProviderElement<LaunchSuggestedTripsIndexLoader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LaunchSuggestedTripsIndexLoader create(Ref ref) {
    return launchSuggestedTripsIndexLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchSuggestedTripsIndexLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchSuggestedTripsIndexLoader>(
        value,
      ),
    );
  }
}

String _$launchSuggestedTripsIndexLoaderHash() =>
    r'62809e40090f1a16cd58232468ad43a7df8a1af4';

/// Pre-computed launch suggested trips index (one-way and round trips).

@ProviderFor(launchSuggestedTripsIndex)
final launchSuggestedTripsIndexProvider = LaunchSuggestedTripsIndexProvider._();

/// Pre-computed launch suggested trips index (one-way and round trips).

final class LaunchSuggestedTripsIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<LaunchSuggestedTripsIndex>,
          LaunchSuggestedTripsIndex,
          FutureOr<LaunchSuggestedTripsIndex>
        >
    with
        $FutureModifier<LaunchSuggestedTripsIndex>,
        $FutureProvider<LaunchSuggestedTripsIndex> {
  /// Pre-computed launch suggested trips index (one-way and round trips).
  LaunchSuggestedTripsIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: disableProviderRetry,
        name: r'launchSuggestedTripsIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchSuggestedTripsIndexHash();

  @$internal
  @override
  $FutureProviderElement<LaunchSuggestedTripsIndex> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LaunchSuggestedTripsIndex> create(Ref ref) {
    return launchSuggestedTripsIndex(ref);
  }
}

String _$launchSuggestedTripsIndexHash() =>
    r'ecd50ed79d4f9323a35f58ac34e57c07072b8596';

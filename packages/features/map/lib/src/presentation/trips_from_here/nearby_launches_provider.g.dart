// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_launches_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves catalog launches for one reachability band from a source launch.

@ProviderFor(nearbyLaunchesForBand)
final nearbyLaunchesForBandProvider = NearbyLaunchesForBandFamily._();

/// Resolves catalog launches for one reachability band from a source launch.

final class NearbyLaunchesForBandProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LaunchPoint>>,
          List<LaunchPoint>,
          FutureOr<List<LaunchPoint>>
        >
    with
        $FutureModifier<List<LaunchPoint>>,
        $FutureProvider<List<LaunchPoint>> {
  /// Resolves catalog launches for one reachability band from a source launch.
  NearbyLaunchesForBandProvider._({
    required NearbyLaunchesForBandFamily super.from,
    required NearbyLaunchesBandParams super.argument,
  }) : super(
         retry: disableProviderRetry,
         name: r'nearbyLaunchesForBandProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyLaunchesForBandHash();

  @override
  String toString() {
    return r'nearbyLaunchesForBandProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LaunchPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LaunchPoint>> create(Ref ref) {
    final argument = this.argument as NearbyLaunchesBandParams;
    return nearbyLaunchesForBand(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyLaunchesForBandProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyLaunchesForBandHash() =>
    r'9a93aebc5daac8ed1ab2be58799570c3fdb3bbc0';

/// Resolves catalog launches for one reachability band from a source launch.

final class NearbyLaunchesForBandFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<LaunchPoint>>,
          NearbyLaunchesBandParams
        > {
  NearbyLaunchesForBandFamily._()
    : super(
        retry: disableProviderRetry,
        name: r'nearbyLaunchesForBandProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resolves catalog launches for one reachability band from a source launch.

  NearbyLaunchesForBandProvider call(NearbyLaunchesBandParams params) =>
      NearbyLaunchesForBandProvider._(argument: params, from: this);

  @override
  String toString() => r'nearbyLaunchesForBandProvider';
}

/// Nearby launches grouped by exclusive reachability band.

@ProviderFor(nearbyLaunchesGrouped)
final nearbyLaunchesGroupedProvider = NearbyLaunchesGroupedFamily._();

/// Nearby launches grouped by exclusive reachability band.

final class NearbyLaunchesGroupedProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<ReachabilityBand, List<LaunchPoint>>>,
          Map<ReachabilityBand, List<LaunchPoint>>,
          FutureOr<Map<ReachabilityBand, List<LaunchPoint>>>
        >
    with
        $FutureModifier<Map<ReachabilityBand, List<LaunchPoint>>>,
        $FutureProvider<Map<ReachabilityBand, List<LaunchPoint>>> {
  /// Nearby launches grouped by exclusive reachability band.
  NearbyLaunchesGroupedProvider._({
    required NearbyLaunchesGroupedFamily super.from,
    required String super.argument,
  }) : super(
         retry: disableProviderRetry,
         name: r'nearbyLaunchesGroupedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyLaunchesGroupedHash();

  @override
  String toString() {
    return r'nearbyLaunchesGroupedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<ReachabilityBand, List<LaunchPoint>>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<ReachabilityBand, List<LaunchPoint>>> create(Ref ref) {
    final argument = this.argument as String;
    return nearbyLaunchesGrouped(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyLaunchesGroupedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyLaunchesGroupedHash() =>
    r'd3725d0568e365128feed964af1224691dbddb92';

/// Nearby launches grouped by exclusive reachability band.

final class NearbyLaunchesGroupedFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<ReachabilityBand, List<LaunchPoint>>>,
          String
        > {
  NearbyLaunchesGroupedFamily._()
    : super(
        retry: disableProviderRetry,
        name: r'nearbyLaunchesGroupedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Nearby launches grouped by exclusive reachability band.

  NearbyLaunchesGroupedProvider call(String originLaunchId) =>
      NearbyLaunchesGroupedProvider._(argument: originLaunchId, from: this);

  @override
  String toString() => r'nearbyLaunchesGroupedProvider';
}

/// Signals map screen to run hydro routing after returning from launch detail.

@ProviderFor(TripsFromHereRoutePending)
final tripsFromHereRoutePendingProvider = TripsFromHereRoutePendingProvider._();

/// Signals map screen to run hydro routing after returning from launch detail.
final class TripsFromHereRoutePendingProvider
    extends $NotifierProvider<TripsFromHereRoutePending, bool> {
  /// Signals map screen to run hydro routing after returning from launch detail.
  TripsFromHereRoutePendingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripsFromHereRoutePendingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripsFromHereRoutePendingHash();

  @$internal
  @override
  TripsFromHereRoutePending create() => TripsFromHereRoutePending();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$tripsFromHereRoutePendingHash() =>
    r'85e2f48c55536fddc9e71e07e0eef8d98f334a02';

/// Signals map screen to run hydro routing after returning from launch detail.

abstract class _$TripsFromHereRoutePending extends $Notifier<bool> {
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

/// Whether suggested trips index is wired (v2 extension point).

@ProviderFor(suggestedTripsIndexAvailable)
final suggestedTripsIndexAvailableProvider =
    SuggestedTripsIndexAvailableProvider._();

/// Whether suggested trips index is wired (v2 extension point).

final class SuggestedTripsIndexAvailableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether suggested trips index is wired (v2 extension point).
  SuggestedTripsIndexAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestedTripsIndexAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestedTripsIndexAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return suggestedTripsIndexAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$suggestedTripsIndexAvailableHash() =>
    r'6bd949ee953d5b2b3cd9ea3a7a25a12a1b15e884';

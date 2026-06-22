// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_trips_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Origin launch for the active nearby trips search session (null = closed).

@ProviderFor(NearbyTripsSearchOrigin)
final nearbyTripsSearchOriginProvider = NearbyTripsSearchOriginProvider._();

/// Origin launch for the active nearby trips search session (null = closed).
final class NearbyTripsSearchOriginProvider
    extends $NotifierProvider<NearbyTripsSearchOrigin, LaunchPoint?> {
  /// Origin launch for the active nearby trips search session (null = closed).
  NearbyTripsSearchOriginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyTripsSearchOriginProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyTripsSearchOriginHash();

  @$internal
  @override
  NearbyTripsSearchOrigin create() => NearbyTripsSearchOrigin();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchPoint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchPoint?>(value),
    );
  }
}

String _$nearbyTripsSearchOriginHash() =>
    r'972d474f6c3f40b397a536f600c53089093e906c';

/// Origin launch for the active nearby trips search session (null = closed).

abstract class _$NearbyTripsSearchOrigin extends $Notifier<LaunchPoint?> {
  LaunchPoint? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LaunchPoint?, LaunchPoint?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LaunchPoint?, LaunchPoint?>,
              LaunchPoint?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Max graph-distance (mi) for nearby trips search results.

@ProviderFor(NearbyTripsMaxDistanceMi)
final nearbyTripsMaxDistanceMiProvider = NearbyTripsMaxDistanceMiProvider._();

/// Max graph-distance (mi) for nearby trips search results.
final class NearbyTripsMaxDistanceMiProvider
    extends $NotifierProvider<NearbyTripsMaxDistanceMi, int> {
  /// Max graph-distance (mi) for nearby trips search results.
  NearbyTripsMaxDistanceMiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyTripsMaxDistanceMiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyTripsMaxDistanceMiHash();

  @$internal
  @override
  NearbyTripsMaxDistanceMi create() => NearbyTripsMaxDistanceMi();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$nearbyTripsMaxDistanceMiHash() =>
    r'1444bbd6d75189bcc02fa02f7a27eee872abf326';

/// Max graph-distance (mi) for nearby trips search results.

abstract class _$NearbyTripsMaxDistanceMi extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Query string for filtering nearby trips search results.

@ProviderFor(NearbyTripsSearchQuery)
final nearbyTripsSearchQueryProvider = NearbyTripsSearchQueryProvider._();

/// Query string for filtering nearby trips search results.
final class NearbyTripsSearchQueryProvider
    extends $NotifierProvider<NearbyTripsSearchQuery, String> {
  /// Query string for filtering nearby trips search results.
  NearbyTripsSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nearbyTripsSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nearbyTripsSearchQueryHash();

  @$internal
  @override
  NearbyTripsSearchQuery create() => NearbyTripsSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$nearbyTripsSearchQueryHash() =>
    r'e9ebde8b7413f06ce5d869ad96efec917e1706b9';

/// Query string for filtering nearby trips search results.

abstract class _$NearbyTripsSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Nearby launches within the selected max distance, filtered by query text.

@ProviderFor(filteredNearbyTrips)
final filteredNearbyTripsProvider = FilteredNearbyTripsFamily._();

/// Nearby launches within the selected max distance, filtered by query text.

final class FilteredNearbyTripsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LaunchPoint>>,
          List<LaunchPoint>,
          FutureOr<List<LaunchPoint>>
        >
    with
        $FutureModifier<List<LaunchPoint>>,
        $FutureProvider<List<LaunchPoint>> {
  /// Nearby launches within the selected max distance, filtered by query text.
  FilteredNearbyTripsProvider._({
    required FilteredNearbyTripsFamily super.from,
    required String super.argument,
  }) : super(
         retry: disableProviderRetry,
         name: r'filteredNearbyTripsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredNearbyTripsHash();

  @override
  String toString() {
    return r'filteredNearbyTripsProvider'
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
    final argument = this.argument as String;
    return filteredNearbyTrips(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredNearbyTripsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredNearbyTripsHash() =>
    r'5264d895e66cc712c89b03bdefd8241a3af22644';

/// Nearby launches within the selected max distance, filtered by query text.

final class FilteredNearbyTripsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LaunchPoint>>, String> {
  FilteredNearbyTripsFamily._()
    : super(
        retry: disableProviderRetry,
        name: r'filteredNearbyTripsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Nearby launches within the selected max distance, filtered by query text.

  FilteredNearbyTripsProvider call(String originLaunchId) =>
      FilteredNearbyTripsProvider._(argument: originLaunchId, from: this);

  @override
  String toString() => r'filteredNearbyTripsProvider';
}

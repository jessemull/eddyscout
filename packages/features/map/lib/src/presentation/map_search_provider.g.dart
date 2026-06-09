// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the full-screen search overlay is visible.

@ProviderFor(MapSearchOverlayVisible)
final mapSearchOverlayVisibleProvider = MapSearchOverlayVisibleProvider._();

/// Whether the full-screen search overlay is visible.
final class MapSearchOverlayVisibleProvider
    extends $NotifierProvider<MapSearchOverlayVisible, bool> {
  /// Whether the full-screen search overlay is visible.
  MapSearchOverlayVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchOverlayVisibleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSearchOverlayVisibleHash();

  @$internal
  @override
  MapSearchOverlayVisible create() => MapSearchOverlayVisible();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mapSearchOverlayVisibleHash() =>
    r'c3004f76eed6f4e8e67ae2136ab84aec5fd6df2c';

/// Whether the full-screen search overlay is visible.

abstract class _$MapSearchOverlayVisible extends $Notifier<bool> {
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

/// Search query text from the floating field.

@ProviderFor(MapSearchQuery)
final mapSearchQueryProvider = MapSearchQueryProvider._();

/// Search query text from the floating field.
final class MapSearchQueryProvider
    extends $NotifierProvider<MapSearchQuery, String> {
  /// Search query text from the floating field.
  MapSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSearchQueryHash();

  @$internal
  @override
  MapSearchQuery create() => MapSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$mapSearchQueryHash() => r'dedcec8bc8174d1028bf44e3237600265ec091fa';

/// Search query text from the floating field.

abstract class _$MapSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Local launch hits for the current query.

@ProviderFor(mapSearchLaunchHits)
final mapSearchLaunchHitsProvider = MapSearchLaunchHitsProvider._();

/// Local launch hits for the current query.

final class MapSearchLaunchHitsProvider
    extends
        $FunctionalProvider<
          List<MapSearchHitLaunch>,
          List<MapSearchHitLaunch>,
          List<MapSearchHitLaunch>
        >
    with $Provider<List<MapSearchHitLaunch>> {
  /// Local launch hits for the current query.
  MapSearchLaunchHitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchLaunchHitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSearchLaunchHitsHash();

  @$internal
  @override
  $ProviderElement<List<MapSearchHitLaunch>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<MapSearchHitLaunch> create(Ref ref) {
    return mapSearchLaunchHits(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MapSearchHitLaunch> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MapSearchHitLaunch>>(value),
    );
  }
}

String _$mapSearchLaunchHitsHash() =>
    r'1c9c5b2d528f72a59d916072517eb2b93b2140e7';

/// Remote geocoding hits (stub until Mapbox Search is integrated).

@ProviderFor(mapSearchPlaceHits)
final mapSearchPlaceHitsProvider = MapSearchPlaceHitsFamily._();

/// Remote geocoding hits (stub until Mapbox Search is integrated).

final class MapSearchPlaceHitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MapSearchHitPlace>>,
          List<MapSearchHitPlace>,
          FutureOr<List<MapSearchHitPlace>>
        >
    with
        $FutureModifier<List<MapSearchHitPlace>>,
        $FutureProvider<List<MapSearchHitPlace>> {
  /// Remote geocoding hits (stub until Mapbox Search is integrated).
  MapSearchPlaceHitsProvider._({
    required MapSearchPlaceHitsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'mapSearchPlaceHitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mapSearchPlaceHitsHash();

  @override
  String toString() {
    return r'mapSearchPlaceHitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MapSearchHitPlace>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MapSearchHitPlace>> create(Ref ref) {
    final argument = this.argument as String;
    return mapSearchPlaceHits(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MapSearchPlaceHitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mapSearchPlaceHitsHash() =>
    r'd39ccdc96c1f639a9aeda6bac3c00758a501bed7';

/// Remote geocoding hits (stub until Mapbox Search is integrated).

final class MapSearchPlaceHitsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MapSearchHitPlace>>, String> {
  MapSearchPlaceHitsFamily._()
    : super(
        retry: null,
        name: r'mapSearchPlaceHitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Remote geocoding hits (stub until Mapbox Search is integrated).

  MapSearchPlaceHitsProvider call(String query) =>
      MapSearchPlaceHitsProvider._(argument: query, from: this);

  @override
  String toString() => r'mapSearchPlaceHitsProvider';
}

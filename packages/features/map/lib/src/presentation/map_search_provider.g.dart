// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether inline map search is expanded at the top of the map.

@ProviderFor(MapSearchExpanded)
final mapSearchExpandedProvider = MapSearchExpandedProvider._();

/// Whether inline map search is expanded at the top of the map.
final class MapSearchExpandedProvider
    extends $NotifierProvider<MapSearchExpanded, bool> {
  /// Whether inline map search is expanded at the top of the map.
  MapSearchExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchExpandedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSearchExpandedHash();

  @$internal
  @override
  MapSearchExpanded create() => MapSearchExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mapSearchExpandedHash() => r'd9e3b1588ec63502d548307892cf59123316ad57';

/// Whether inline map search is expanded at the top of the map.

abstract class _$MapSearchExpanded extends $Notifier<bool> {
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

/// Whether the edit-stops panel shows an inline add-stop search row (2+ stops).

@ProviderFor(MapPlanningInlineAddStop)
final mapPlanningInlineAddStopProvider = MapPlanningInlineAddStopProvider._();

/// Whether the edit-stops panel shows an inline add-stop search row (2+ stops).
final class MapPlanningInlineAddStopProvider
    extends $NotifierProvider<MapPlanningInlineAddStop, bool> {
  /// Whether the edit-stops panel shows an inline add-stop search row (2+ stops).
  MapPlanningInlineAddStopProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapPlanningInlineAddStopProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapPlanningInlineAddStopHash();

  @$internal
  @override
  MapPlanningInlineAddStop create() => MapPlanningInlineAddStop();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mapPlanningInlineAddStopHash() =>
    r'532a122ee704a4d6ff50fa1e3b193344c0f265d0';

/// Whether the edit-stops panel shows an inline add-stop search row (2+ stops).

abstract class _$MapPlanningInlineAddStop extends $Notifier<bool> {
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

/// Whether browse search should cover the map with full-screen results.

@ProviderFor(mapBrowseSearchFullScreen)
final mapBrowseSearchFullScreenProvider = MapBrowseSearchFullScreenProvider._();

/// Whether browse search should cover the map with full-screen results.

final class MapBrowseSearchFullScreenProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether browse search should cover the map with full-screen results.
  MapBrowseSearchFullScreenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapBrowseSearchFullScreenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapBrowseSearchFullScreenHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return mapBrowseSearchFullScreen(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mapBrowseSearchFullScreenHash() =>
    r'cdcb66bc428b03b99076407b9140e64aaffe37c1';

/// Selection context for the active search session.

@ProviderFor(MapSearchContextState)
final mapSearchContextStateProvider = MapSearchContextStateProvider._();

/// Selection context for the active search session.
final class MapSearchContextStateProvider
    extends $NotifierProvider<MapSearchContextState, MapSearchContext> {
  /// Selection context for the active search session.
  MapSearchContextStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchContextStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapSearchContextStateHash();

  @$internal
  @override
  MapSearchContextState create() => MapSearchContextState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapSearchContext value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapSearchContext>(value),
    );
  }
}

String _$mapSearchContextStateHash() =>
    r'0f98a3fb37b682075518106c91f2876bbc290f32';

/// Selection context for the active search session.

abstract class _$MapSearchContextState extends $Notifier<MapSearchContext> {
  MapSearchContext build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MapSearchContext, MapSearchContext>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MapSearchContext, MapSearchContext>,
              MapSearchContext,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Search query text from the search field.

@ProviderFor(MapSearchQuery)
final mapSearchQueryProvider = MapSearchQueryProvider._();

/// Search query text from the search field.
final class MapSearchQueryProvider
    extends $NotifierProvider<MapSearchQuery, String> {
  /// Search query text from the search field.
  MapSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapSearchQueryProvider',
        isAutoDispose: true,
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

String _$mapSearchQueryHash() => r'5dd30629840bc2ad32ac020e0baf15e414e2ef74';

/// Search query text from the search field.

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
    r'6c6b92b8bda92c7b9d1cd0e36e37ade884203812';

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

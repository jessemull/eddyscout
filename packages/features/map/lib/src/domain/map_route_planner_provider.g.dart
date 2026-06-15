// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_route_planner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Override in the app shell with a hydro-backed [MapRoutePlanner].

@ProviderFor(mapRoutePlanner)
final mapRoutePlannerProvider = MapRoutePlannerProvider._();

/// Override in the app shell with a hydro-backed [MapRoutePlanner].

final class MapRoutePlannerProvider
    extends
        $FunctionalProvider<
          AsyncValue<MapRoutePlanner>,
          MapRoutePlanner,
          FutureOr<MapRoutePlanner>
        >
    with $FutureModifier<MapRoutePlanner>, $FutureProvider<MapRoutePlanner> {
  /// Override in the app shell with a hydro-backed [MapRoutePlanner].
  MapRoutePlannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: disableProviderRetry,
        name: r'mapRoutePlannerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapRoutePlannerHash();

  @$internal
  @override
  $FutureProviderElement<MapRoutePlanner> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MapRoutePlanner> create(Ref ref) {
    return mapRoutePlanner(ref);
  }
}

String _$mapRoutePlannerHash() => r'96983ccafeca0aa315af74dcccfa2455c2832d65';

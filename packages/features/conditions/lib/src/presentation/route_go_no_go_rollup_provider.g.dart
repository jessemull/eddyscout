// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_go_no_go_rollup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Evaluates and rolls up go/no-go across ordered route waypoint launch ids.

@ProviderFor(routeGoNoGoRollup)
final routeGoNoGoRollupProvider = RouteGoNoGoRollupFamily._();

/// Evaluates and rolls up go/no-go across ordered route waypoint launch ids.

final class RouteGoNoGoRollupProvider
    extends
        $FunctionalProvider<
          AsyncValue<RouteGoNoGoResult>,
          RouteGoNoGoResult,
          FutureOr<RouteGoNoGoResult>
        >
    with
        $FutureModifier<RouteGoNoGoResult>,
        $FutureProvider<RouteGoNoGoResult> {
  /// Evaluates and rolls up go/no-go across ordered route waypoint launch ids.
  RouteGoNoGoRollupProvider._({
    required RouteGoNoGoRollupFamily super.from,
    required RouteGoNoGoWaypointsKey super.argument,
  }) : super(
         retry: disableProviderRetry,
         name: r'routeGoNoGoRollupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routeGoNoGoRollupHash();

  @override
  String toString() {
    return r'routeGoNoGoRollupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RouteGoNoGoResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RouteGoNoGoResult> create(Ref ref) {
    final argument = this.argument as RouteGoNoGoWaypointsKey;
    return routeGoNoGoRollup(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RouteGoNoGoRollupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routeGoNoGoRollupHash() => r'e8a5c61602ca4f30e9a273f7448f5480c4b03717';

/// Evaluates and rolls up go/no-go across ordered route waypoint launch ids.

final class RouteGoNoGoRollupFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<RouteGoNoGoResult>,
          RouteGoNoGoWaypointsKey
        > {
  RouteGoNoGoRollupFamily._()
    : super(
        retry: disableProviderRetry,
        name: r'routeGoNoGoRollupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Evaluates and rolls up go/no-go across ordered route waypoint launch ids.

  RouteGoNoGoRollupProvider call(RouteGoNoGoWaypointsKey waypointsKey) =>
      RouteGoNoGoRollupProvider._(argument: waypointsKey, from: this);

  @override
  String toString() => r'routeGoNoGoRollupProvider';
}

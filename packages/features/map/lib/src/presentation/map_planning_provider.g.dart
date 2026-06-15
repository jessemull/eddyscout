// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_planning_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RoutePlanning)
final routePlanningProvider = RoutePlanningProvider._();

final class RoutePlanningProvider
    extends $NotifierProvider<RoutePlanning, RoutePlanningState> {
  RoutePlanningProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routePlanningProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routePlanningHash();

  @$internal
  @override
  RoutePlanning create() => RoutePlanning();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutePlanningState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutePlanningState>(value),
    );
  }
}

String _$routePlanningHash() => r'14b079e0c1cbb662292e8ed5b6af96044709be91';

abstract class _$RoutePlanning extends $Notifier<RoutePlanningState> {
  RoutePlanningState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RoutePlanningState, RoutePlanningState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RoutePlanningState, RoutePlanningState>,
              RoutePlanningState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

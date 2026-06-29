// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpx_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GpxActions)
final gpxActionsProvider = GpxActionsProvider._();

final class GpxActionsProvider
    extends $AsyncNotifierProvider<GpxActions, void> {
  GpxActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gpxActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gpxActionsHash();

  @$internal
  @override
  GpxActions create() => GpxActions();
}

String _$gpxActionsHash() => r'a9f50c1c0fd4bb7aef0c9e2a01cb004287e21db4';

abstract class _$GpxActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

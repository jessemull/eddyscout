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

String _$gpxActionsHash() => r'6510294d183d6be6e0fb0c4e39588223a21a7833';

abstract class _$GpxActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

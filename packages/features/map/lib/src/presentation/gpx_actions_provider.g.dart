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

String _$gpxActionsHash() => r'10f01ef4e6b4c9ea75f4724a2cff92c32c17abfd';

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

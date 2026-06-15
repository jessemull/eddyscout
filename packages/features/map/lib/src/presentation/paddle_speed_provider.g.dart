// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paddle_speed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User's average paddling speed for trip-time estimates.

@ProviderFor(PaddleSpeed)
final paddleSpeedProvider = PaddleSpeedProvider._();

/// User's average paddling speed for trip-time estimates.
final class PaddleSpeedProvider
    extends $AsyncNotifierProvider<PaddleSpeed, double> {
  /// User's average paddling speed for trip-time estimates.
  PaddleSpeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paddleSpeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paddleSpeedHash();

  @$internal
  @override
  PaddleSpeed create() => PaddleSpeed();
}

String _$paddleSpeedHash() => r'f527a3a1e5dc7c6b8f1e2d1c3c51fb2efaea11a9';

/// User's average paddling speed for trip-time estimates.

abstract class _$PaddleSpeed extends $AsyncNotifier<double> {
  FutureOr<double> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<double>, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<double>, double>,
              AsyncValue<double>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Current paddling speed for trip estimates, falling back to the default.

@ProviderFor(effectivePaddleSpeedKmh)
final effectivePaddleSpeedKmhProvider = EffectivePaddleSpeedKmhProvider._();

/// Current paddling speed for trip estimates, falling back to the default.

final class EffectivePaddleSpeedKmhProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Current paddling speed for trip estimates, falling back to the default.
  EffectivePaddleSpeedKmhProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectivePaddleSpeedKmhProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectivePaddleSpeedKmhHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return effectivePaddleSpeedKmh(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$effectivePaddleSpeedKmhHash() =>
    r'b5fa65cd171e4f3729ebbaf10c6b3fd513e44950';

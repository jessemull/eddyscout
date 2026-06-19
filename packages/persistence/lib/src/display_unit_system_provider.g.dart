// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_unit_system_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User preference for metric vs imperial distance and speed display.

@ProviderFor(UnitSystem)
final unitSystemProvider = UnitSystemProvider._();

/// User preference for metric vs imperial distance and speed display.
final class UnitSystemProvider
    extends $AsyncNotifierProvider<UnitSystem, DisplayUnitSystem> {
  /// User preference for metric vs imperial distance and speed display.
  UnitSystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitSystemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitSystemHash();

  @$internal
  @override
  UnitSystem create() => UnitSystem();
}

String _$unitSystemHash() => r'0aaae031f1ce7d5b40067cfd622294a8bb919024';

/// User preference for metric vs imperial distance and speed display.

abstract class _$UnitSystem extends $AsyncNotifier<DisplayUnitSystem> {
  FutureOr<DisplayUnitSystem> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DisplayUnitSystem>, DisplayUnitSystem>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DisplayUnitSystem>, DisplayUnitSystem>,
              AsyncValue<DisplayUnitSystem>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Current display unit system, falling back to [kDefaultDisplayUnitSystem].

@ProviderFor(effectiveDisplayUnitSystem)
final effectiveDisplayUnitSystemProvider =
    EffectiveDisplayUnitSystemProvider._();

/// Current display unit system, falling back to [kDefaultDisplayUnitSystem].

final class EffectiveDisplayUnitSystemProvider
    extends
        $FunctionalProvider<
          DisplayUnitSystem,
          DisplayUnitSystem,
          DisplayUnitSystem
        >
    with $Provider<DisplayUnitSystem> {
  /// Current display unit system, falling back to [kDefaultDisplayUnitSystem].
  EffectiveDisplayUnitSystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveDisplayUnitSystemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveDisplayUnitSystemHash();

  @$internal
  @override
  $ProviderElement<DisplayUnitSystem> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DisplayUnitSystem create(Ref ref) {
    return effectiveDisplayUnitSystem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisplayUnitSystem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisplayUnitSystem>(value),
    );
  }
}

String _$effectiveDisplayUnitSystemHash() =>
    r'338f7ff217079ed6a7a30d698566b2a8d8bc21e8';

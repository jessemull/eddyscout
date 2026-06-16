// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_unit_preference_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User preference for metric vs imperial distance and speed display.

@ProviderFor(DisplayUnitPreference)
final displayUnitPreferenceProvider = DisplayUnitPreferenceProvider._();

/// User preference for metric vs imperial distance and speed display.
final class DisplayUnitPreferenceProvider
    extends $AsyncNotifierProvider<DisplayUnitPreference, DisplayUnitSystem> {
  /// User preference for metric vs imperial distance and speed display.
  DisplayUnitPreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayUnitPreferenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayUnitPreferenceHash();

  @$internal
  @override
  DisplayUnitPreference create() => DisplayUnitPreference();
}

String _$displayUnitPreferenceHash() =>
    r'8d4e5ff6a5eb378098c93183d0f8e94ee795cbea';

/// User preference for metric vs imperial distance and speed display.

abstract class _$DisplayUnitPreference
    extends $AsyncNotifier<DisplayUnitSystem> {
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

/// Current display units, falling back to metric while loading or on error.

@ProviderFor(effectiveDisplayUnits)
final effectiveDisplayUnitsProvider = EffectiveDisplayUnitsProvider._();

/// Current display units, falling back to metric while loading or on error.

final class EffectiveDisplayUnitsProvider
    extends
        $FunctionalProvider<
          DisplayUnitSystem,
          DisplayUnitSystem,
          DisplayUnitSystem
        >
    with $Provider<DisplayUnitSystem> {
  /// Current display units, falling back to metric while loading or on error.
  EffectiveDisplayUnitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveDisplayUnitsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveDisplayUnitsHash();

  @$internal
  @override
  $ProviderElement<DisplayUnitSystem> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DisplayUnitSystem create(Ref ref) {
    return effectiveDisplayUnits(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DisplayUnitSystem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DisplayUnitSystem>(value),
    );
  }
}

String _$effectiveDisplayUnitsHash() =>
    r'5c6d8f0ffd5a764b08d497aca03dc307f77d2f80';

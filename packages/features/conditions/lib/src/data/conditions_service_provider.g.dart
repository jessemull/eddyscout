// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// HTTP-backed conditions service for repository wiring at the app root.

@ProviderFor(conditionsService)
final conditionsServiceProvider = ConditionsServiceProvider._();

/// HTTP-backed conditions service for repository wiring at the app root.

final class ConditionsServiceProvider
    extends
        $FunctionalProvider<
          ConditionsService,
          ConditionsService,
          ConditionsService
        >
    with $Provider<ConditionsService> {
  /// HTTP-backed conditions service for repository wiring at the app root.
  ConditionsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionsServiceHash();

  @$internal
  @override
  $ProviderElement<ConditionsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConditionsService create(Ref ref) {
    return conditionsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionsService>(value),
    );
  }
}

String _$conditionsServiceHash() => r'd88bbca12c0b0616caa207229046938369b7423a';

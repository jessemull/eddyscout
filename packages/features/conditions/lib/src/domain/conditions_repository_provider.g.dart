// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable [ConditionsRepository] token for presentation and tests.

@ProviderFor(conditionsRepository)
final conditionsRepositoryProvider = ConditionsRepositoryProvider._();

/// Injectable [ConditionsRepository] token for presentation and tests.

final class ConditionsRepositoryProvider
    extends
        $FunctionalProvider<
          ConditionsRepository,
          ConditionsRepository,
          ConditionsRepository
        >
    with $Provider<ConditionsRepository> {
  /// Injectable [ConditionsRepository] token for presentation and tests.
  ConditionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConditionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConditionsRepository create(Ref ref) {
    return conditionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionsRepository>(value),
    );
  }
}

String _$conditionsRepositoryHash() =>
    r'a24ff8df693c2a95dc584966cfcaf41b4c0aab6e';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_ai_summary_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable [ConditionsAiSummaryRepository] token for presentation and tests.

@ProviderFor(conditionsAiSummaryRepository)
final conditionsAiSummaryRepositoryProvider =
    ConditionsAiSummaryRepositoryProvider._();

/// Injectable [ConditionsAiSummaryRepository] token for presentation and tests.

final class ConditionsAiSummaryRepositoryProvider
    extends
        $FunctionalProvider<
          ConditionsAiSummaryRepository,
          ConditionsAiSummaryRepository,
          ConditionsAiSummaryRepository
        >
    with $Provider<ConditionsAiSummaryRepository> {
  /// Injectable [ConditionsAiSummaryRepository] token for presentation and tests.
  ConditionsAiSummaryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionsAiSummaryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionsAiSummaryRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConditionsAiSummaryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConditionsAiSummaryRepository create(Ref ref) {
    return conditionsAiSummaryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionsAiSummaryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionsAiSummaryRepository>(
        value,
      ),
    );
  }
}

String _$conditionsAiSummaryRepositoryHash() =>
    r'6c2e95fa1b4fd487160eb58975ba6519c9dd6731';

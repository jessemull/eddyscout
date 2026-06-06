// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_ai_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable [ConditionsAiSummaryRepository] for tests and overrides.

@ProviderFor(conditionsAiSummaryRepository)
final conditionsAiSummaryRepositoryProvider =
    ConditionsAiSummaryRepositoryProvider._();

/// Injectable [ConditionsAiSummaryRepository] for tests and overrides.

final class ConditionsAiSummaryRepositoryProvider
    extends
        $FunctionalProvider<
          ConditionsAiSummaryRepository,
          ConditionsAiSummaryRepository,
          ConditionsAiSummaryRepository
        >
    with $Provider<ConditionsAiSummaryRepository> {
  /// Injectable [ConditionsAiSummaryRepository] for tests and overrides.
  ConditionsAiSummaryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionsAiSummaryRepositoryProvider',
        isAutoDispose: true,
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
    r'4bed46a87a6a99ec7d11be53b6c8d6f4bd35233d';

/// Notifier for the conditions AI summary card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).

@ProviderFor(ConditionsAiSummary)
final conditionsAiSummaryProvider = ConditionsAiSummaryFamily._();

/// Notifier for the conditions AI summary card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).
final class ConditionsAiSummaryProvider
    extends $NotifierProvider<ConditionsAiSummary, ConditionsAiSummaryState> {
  /// Notifier for the conditions AI summary card.
  ///
  /// Keep-alive preserves card state when navigating away from launch detail
  /// and back within the same app session (matches pre-codegen behavior).
  ConditionsAiSummaryProvider._({
    required ConditionsAiSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conditionsAiSummaryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conditionsAiSummaryHash();

  @override
  String toString() {
    return r'conditionsAiSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConditionsAiSummary create() => ConditionsAiSummary();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConditionsAiSummaryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConditionsAiSummaryState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConditionsAiSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conditionsAiSummaryHash() =>
    r'dea0bf40b7132201527dde7ed83714985d3fa4f6';

/// Notifier for the conditions AI summary card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).

final class ConditionsAiSummaryFamily extends $Family
    with
        $ClassFamilyOverride<
          ConditionsAiSummary,
          ConditionsAiSummaryState,
          ConditionsAiSummaryState,
          ConditionsAiSummaryState,
          String
        > {
  ConditionsAiSummaryFamily._()
    : super(
        retry: null,
        name: r'conditionsAiSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Notifier for the conditions AI summary card.
  ///
  /// Keep-alive preserves card state when navigating away from launch detail
  /// and back within the same app session (matches pre-codegen behavior).

  ConditionsAiSummaryProvider call(String launchId) =>
      ConditionsAiSummaryProvider._(argument: launchId, from: this);

  @override
  String toString() => r'conditionsAiSummaryProvider';
}

/// Notifier for the conditions AI summary card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).

abstract class _$ConditionsAiSummary
    extends $Notifier<ConditionsAiSummaryState> {
  late final _$args = ref.$arg as String;
  String get launchId => _$args;

  ConditionsAiSummaryState build(String launchId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ConditionsAiSummaryState, ConditionsAiSummaryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConditionsAiSummaryState, ConditionsAiSummaryState>,
              ConditionsAiSummaryState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

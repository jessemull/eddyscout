// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_queue_filters_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pending queue filter state for the moderation screen.

@ProviderFor(ModerationPendingFilters)
final moderationPendingFiltersProvider = ModerationPendingFiltersProvider._();

/// Pending queue filter state for the moderation screen.
final class ModerationPendingFiltersProvider
    extends
        $NotifierProvider<
          ModerationPendingFilters,
          ModerationPendingFiltersState
        > {
  /// Pending queue filter state for the moderation screen.
  ModerationPendingFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderationPendingFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderationPendingFiltersHash();

  @$internal
  @override
  ModerationPendingFilters create() => ModerationPendingFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModerationPendingFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModerationPendingFiltersState>(
        value,
      ),
    );
  }
}

String _$moderationPendingFiltersHash() =>
    r'8dae501cc58523f7a3d35098fbb88ea3390284a1';

/// Pending queue filter state for the moderation screen.

abstract class _$ModerationPendingFilters
    extends $Notifier<ModerationPendingFiltersState> {
  ModerationPendingFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ModerationPendingFiltersState,
              ModerationPendingFiltersState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ModerationPendingFiltersState,
                ModerationPendingFiltersState
              >,
              ModerationPendingFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// History filter state for the moderation screen.

@ProviderFor(ModerationHistoryFilters)
final moderationHistoryFiltersProvider = ModerationHistoryFiltersProvider._();

/// History filter state for the moderation screen.
final class ModerationHistoryFiltersProvider
    extends
        $NotifierProvider<
          ModerationHistoryFilters,
          ModerationHistoryFiltersState
        > {
  /// History filter state for the moderation screen.
  ModerationHistoryFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderationHistoryFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderationHistoryFiltersHash();

  @$internal
  @override
  ModerationHistoryFilters create() => ModerationHistoryFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModerationHistoryFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModerationHistoryFiltersState>(
        value,
      ),
    );
  }
}

String _$moderationHistoryFiltersHash() =>
    r'661e7c90fa47ce181aa421c6b5291979731378fb';

/// History filter state for the moderation screen.

abstract class _$ModerationHistoryFilters
    extends $Notifier<ModerationHistoryFiltersState> {
  ModerationHistoryFiltersState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ModerationHistoryFiltersState,
              ModerationHistoryFiltersState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ModerationHistoryFiltersState,
                ModerationHistoryFiltersState
              >,
              ModerationHistoryFiltersState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

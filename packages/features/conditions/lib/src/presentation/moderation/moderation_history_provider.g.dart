// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Moderation audit history rows.

@ProviderFor(ModerationHistory)
final moderationHistoryProvider = ModerationHistoryProvider._();

/// Moderation audit history rows.
final class ModerationHistoryProvider
    extends
        $AsyncNotifierProvider<
          ModerationHistory,
          List<ModerationHistoryReport>
        > {
  /// Moderation audit history rows.
  ModerationHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderationHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderationHistoryHash();

  @$internal
  @override
  ModerationHistory create() => ModerationHistory();
}

String _$moderationHistoryHash() => r'308bf1aa2ea127f7b4926b1e92af7decbda2c9e0';

/// Moderation audit history rows.

abstract class _$ModerationHistory
    extends $AsyncNotifier<List<ModerationHistoryReport>> {
  FutureOr<List<ModerationHistoryReport>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ModerationHistoryReport>>,
              List<ModerationHistoryReport>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ModerationHistoryReport>>,
                List<ModerationHistoryReport>
              >,
              AsyncValue<List<ModerationHistoryReport>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

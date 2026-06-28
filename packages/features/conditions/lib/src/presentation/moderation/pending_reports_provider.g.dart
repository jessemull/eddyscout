// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Held condition reports awaiting moderator action.

@ProviderFor(ModerationPendingReports)
final moderationPendingReportsProvider = ModerationPendingReportsProvider._();

/// Held condition reports awaiting moderator action.
final class ModerationPendingReportsProvider
    extends
        $AsyncNotifierProvider<
          ModerationPendingReports,
          List<ModerationQueueReport>
        > {
  /// Held condition reports awaiting moderator action.
  ModerationPendingReportsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderationPendingReportsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderationPendingReportsHash();

  @$internal
  @override
  ModerationPendingReports create() => ModerationPendingReports();
}

String _$moderationPendingReportsHash() =>
    r'08990d61f8b0aaef254e1e8c2489ccc26ca7736c';

/// Held condition reports awaiting moderator action.

abstract class _$ModerationPendingReports
    extends $AsyncNotifier<List<ModerationQueueReport>> {
  FutureOr<List<ModerationQueueReport>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ModerationQueueReport>>,
              List<ModerationQueueReport>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ModerationQueueReport>>,
                List<ModerationQueueReport>
              >,
              AsyncValue<List<ModerationQueueReport>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

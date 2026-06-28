// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Selected pending report ids for bulk moderation actions.

@ProviderFor(ModerationSelection)
final moderationSelectionProvider = ModerationSelectionProvider._();

/// Selected pending report ids for bulk moderation actions.
final class ModerationSelectionProvider
    extends $NotifierProvider<ModerationSelection, Set<String>> {
  /// Selected pending report ids for bulk moderation actions.
  ModerationSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderationSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderationSelectionHash();

  @$internal
  @override
  ModerationSelection create() => ModerationSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$moderationSelectionHash() =>
    r'38d9cc4028dbd29c4264d6d6660b65de939d125c';

/// Selected pending report ids for bulk moderation actions.

abstract class _$ModerationSelection extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

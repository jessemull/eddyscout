// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_reports_digest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for the launch reports digest card.

@ProviderFor(LaunchReportsDigest)
final launchReportsDigestProvider = LaunchReportsDigestFamily._();

/// Notifier for the launch reports digest card.
final class LaunchReportsDigestProvider
    extends $NotifierProvider<LaunchReportsDigest, LaunchReportsDigestState> {
  /// Notifier for the launch reports digest card.
  LaunchReportsDigestProvider._({
    required LaunchReportsDigestFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'launchReportsDigestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$launchReportsDigestHash();

  @override
  String toString() {
    return r'launchReportsDigestProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LaunchReportsDigest create() => LaunchReportsDigest();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchReportsDigestState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchReportsDigestState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LaunchReportsDigestProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$launchReportsDigestHash() =>
    r'78a6bbe427663617a1d904a4a8bb5c290c930550';

/// Notifier for the launch reports digest card.

final class LaunchReportsDigestFamily extends $Family
    with
        $ClassFamilyOverride<
          LaunchReportsDigest,
          LaunchReportsDigestState,
          LaunchReportsDigestState,
          LaunchReportsDigestState,
          String
        > {
  LaunchReportsDigestFamily._()
    : super(
        retry: null,
        name: r'launchReportsDigestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Notifier for the launch reports digest card.

  LaunchReportsDigestProvider call(String launchId) =>
      LaunchReportsDigestProvider._(argument: launchId, from: this);

  @override
  String toString() => r'launchReportsDigestProvider';
}

/// Notifier for the launch reports digest card.

abstract class _$LaunchReportsDigest
    extends $Notifier<LaunchReportsDigestState> {
  late final _$args = ref.$arg as String;
  String get launchId => _$args;

  LaunchReportsDigestState build(String launchId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<LaunchReportsDigestState, LaunchReportsDigestState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LaunchReportsDigestState, LaunchReportsDigestState>,
              LaunchReportsDigestState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

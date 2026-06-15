// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_reports_digest_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for the launch reports digest card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).

@ProviderFor(LaunchReportsDigest)
final launchReportsDigestProvider = LaunchReportsDigestFamily._();

/// Notifier for the launch reports digest card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).
final class LaunchReportsDigestProvider
    extends $NotifierProvider<LaunchReportsDigest, LaunchReportsDigestState> {
  /// Notifier for the launch reports digest card.
  ///
  /// Keep-alive preserves card state when navigating away from launch detail
  /// and back within the same app session (matches pre-codegen behavior).
  LaunchReportsDigestProvider._({
    required LaunchReportsDigestFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'launchReportsDigestProvider',
         isAutoDispose: false,
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
    r'b44fbe47ad1e87d0b2d51429a7e0bf9ae21ac014';

/// Notifier for the launch reports digest card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).

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
        isAutoDispose: false,
      );

  /// Notifier for the launch reports digest card.
  ///
  /// Keep-alive preserves card state when navigating away from launch detail
  /// and back within the same app session (matches pre-codegen behavior).

  LaunchReportsDigestProvider call(String launchId) =>
      LaunchReportsDigestProvider._(argument: launchId, from: this);

  @override
  String toString() => r'launchReportsDigestProvider';
}

/// Notifier for the launch reports digest card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).

abstract class _$LaunchReportsDigest
    extends $Notifier<LaunchReportsDigestState> {
  late final _$args = ref.$arg as String;
  String get launchId => _$args;

  LaunchReportsDigestState build(String launchId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, () => build(_$args));
  }
}

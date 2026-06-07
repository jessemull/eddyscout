// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_client_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Application-wide analytics client.
///
/// Debug builds log to console; release builds use [NoOpAnalyticsClient].

@ProviderFor(analyticsClient)
final analyticsClientProvider = AnalyticsClientProvider._();

/// Application-wide analytics client.
///
/// Debug builds log to console; release builds use [NoOpAnalyticsClient].

final class AnalyticsClientProvider
    extends
        $FunctionalProvider<AnalyticsClient, AnalyticsClient, AnalyticsClient>
    with $Provider<AnalyticsClient> {
  /// Application-wide analytics client.
  ///
  /// Debug builds log to console; release builds use [NoOpAnalyticsClient].
  AnalyticsClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsClientHash();

  @$internal
  @override
  $ProviderElement<AnalyticsClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsClient create(Ref ref) {
    return analyticsClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsClient>(value),
    );
  }
}

String _$analyticsClientHash() => r'061b354d361c7c9eab43e5c071f907a0db66f676';

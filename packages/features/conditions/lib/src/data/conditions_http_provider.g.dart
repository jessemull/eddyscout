// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions_http_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared conditions HTTP client (Dio-backed).

@ProviderFor(conditionsHttpClient)
final conditionsHttpClientProvider = ConditionsHttpClientProvider._();

/// Shared conditions HTTP client (Dio-backed).

final class ConditionsHttpClientProvider
    extends
        $FunctionalProvider<
          EddyScoutHttpClient,
          EddyScoutHttpClient,
          EddyScoutHttpClient
        >
    with $Provider<EddyScoutHttpClient> {
  /// Shared conditions HTTP client (Dio-backed).
  ConditionsHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conditionsHttpClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conditionsHttpClientHash();

  @$internal
  @override
  $ProviderElement<EddyScoutHttpClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EddyScoutHttpClient create(Ref ref) {
    return conditionsHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EddyScoutHttpClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EddyScoutHttpClient>(value),
    );
  }
}

String _$conditionsHttpClientHash() =>
    r'6c2f80ed25e585c717d633fc4d1e647f90e7024e';

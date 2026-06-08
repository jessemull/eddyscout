// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpx_file_gateway_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Injectable GPX file gateway for presentation and tests.

@ProviderFor(gpxFileGateway)
final gpxFileGatewayProvider = GpxFileGatewayProvider._();

/// Injectable GPX file gateway for presentation and tests.

final class GpxFileGatewayProvider
    extends $FunctionalProvider<GpxFileGateway, GpxFileGateway, GpxFileGateway>
    with $Provider<GpxFileGateway> {
  /// Injectable GPX file gateway for presentation and tests.
  GpxFileGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gpxFileGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gpxFileGatewayHash();

  @$internal
  @override
  $ProviderElement<GpxFileGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GpxFileGateway create(Ref ref) {
    return gpxFileGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GpxFileGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GpxFileGateway>(value),
    );
  }
}

String _$gpxFileGatewayHash() => r'92ab01e59de89aab876692360645aaeb0e28cca8';

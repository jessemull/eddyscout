// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpx_file_gateway.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gpxFileGateway)
final gpxFileGatewayProvider = GpxFileGatewayProvider._();

final class GpxFileGatewayProvider
    extends $FunctionalProvider<GpxFileGateway, GpxFileGateway, GpxFileGateway>
    with $Provider<GpxFileGateway> {
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

String _$gpxFileGatewayHash() => r'0cab3b74de0ad2d4dbd3d3906a804c79cf5a76e3';

import 'package:eddyscout_map/src/domain/gpx_file_gateway.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gpx_file_gateway_provider.g.dart';

/// Injectable GPX file gateway for presentation and tests.
@Riverpod(keepAlive: true)
GpxFileGateway gpxFileGateway(Ref ref) {
  throw UnimplementedError(
    'Override gpxFileGatewayProvider in ProviderScope.',
  );
}

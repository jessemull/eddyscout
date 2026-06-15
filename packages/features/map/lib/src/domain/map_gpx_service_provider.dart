import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/domain/map_gpx_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_gpx_service_provider.g.dart';

/// Override in the app shell with a hydro-backed [MapGpxService].
@Riverpod(keepAlive: true, retry: disableProviderRetry)
Future<MapGpxService> mapGpxService(Ref ref) async {
  throw UnimplementedError(
    'Override mapGpxServiceProvider in ProviderScope (app shell).',
  );
}

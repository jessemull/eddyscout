import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/domain/map_route_planner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_route_planner_provider.g.dart';

/// Override in the app shell with a hydro-backed [MapRoutePlanner].
@Riverpod(keepAlive: true, retry: disableProviderRetry)
Future<MapRoutePlanner> mapRoutePlanner(Ref ref) async {
  throw UnimplementedError(
    'Override mapRoutePlannerProvider in ProviderScope (app shell).',
  );
}

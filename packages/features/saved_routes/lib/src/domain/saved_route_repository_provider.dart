import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_route_repository_provider.g.dart';

/// Injectable [SavedRouteRepository] token for presentation and tests.
@Riverpod(keepAlive: true)
SavedRouteRepository savedRouteRepository(Ref ref) {
  throw UnimplementedError(
    'Override savedRouteRepositoryProvider in ProviderScope '
    '(see apps/eddyscout/lib/routing/saved_routes_database_override.dart).',
  );
}

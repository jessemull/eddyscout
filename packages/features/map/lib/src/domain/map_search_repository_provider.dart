import 'package:eddyscout_map/src/domain/launch_points.dart';
import 'package:eddyscout_map/src/domain/map_search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_search_repository_provider.g.dart';

/// Bundled launch search repository for the map overlay.
@Riverpod(keepAlive: true)
MapSearchRepository mapSearchRepository(Ref ref) {
  return const LocalMapSearchRepository(kLaunchPoints);
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/map_search_repository_provider.dart';
import '../domain/map_search_result.dart';

part 'map_search_provider.g.dart';

/// Whether the full-screen search overlay is visible.
@Riverpod(keepAlive: true)
class MapSearchOverlayVisible extends _$MapSearchOverlayVisible {
  @override
  bool build() => false;

  void show() => state = true;

  void hide() {
    state = false;
    ref.read(mapSearchQueryProvider.notifier).clear();
  }
}

/// Search query text from the floating field.
@Riverpod(keepAlive: true)
class MapSearchQuery extends _$MapSearchQuery {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties — Riverpod notifier API
  void changeQuery(String value) => state = value;

  void clear() => state = '';
}

/// Local launch hits for the current query.
@riverpod
List<MapSearchHitLaunch> mapSearchLaunchHits(Ref ref) {
  final query = ref.watch(mapSearchQueryProvider);
  if (query.trim().isEmpty) {
    return const [];
  }
  final repository = ref.watch(mapSearchRepositoryProvider);
  return repository.searchLaunches(query).map(MapSearchHitLaunch.new).toList();
}

/// Remote geocoding hits (stub until Mapbox Search is integrated).
@riverpod
Future<List<MapSearchHitPlace>> mapSearchPlaceHits(
  Ref ref,
  String query,
) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    return const [];
  }
  final repository = ref.read(mapSearchRepositoryProvider);
  final places = await repository.searchPlaces(trimmed);
  return places.map(MapSearchHitPlace.new).toList();
}

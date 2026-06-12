import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/map_search_repository_provider.dart';
import '../domain/map_search_result.dart';

part 'map_search_provider.g.dart';

/// Why map search is open — affects what happens on result selection.
enum MapSearchContext {
  /// Pick a launch to show the place peek sheet.
  browse,

  /// Add the next waypoint while route planning.
  addStop,
}

/// Whether inline map search is expanded at the top of the map.
@Riverpod(keepAlive: true)
class MapSearchExpanded extends _$MapSearchExpanded {
  @override
  bool build() => false;

  void expand() => state = true;

  void collapse() {
    state = false;
    ref.read(mapSearchQueryProvider.notifier).clear();
    ref.read(mapPlanningInlineAddStopProvider.notifier).hide();
  }
}

/// Whether the edit-stops panel shows an inline add-stop search row (2+ stops).
@Riverpod(keepAlive: true)
class MapPlanningInlineAddStop extends _$MapPlanningInlineAddStop {
  @override
  bool build() => false;

  void show() => state = true;

  void hide() => state = false;
}

/// Whether browse search should cover the map with full-screen results.
@riverpod
bool mapBrowseSearchFullScreen(Ref ref) {
  final query = ref.watch(mapSearchQueryProvider).trim();
  if (query.isEmpty) {
    return false;
  }
  final launchHits = ref.watch(mapSearchLaunchHitsProvider);
  if (launchHits.isNotEmpty) {
    return true;
  }
  final placeHits = ref.watch(mapSearchPlaceHitsProvider(query));
  return placeHits.hasValue;
}

/// Selection context for the active search session.
@Riverpod(keepAlive: true)
class MapSearchContextState extends _$MapSearchContextState {
  @override
  MapSearchContext build() => MapSearchContext.browse;

  void setBrowse() => state = MapSearchContext.browse;

  void setAddStop() => state = MapSearchContext.addStop;
}

/// Search query text from the search field.
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

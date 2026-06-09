import 'package:eddyscout_core/eddyscout_core.dart';

import 'package:eddyscout_map/src/domain/map_search_result.dart';

/// Local launch search plus optional geocoding.
///
/// Phase 2 geocoding stub returns no places until Mapbox Search ships.
abstract interface class MapSearchRepository {
  /// Searches curated launches by name, river, and notes.
  List<LaunchSearchResult> searchLaunches(String query);

  /// Searches remote places; stub returns empty until Mapbox Search ships.
  Future<List<GeocodedSearchResult>> searchPlaces(String query);
}

/// In-memory launch filter with a no-op geocoding stub.
final class LocalMapSearchRepository implements MapSearchRepository {
  /// Creates a repository backed by [launches].
  const LocalMapSearchRepository(this.launches);

  /// Curated launches to search.
  final List<LaunchPoint> launches;

  @override
  List<LaunchSearchResult> searchLaunches(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return [];
    }
    final hits = <LaunchSearchResult>[];
    for (final launch in launches) {
      final haystack =
          '${launch.name} ${launch.riverSystem.name} ${launch.shortNote}'
              .toLowerCase();
      if (haystack.contains(trimmed)) {
        hits.add(LaunchSearchResult(launch));
      }
    }
    hits.sort(
      (a, b) => a.launch.name.toLowerCase().compareTo(
        b.launch.name.toLowerCase(),
      ),
    );
    return hits;
  }

  @override
  Future<List<GeocodedSearchResult>> searchPlaces(String query) async {
    // Phase 2: wire Mapbox Geocoding API after dependency approval.
    return const [];
  }
}

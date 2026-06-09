import 'package:eddyscout_core/eddyscout_core.dart';

/// A curated launch matching local search.
final class LaunchSearchResult {
  /// Creates a launch search hit.
  const LaunchSearchResult(this.launch);

  /// Matching launch from the bundled catalog.
  final LaunchPoint launch;
}

/// A geocoded place from a remote search provider (Phase 2+).
final class GeocodedSearchResult {
  /// Creates a geocoded place hit.
  const GeocodedSearchResult({
    required this.name,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });

  /// Primary place label.
  final String name;

  /// Secondary context (city, region, etc.).
  final String subtitle;

  /// WGS84 latitude.
  final double latitude;

  /// WGS84 longitude.
  final double longitude;
}

/// Unified map search hit for overlay rendering.
sealed class MapSearchHit {
  /// Creates a map search hit.
  const MapSearchHit();
}

/// Local launch catalog hit.
final class MapSearchHitLaunch extends MapSearchHit {
  /// Creates a launch catalog hit.
  const MapSearchHitLaunch(this.result);

  /// Launch search result.
  final LaunchSearchResult result;
}

/// Remote geocoding hit (empty until Mapbox Search is approved).
final class MapSearchHitPlace extends MapSearchHit {
  /// Creates a geocoded place hit wrapper.
  const MapSearchHitPlace(this.result);

  /// Geocoded place result.
  final GeocodedSearchResult result;
}

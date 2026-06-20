import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const launch = LaunchPoint(
    id: 'launch-a',
    name: 'Test Launch',
    latitude: 45.5,
    longitude: -122.6,
    shortNote: 'Note',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );

  test('LaunchSearchResult wraps launch catalog hit', () {
    const result = LaunchSearchResult(launch);
    expect(result.launch, launch);
  });

  test('GeocodedSearchResult stores place fields', () {
    const result = GeocodedSearchResult(
      name: 'Portland',
      subtitle: 'Oregon',
      latitude: 45.5,
      longitude: -122.6,
    );

    expect(result.name, 'Portland');
    expect(result.subtitle, 'Oregon');
    expect(result.latitude, 45.5);
    expect(result.longitude, -122.6);
  });

  test('MapSearchHit variants wrap launch and place results', () {
    const launchHit = MapSearchHitLaunch(LaunchSearchResult(launch));
    const placeHit = MapSearchHitPlace(
      GeocodedSearchResult(
        name: 'Portland',
        subtitle: 'Oregon',
        latitude: 45.5,
        longitude: -122.6,
      ),
    );

    expect(launchHit.result.launch, launch);
    expect(placeHit.result.name, 'Portland');
  });
}

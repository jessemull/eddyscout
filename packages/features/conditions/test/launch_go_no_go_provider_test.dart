import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('launchGoNoGoResultProvider evaluates from snapshot', () {
    final launch = LaunchPoint(
      id: 'test_launch',
      name: 'Test',
      latitude: 45.5,
      longitude: -122.6,
      shortNote: 'note',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
    );
    final snapshot = ConditionsSnapshot(
      fetchedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
      weather: WeatherConditions(
        temperatureF: 55,
        windSpeedMph: 5,
        windGustMph: 6,
        windDirection: 'N',
        shortForecast: 'Fair',
        periodStart: DateTime.parse('2026-06-15T12:00:00-07:00'),
        source: WeatherDataSource.nws,
      ),
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = container.read(
      launchGoNoGoResultProvider((
        launch: launch,
        snapshot: snapshot,
        profile: GoNoGoProfile.intermediate,
      )),
    );

    expect(result.verdict, GoNoGoVerdict.go);
  });
}

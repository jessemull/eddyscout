import 'package:flutter_test/flutter_test.dart';

import 'package:eddyscout/conditions/conditions_models.dart';
import 'package:eddyscout/data/launch_models.dart';
import 'package:eddyscout/decision/go_no_go.dart';
import 'package:eddyscout/firebase/conditions_summary_payload.dart';

void main() {
  test('conditionsSummaryPayload includes launch, snapshot, goNoGo keys', () {
    final launch = LaunchPoint(
      id: 'x',
      name: 'X',
      latitude: 1,
      longitude: 2,
      shortNote: 'n',
      riverSystem: RiverSystem.willamette,
      windExposure: WindExposure.moderate,
      tideRelevance: TideRelevance.none,
      flowBands: const LaunchFlowBands(cfsComfortMax: 100),
    );
    final snap = ConditionsSnapshot(
      fetchedAt: DateTime.utc(2026, 6, 1, 18),
      weather: WeatherConditions(
        temperatureF: 60,
        windSpeedMph: 5,
        windGustMph: null,
        windDirection: 'NW',
        shortForecast: 'Clear',
        periodStart: DateTime.utc(2026, 6, 1, 19),
        source: WeatherDataSource.nws,
      ),
    );
    final go = GoNoGoEvaluator.evaluate(launch, snap);
    final json = conditionsSummaryPayload(
      launch: launch,
      snapshot: snap,
      goNoGo: go,
      skillProfile: GoNoGoProfile.intermediate,
    );

    expect(json.containsKey('launch'), true);
    expect(json.containsKey('snapshot'), true);
    expect(json.containsKey('goNoGo'), true);
    final launchMap = json['launch']! as Map<String, Object?>;
    expect(launchMap['skillProfile'], 'intermediate');
    expect(launchMap['flowBands'], isA<Map>());
    final snapMap = json['snapshot']! as Map<String, Object?>;
    expect(snapMap['fetchedAt'], '2026-06-01T18:00:00.000Z');
    final wx = snapMap['weather']! as Map<String, Object?>;
    expect(wx['source'], 'nws');
    final gg = json['goNoGo']! as Map<String, Object?>;
    expect(gg['verdict'], isNotNull);
    expect(gg['reasons'], isA<List>());
  });
}

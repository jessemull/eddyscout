import 'package:eddyscout/conditions/conditions_models.dart';
import 'package:eddyscout/data/launch_models.dart';
import 'package:eddyscout/decision/go_no_go.dart';
import 'package:eddyscout/firebase/conditions_ai_summary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConditionsAiSummaryRepository extends Mock
    implements ConditionsAiSummaryRepository {}

LaunchPoint _launch() {
  return const LaunchPoint(
    id: 'cathedral_park',
    name: 'Cathedral Park Boat Ramp',
    latitude: 45.5621,
    longitude: -122.7328,
    shortNote: 'Test',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.minor,
  );
}

ConditionsSnapshot _snapshot() {
  return ConditionsSnapshot(
    fetchedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
    weather: null,
    weatherError: 'offline',
  );
}

GoNoGoResult _goNoGo() {
  return GoNoGoResult(
    verdict: GoNoGoVerdict.marginal,
    reasons: const [],
    computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
  );
}

void main() {
  group('conditionsAiSummaryProvider', () {
    late _MockConditionsAiSummaryRepository repository;
    late LaunchPoint launch;
    late ConditionsSnapshot snapshot;
    late GoNoGoResult goNoGo;

    setUp(() {
      repository = _MockConditionsAiSummaryRepository();
      launch = _launch();
      snapshot = _snapshot();
      goNoGo = _goNoGo();
    });

    test('starts idle until summarize is called', () {
      final container = ProviderContainer(
        overrides: [
          conditionsAiSummaryRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(
        conditionsAiSummaryProvider('cathedral_park'),
      );

      expect(state.isIdle, isTrue);
    });

    test('summarize stores summary text', () async {
      when(
        () => repository.summarize(
          launch: launch,
          snapshot: snapshot,
          goNoGo: goNoGo,
          skillProfile: GoNoGoProfile.intermediate,
        ),
      ).thenAnswer((_) async => 'Calm morning on the Willamette.');

      final container = ProviderContainer(
        overrides: [
          conditionsAiSummaryRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(conditionsAiSummaryProvider('cathedral_park').notifier)
          .summarize(
            launch: launch,
            snapshot: snapshot,
            goNoGo: goNoGo,
            skillProfile: GoNoGoProfile.intermediate,
          );

      expect(
        container.read(conditionsAiSummaryProvider('cathedral_park')).summary,
        'Calm morning on the Willamette.',
      );
    });

    test('summarize stores error message on failure', () async {
      when(
        () => repository.summarize(
          launch: launch,
          snapshot: snapshot,
          goNoGo: goNoGo,
          skillProfile: GoNoGoProfile.intermediate,
        ),
      ).thenThrow(Exception('callable failed'));

      final container = ProviderContainer(
        overrides: [
          conditionsAiSummaryRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(conditionsAiSummaryProvider('cathedral_park').notifier)
          .summarize(
            launch: launch,
            snapshot: snapshot,
            goNoGo: goNoGo,
            skillProfile: GoNoGoProfile.intermediate,
          );

      expect(
        container
            .read(conditionsAiSummaryProvider('cathedral_park'))
            .errorMessage,
        contains('callable failed'),
      );
    });
  });
}

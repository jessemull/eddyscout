import 'package:eddyscout/conditions/conditions_models.dart';
import 'package:eddyscout/conditions/conditions_provider.dart';
import 'package:eddyscout/conditions/conditions_service.dart';
import 'package:eddyscout/data/launch_models.dart';
import 'package:eddyscout/data/launch_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConditionsService extends Mock implements ConditionsService {}

void main() {
  group('launchPointByIdProvider', () {
    test('returns curated launch for known id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final launch = container.read(launchPointByIdProvider('cathedral_park'));

      expect(launch.name, 'Cathedral Park Boat Ramp');
    });

    test('throws for unknown id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(launchPointByIdProvider('missing_launch')),
        throwsStateError,
      );
    });
  });

  group('conditionsSnapshotProvider', () {
    late _MockConditionsService service;

    setUp(() {
      service = _MockConditionsService();
    });

    test('loads snapshot via injected service', () async {
      final launch = kLaunchPoints.first;
      final snapshot = ConditionsSnapshot(
        fetchedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
        weather: null,
        weatherError: 'offline',
      );
      when(() => service.load(launch)).thenAnswer((_) async => snapshot);

      final container = ProviderContainer(
        overrides: [conditionsServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        conditionsSnapshotProvider(launch.id).future,
      );

      expect(result, snapshot);
      verify(() => service.load(launch)).called(1);
    });
  });
}

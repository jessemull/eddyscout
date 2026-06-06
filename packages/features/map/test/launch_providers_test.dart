import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('launchPointByIdProvider', () {
    test('returns curated launch for known id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(launchPointByIdProvider('cathedral_park'));

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull?.name, 'Cathedral Park Boat Ramp');
    });

    test('returns NotFoundFailure for unknown id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = container.read(launchPointByIdProvider('missing_launch'));

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<NotFoundFailure>());
      expect(
        result.errorOrNull?.message,
        'No launch with id: missing_launch',
      );
    });

    test('delegates to findLaunchPointById for known ids', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final id = kLaunchPoints.first.id;
      final result = container.read(launchPointByIdProvider(id));

      expect(result.valueOrNull, findLaunchPointById(id));
    });
  });

  group('readLaunchPointIfExists', () {
    test('returns launch for known id via Ref', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final launch = container.read(
        _launchLookupProbeProvider('cathedral_park'),
      );

      expect(launch?.name, 'Cathedral Park Boat Ramp');
    });

    testWidgets('returns launch for known id', (tester) async {
      LaunchPoint? launch;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              launch = ref.readLaunchPointIfExists('cathedral_park');
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(launch, isNotNull);
      expect(launch!.name, 'Cathedral Park Boat Ramp');
    });

    testWidgets('returns null for unknown id', (tester) async {
      LaunchPoint? launch;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              launch = ref.readLaunchPointIfExists('missing_launch');
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(launch, isNull);
    });
  });
}

final Provider<LaunchPoint?> Function(String) _launchLookupProbeProvider =
    Provider.family<LaunchPoint?, String>(
      (ref, id) => ref.readLaunchPointIfExists(id),
    );

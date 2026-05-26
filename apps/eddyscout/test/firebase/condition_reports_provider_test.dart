import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConditionReportsRepository extends Mock
    implements ConditionReportsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(CancelToken());
  });

  group('conditionReportsListProvider', () {
    late _MockConditionReportsRepository repository;

    setUp(() {
      repository = _MockConditionReportsRepository();
    });

    test('loads reports from repository', () async {
      final reports = [
        ConditionReportListItem(
          message: 'Windy',
          createdAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
          isMine: true,
        ),
      ];
      when(
        () => repository.listReports(
          'cathedral_park',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Result.success(reports));

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        conditionReportsListProvider('cathedral_park').future,
      );

      expect(result, reports);
    });

    test('refetches when refresh token changes', () async {
      when(
        () => repository.listReports(
          'cathedral_park',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => const Result.success([]));

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(
        conditionReportsListProvider('cathedral_park').future,
      );
      container.read(conditionReportsRefreshTokenProvider.notifier).increment();
      await container.read(
        conditionReportsListProvider('cathedral_park').future,
      );

      verify(
        () => repository.listReports(
          'cathedral_park',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(2);
    });
  });

  group('launchReportsDigestProvider', () {
    late _MockConditionReportsRepository repository;

    setUp(() {
      repository = _MockConditionReportsRepository();
    });

    test('starts idle until summarize is called', () {
      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(
        launchReportsDigestProvider('cathedral_park'),
      );

      expect(state.isIdle, isTrue);
    });

    test('summarize stores result', () async {
      const result = LaunchReportsDigestResult(
        digestText: 'Calm morning.',
        cached: false,
        noReports: false,
      );
      when(
        () => repository.summarizeLaunchReports(
          launchId: 'cathedral_park',
          forceRefresh: false,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => const Result.success(result));

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(launchReportsDigestProvider('cathedral_park').notifier)
          .summarize();

      expect(
        container.read(launchReportsDigestProvider('cathedral_park')).result,
        result,
      );
    });

    test('summarize stores error message on failure', () async {
      when(
        () => repository.summarizeLaunchReports(
          launchId: 'cathedral_park',
          forceRefresh: false,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Result.failure(
          NetworkFailure(message: 'network down'),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(launchReportsDigestProvider('cathedral_park').notifier)
          .summarize();

      expect(
        container
            .read(launchReportsDigestProvider('cathedral_park'))
            .errorMessage,
        'network down',
      );
    });
  });
}

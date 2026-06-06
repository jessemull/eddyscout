import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/condition_report_submit_provider.dart';
import 'package:eddyscout_conditions/src/data/condition_reports_provider.dart';
import 'package:eddyscout_conditions/src/data/conditions_ai_summary_provider.dart';
import 'package:eddyscout_conditions/src/data/conditions_provider.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_refresh_token_provider.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_repository_provider.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_report_submit_repository.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_reports_repository.dart';
import 'package:eddyscout_conditions/src/domain/repositories/conditions_ai_summary_repository.dart';
import 'package:eddyscout_conditions/src/domain/repositories/conditions_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConditionsRepository extends Mock implements ConditionsRepository {}

class _MockConditionReportSubmitRepository extends Mock
    implements ConditionReportSubmitRepository {}

class _MockConditionReportsRepository extends Mock
    implements ConditionReportsRepository {}

class _MockConditionsAiSummaryRepository extends Mock
    implements ConditionsAiSummaryRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const LaunchPoint(
        id: 'id',
        name: 'n',
        latitude: 0,
        longitude: 0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      ),
    );
    registerFallbackValue(ConditionsSnapshot(fetchedAt: DateTime(2026)));
    registerFallbackValue(
      GoNoGoResult(
        verdict: GoNoGoVerdict.go,
        reasons: const [],
        computedAt: DateTime(2026),
      ),
    );
    registerFallbackValue(GoNoGoProfile.beginner);
  });

  group('conditionsSnapshotProvider', () {
    test('returns snapshot on success', () async {
      final repo = _MockConditionsRepository();
      final launch = const LaunchPoint(
        id: 'id',
        name: 'n',
        latitude: 0,
        longitude: 0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      );
      final snapshot = ConditionsSnapshot(
        fetchedAt: DateTime(2026),
        weather: const WeatherConditions(source: WeatherDataSource.nws),
      );
      when(
        () => repo.load(launch, cancelToken: any(named: 'cancelToken')),
      ).thenAnswer(
        (_) async => Result.success(snapshot),
      );

      final container = ProviderContainer(
        overrides: [
          conditionsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final value = await container.read(
        conditionsSnapshotProvider(launch).future,
      );
      expect(value.weather?.source, WeatherDataSource.nws);
    });

    test('throws AppFailure on failure', () async {
      final repo = _MockConditionsRepository();
      final launch = const LaunchPoint(
        id: 'id',
        name: 'n',
        latitude: 0,
        longitude: 0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      );
      when(
        () => repo.load(launch, cancelToken: any(named: 'cancelToken')),
      ).thenAnswer(
        (_) async => const Result.failure(NetworkFailure(message: 'down')),
      );

      final container = ProviderContainer(
        overrides: [
          conditionsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(conditionsSnapshotProvider(launch).future),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('cancels in-flight request when disposed', () async {
      final repo = _MockConditionsRepository();
      final launch = const LaunchPoint(
        id: 'id',
        name: 'n',
        latitude: 0,
        longitude: 0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      );

      CancelToken? captured;
      final never = Completer<Result<ConditionsSnapshot, AppFailure>>();
      when(
        () => repo.load(launch, cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((invocation) {
        captured = invocation.namedArguments[#cancelToken] as CancelToken?;
        return never.future;
      });

      final container = ProviderContainer(
        overrides: [
          conditionsRepositoryProvider.overrideWithValue(repo),
        ],
      );

      // Start the provider, then dispose container to trigger cancellation.
      unawaited(container.read(conditionsSnapshotProvider(launch).future));
      container.dispose();

      expect(captured, isNotNull);
      expect(captured!.isCancelled, isTrue);
    });
  });

  group('ConditionReportSubmitNotifier', () {
    test('returns false for blank message', () async {
      final submitRepo = _MockConditionReportSubmitRepository();
      final container = ProviderContainer(
        overrides: [
          conditionReportSubmitRepositoryProvider.overrideWithValue(submitRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        conditionReportSubmitProvider(
          (launchId: 'l', clientConditionsFetchedAt: null),
        ).notifier,
      );

      final ok = await notifier.submit('   ');
      expect(ok, isFalse);
      verifyNever(
        () => submitRepo.submit(
          launchId: any(named: 'launchId'),
          message: any(named: 'message'),
          clientConditionsFetchedAt: any(named: 'clientConditionsFetchedAt'),
          cancelToken: any(named: 'cancelToken'),
        ),
      );
    });

    test('increments refresh token on success', () async {
      final submitRepo = _MockConditionReportSubmitRepository();
      when(
        () => submitRepo.submit(
          launchId: any(named: 'launchId'),
          message: any(named: 'message'),
          clientConditionsFetchedAt: any(named: 'clientConditionsFetchedAt'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => const Result.success(null));

      final container = ProviderContainer(
        overrides: [
          conditionReportSubmitRepositoryProvider.overrideWithValue(submitRepo),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(conditionReportsRefreshTokenProvider), 0);

      final notifier = container.read(
        conditionReportSubmitProvider(
          (launchId: 'l', clientConditionsFetchedAt: 't'),
        ).notifier,
      );
      final ok = await notifier.submit(' hi ');
      expect(ok, isTrue);
      expect(container.read(conditionReportsRefreshTokenProvider), 1);
    });

    test('sets error state and errorMessage on failure', () async {
      final submitRepo = _MockConditionReportSubmitRepository();
      when(
        () => submitRepo.submit(
          launchId: any(named: 'launchId'),
          message: any(named: 'message'),
          clientConditionsFetchedAt: any(named: 'clientConditionsFetchedAt'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(StorageFailure(message: 'nope')),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportSubmitRepositoryProvider.overrideWithValue(submitRepo),
        ],
      );
      addTearDown(container.dispose);

      final provider = conditionReportSubmitProvider(
        (launchId: 'l', clientConditionsFetchedAt: null),
      );
      final notifier = container.read(provider.notifier);

      final ok = await notifier.submit('hello');
      expect(ok, isFalse);
      expect(container.read(provider).hasError, isTrue);
      expect(notifier.errorMessage, 'nope');
    });
  });

  group('ConditionsAiSummaryNotifier', () {
    test('isIdle before summarize and sets summary on success', () async {
      final repo = _MockConditionsAiSummaryRepository();
      when(
        () => repo.summarize(
          launch: any(named: 'launch'),
          snapshot: any(named: 'snapshot'),
          goNoGo: any(named: 'goNoGo'),
          skillProfile: any(named: 'skillProfile'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => const Result.success('summary'));

      final container = ProviderContainer(
        overrides: [
          conditionsAiSummaryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final provider = conditionsAiSummaryProvider('l');
      expect(container.read(provider).isIdle, isTrue);

      final notifier = container.read(provider.notifier);
      await notifier.summarize(
        launch: const LaunchPoint(
          id: 'id',
          name: 'n',
          latitude: 0,
          longitude: 0,
          shortNote: 'note',
          riverSystem: RiverSystem.willamette,
          windExposure: WindExposure.sheltered,
          tideRelevance: TideRelevance.none,
        ),
        snapshot: ConditionsSnapshot(fetchedAt: DateTime(2026)),
        goNoGo: GoNoGoResult(
          verdict: GoNoGoVerdict.go,
          reasons: const [],
          computedAt: DateTime(2026),
        ),
        skillProfile: GoNoGoProfile.beginner,
      );

      final state = container.read(provider);
      expect(state.isIdle, isFalse);
      expect(state.summary, 'summary');
      expect(state.errorMessage, isNull);
    });

    test('sets errorMessage on failure', () async {
      final repo = _MockConditionsAiSummaryRepository();
      when(
        () => repo.summarize(
          launch: any(named: 'launch'),
          snapshot: any(named: 'snapshot'),
          goNoGo: any(named: 'goNoGo'),
          skillProfile: any(named: 'skillProfile'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(NetworkFailure(message: 'down')),
      );

      final container = ProviderContainer(
        overrides: [
          conditionsAiSummaryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final provider = conditionsAiSummaryProvider('l');
      await container
          .read(provider.notifier)
          .summarize(
            launch: const LaunchPoint(
              id: 'id',
              name: 'n',
              latitude: 0,
              longitude: 0,
              shortNote: 'note',
              riverSystem: RiverSystem.willamette,
              windExposure: WindExposure.sheltered,
              tideRelevance: TideRelevance.none,
            ),
            snapshot: ConditionsSnapshot(fetchedAt: DateTime(2026)),
            goNoGo: GoNoGoResult(
              verdict: GoNoGoVerdict.go,
              reasons: const [],
              computedAt: DateTime(2026),
            ),
            skillProfile: GoNoGoProfile.beginner,
          );

      expect(container.read(provider).errorMessage, 'down');
    });
  });

  group('conditionReportsListProvider', () {
    test('returns list on success', () async {
      final repo = _MockConditionReportsRepository();
      when(
        () => repo.listReports(
          any<String>(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(<ConditionReportListItem>[]),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(
        conditionReportsListProvider('l').future,
      );
      expect(list, isEmpty);
    });

    test('throws AppFailure on failure', () async {
      final repo = _MockConditionReportsRepository();
      when(
        () => repo.listReports(
          any<String>(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(NetworkFailure(message: 'no')),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(conditionReportsListProvider('l').future),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('LaunchReportsDigestNotifier', () {
    test('sets result on success', () async {
      final repo = _MockConditionReportsRepository();
      when(
        () => repo.summarizeLaunchReports(
          launchId: any(named: 'launchId'),
          forceRefresh: any(named: 'forceRefresh'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          LaunchReportsDigestResult(
            digestText: 'hi',
            cached: false,
            noReports: false,
          ),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final provider = launchReportsDigestProvider('l');
      expect(container.read(provider).isIdle, isTrue);

      await container.read(provider.notifier).summarize(forceRefresh: true);
      expect(container.read(provider).result?.digestText, 'hi');
      expect(container.read(provider).errorMessage, isNull);
    });

    test('sets errorMessage on failure', () async {
      final repo = _MockConditionReportsRepository();
      when(
        () => repo.summarizeLaunchReports(
          launchId: any(named: 'launchId'),
          forceRefresh: any(named: 'forceRefresh'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(StorageFailure(message: 'no')),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final provider = launchReportsDigestProvider('l');
      await container.read(provider.notifier).summarize();
      expect(container.read(provider).errorMessage, 'no');
    });
  });
}

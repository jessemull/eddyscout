import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConditionReportsRepository extends Mock
    implements ConditionReportsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const launchId = 'cathedral-park';
  const digest = LaunchReportsDigestResult(
    digestText: 'Choppy near the bridge.',
    cached: false,
    noReports: false,
  );

  group('launchReportsDigestProvider', () {
    test('summarize success stores digest result', () async {
      final repo = _MockConditionReportsRepository();
      when(
        () => repo.summarizeLaunchReports(
          launchId: launchId,
          forceRefresh: false,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async =>
            const Result<LaunchReportsDigestResult, AppFailure>.success(
              digest,
            ),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(launchReportsDigestProvider(launchId).notifier)
          .summarize();

      final state = container.read(launchReportsDigestProvider(launchId));
      expect(state.isLoading, isFalse);
      expect(state.result, digest);
      expect(state.errorMessage, isNull);
    });

    test('summarize failure stores user-facing error message', () async {
      final repo = _MockConditionReportsRepository();
      when(
        () => repo.summarizeLaunchReports(
          launchId: launchId,
          forceRefresh: any(named: 'forceRefresh'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async =>
            const Result<LaunchReportsDigestResult, AppFailure>.failure(
              NetworkFailure(message: 'Callable unavailable'),
            ),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(launchReportsDigestProvider(launchId).notifier)
          .summarize();

      final state = container.read(launchReportsDigestProvider(launchId));
      expect(state.errorMessage, 'Callable unavailable');
      expect(state.result, isNull);
    });

    test('summarize passes forceRefresh to repository', () async {
      final repo = _MockConditionReportsRepository();
      when(
        () => repo.summarizeLaunchReports(
          launchId: launchId,
          forceRefresh: true,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async =>
            const Result<LaunchReportsDigestResult, AppFailure>.success(
              digest,
            ),
      );

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(launchReportsDigestProvider(launchId).notifier)
          .summarize(forceRefresh: true);

      verify(
        () => repo.summarizeLaunchReports(
          launchId: launchId,
          forceRefresh: true,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });

    test('dispose cancels active summarize token', () async {
      final repo = _MockConditionReportsRepository();
      CancelToken? capturedToken;
      final pending =
          Completer<Result<LaunchReportsDigestResult, AppFailure>>();
      when(
        () => repo.summarizeLaunchReports(
          launchId: launchId,
          forceRefresh: any(named: 'forceRefresh'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((invocation) async {
        capturedToken = invocation.namedArguments[#cancelToken] as CancelToken?;
        return pending.future;
      });

      final container = ProviderContainer(
        overrides: [
          conditionReportsRepositoryProvider.overrideWithValue(repo),
        ],
      );

      final subscription = container.listen(
        launchReportsDigestProvider(launchId),
        (_, _) {},
      );
      unawaited(
        container
            .read(launchReportsDigestProvider(launchId).notifier)
            .summarize(),
      );
      await Future<void>.delayed(Duration.zero);

      subscription.close();
      container.dispose();

      expect(capturedToken?.isCancelled, isTrue);
      pending.complete(const Result.success(digest));
    });
  });
}

import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class _MockHttpsCallable extends Mock implements HttpsCallable {}

class _MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<String, Object?>{});
  });

  setUp(ConditionsCallablesTestHooks.reset);
  tearDown(ConditionsCallablesTestHooks.reset);

  group('ConditionReportListItem.fromJson', () {
    test('parses valid report row', () {
      final item = ConditionReportListItem.fromJson({
        'message': 'Windy afternoon',
        'createdAt': '2026-06-15T12:00:00-07:00',
        'isMine': true,
      });

      expect(item.message, 'Windy afternoon');
      expect(item.isMine, isTrue);
    });

    test('throws when fields are missing or wrong type', () {
      expect(
        () => ConditionReportListItem.fromJson({
          'message': 1,
          'createdAt': '2026-06-15T12:00:00-07:00',
          'isMine': true,
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('LaunchReportsDigestResult.fromJson', () {
    test('parses digest with optional noReports', () {
      final result = LaunchReportsDigestResult.fromJson({
        'digestText': 'Calm morning.',
        'cached': true,
      });

      expect(result.digestText, 'Calm morning.');
      expect(result.cached, isTrue);
      expect(result.noReports, isFalse);
    });

    test('parses noReports true', () {
      final result = LaunchReportsDigestResult.fromJson({
        'digestText': 'No reports yet.',
        'cached': false,
        'noReports': true,
      });

      expect(result.noReports, isTrue);
    });

    test('throws when digestText or cached invalid', () {
      expect(
        () => LaunchReportsDigestResult.fromJson({
          'digestText': 'ok',
          'cached': 'yes',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Callable wrappers', () {
    late _MockFirebaseFunctions functions;
    late _MockHttpsCallable callable;
    late _MockHttpsCallableResult result;

    setUp(() {
      functions = _MockFirebaseFunctions();
      callable = _MockHttpsCallable();
      result = _MockHttpsCallableResult();
      ConditionsCallablesTestHooks.functions = functions;
      ConditionsCallablesTestHooks.ensureIdToken = () async {};
      when(() => functions.httpsCallable(any())).thenReturn(callable);
    });

    test('callSummarizeConditions returns summaryText', () async {
      when(() => result.data).thenReturn({'summaryText': 'Light wind.'});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callSummarizeConditions({'launchId': 'test'});

      expect(res.valueOrNull, 'Light wind.');
      verify(() => functions.httpsCallable('summarizeConditions')).called(1);
    });

    test('callSummarizeConditions falls back to summary key', () async {
      when(() => result.data).thenReturn({'summary': 'Fallback ok.'});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callSummarizeConditions({'launchId': 'test'});

      expect(res.valueOrNull, 'Fallback ok.');
    });

    test(
      'callSummarizeConditions returns failure when summary missing',
      () async {
        when(() => result.data).thenReturn(<String, dynamic>{});
        when(
          () =>
              callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
        ).thenAnswer((_) async => result);

        final res = await callSummarizeConditions({'launchId': 'test'});

        expect(res.isFailure, isTrue);
        expect(res.errorOrNull, isA<AppFailure>());
      },
    );

    test(
      'callables map non-unauthenticated FirebaseFunctionsException to failure',
      () async {
        when(
          () =>
              callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
        ).thenThrow(
          FirebaseFunctionsException(code: 'internal', message: 'nope'),
        );

        final res = await callSummarizeConditions({'launchId': 'test'});

        expect(res.isFailure, isTrue);
        expect(res.errorOrNull, isA<UnexpectedFailure>());
        expect(res.errorOrNull?.message, 'nope');
      },
    );

    test('callSubmitConditionReport parses moderation status', () async {
      when(() => result.data).thenReturn({
        'ok': true,
        'moderationStatus': 'held',
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callSubmitConditionReport(
        launchId: 'cathedral_park',
        message: 'test',
      );

      expect(
        res.valueOrNull?.moderationStatus,
        ConditionReportModerationStatus.held,
      );
    });

    test('callListConditionReports maps report rows', () async {
      when(() => result.data).thenReturn({
        'reports': [
          {
            'message': 'Choppy',
            'createdAt': '2026-06-15T10:00:00-07:00',
            'isMine': false,
          },
        ],
        'viewerHasPendingReport': true,
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callListConditionReports(launchId: 'cathedral_park');

      expect(res.valueOrNull?.reports, hasLength(1));
      expect(res.valueOrNull!.reports.first.message, 'Choppy');
      expect(res.valueOrNull!.viewerHasPendingReport, isTrue);
      verify(() => functions.httpsCallable('listConditionReports')).called(1);
    });

    test('callSummarizeLaunchReports parses digest result', () async {
      when(() => result.data).thenReturn({
        'digestText': 'Quiet day.',
        'cached': false,
        'noReports': false,
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callSummarizeLaunchReports(launchId: 'sellwood');

      expect(res.valueOrNull?.digestText, 'Quiet day.');
      verify(() => functions.httpsCallable('summarizeLaunchReports')).called(1);
    });

    test('callReopenConditionReport invokes reopen callable', () async {
      when(() => result.data).thenReturn({'ok': true});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callReopenConditionReport(reportId: 'report-1');

      expect(res.isSuccess, isTrue);
      verify(() => functions.httpsCallable('reopenConditionReport')).called(1);
      verify(
        () => callable.call<Map<String, dynamic>>({
          'reportId': 'report-1',
        }),
      ).called(1);
    });

    test('retries once on unauthenticated', () async {
      when(() => result.data).thenReturn({'summaryText': 'Retry ok.'});
      var calls = 0;
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((
        _,
      ) async {
        calls++;
        if (calls == 1) {
          throw FirebaseFunctionsException(
            code: 'unauthenticated',
            message: 'stale token',
          );
        }
        return result;
      });

      final res = await callSummarizeConditions({'launchId': 'test'});

      expect(res.valueOrNull, 'Retry ok.');
      expect(calls, 2);
    });

    test(
      'callSummarizeConditions returns failure when cancel token cancelled',
      () async {
        final token = CancelToken()..cancel('test');

        final res = await callSummarizeConditions(
          {'launchId': 'test'},
          cancelToken: token,
        );

        expect(res.isFailure, isTrue);
        expect(res.errorOrNull, isA<NetworkFailure>());
      },
    );

    test('callCheckModeratorAccess parses isModerator', () async {
      when(() => result.data).thenReturn({'isModerator': true});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callCheckModeratorAccess();

      expect(res.valueOrNull, isTrue);
      verify(() => functions.httpsCallable('checkModeratorAccess')).called(1);
    });

    test('callListPendingConditionReports maps queue rows', () async {
      when(() => result.data).thenReturn({
        'reports': [
          {
            'id': 'r1',
            'launchId': 'sellwood_riverfront',
            'message': 'Choppy',
            'createdAt': '2026-06-15T10:00:00-07:00',
            'submitterUid': 'uid-1',
          },
        ],
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callListPendingConditionReports(
        query: const ModerationQueueQuery(
          launchId: 'sellwood_riverfront',
          sort: ModerationQueueSort.createdAtDesc,
        ),
      );

      expect(res.valueOrNull, hasLength(1));
      expect(res.valueOrNull!.single.id, 'r1');
      verify(
        () => functions.httpsCallable('listPendingConditionReports'),
      ).called(1);
    });

    test('callListModerationHistory maps audit rows', () async {
      when(() => result.data).thenReturn({
        'reports': [
          {
            'id': 'r1',
            'launchId': 'cathedral_park',
            'message': 'Calm',
            'createdAt': '2026-06-15T10:00:00-07:00',
            'submitterUid': 'uid-1',
            'moderationStatus': 'rejected',
            'reviewedAt': '2026-06-16T10:00:00-07:00',
          },
        ],
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callListModerationHistory(
        query: const ModerationHistoryQuery(
          status: ModerationHistoryStatusFilter.rejected,
          sort: ModerationHistorySort.reviewedAtAsc,
        ),
      );

      expect(res.valueOrNull, hasLength(1));
      expect(
        res.valueOrNull!.single.moderationStatus,
        ConditionReportModerationStatus.rejected,
      );
      verify(() => functions.httpsCallable('listModerationHistory')).called(1);
    });

    test('callModerateConditionReport parses moderation status', () async {
      when(() => result.data).thenReturn({'moderationStatus': 'approved'});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callModerateConditionReport(
        reportId: 'r1',
        approve: true,
      );

      expect(
        res.valueOrNull,
        ConditionReportModerationStatus.approved,
      );
      verify(
        () => functions.httpsCallable('moderateConditionReport'),
      ).called(1);
    });

    test('callModerateConditionReportsBatch parses batch result', () async {
      when(() => result.data).thenReturn({
        'succeeded': ['a'],
        'failed': [
          {'reportId': 'b', 'code': 'not-found'},
        ],
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final res = await callModerateConditionReportsBatch(
        reportIds: const ['a', 'b'],
        approve: false,
      );

      expect(res.valueOrNull?.succeeded, ['a']);
      expect(res.valueOrNull?.failed.single.code, 'not-found');
      verify(
        () => functions.httpsCallable('moderateConditionReportsBatch'),
      ).called(1);
    });
  });
}

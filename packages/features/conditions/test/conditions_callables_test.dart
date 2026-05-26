import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
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

      final text = await callSummarizeConditions({'launchId': 'test'});

      expect(text, 'Light wind.');
      verify(() => functions.httpsCallable('summarizeConditions')).called(1);
    });

    test('callSummarizeConditions falls back to summary key', () async {
      when(() => result.data).thenReturn({'summary': 'Fallback ok.'});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final text = await callSummarizeConditions({'launchId': 'test'});

      expect(text, 'Fallback ok.');
    });

    test('callSummarizeConditions throws when summary missing', () async {
      when(() => result.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      expect(
        () => callSummarizeConditions({'launchId': 'test'}),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'callables rethrow non-unauthenticated FirebaseFunctionsException',
      () async {
        when(
          () =>
              callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
        ).thenThrow(
          FirebaseFunctionsException(code: 'internal', message: 'nope'),
        );

        await expectLater(
          () => callSummarizeConditions({'launchId': 'test'}),
          throwsA(isA<FirebaseFunctionsException>()),
        );
      },
    );

    test('callListConditionReports maps report rows', () async {
      when(() => result.data).thenReturn({
        'reports': [
          {
            'message': 'Choppy',
            'createdAt': '2026-06-15T10:00:00-07:00',
            'isMine': false,
          },
        ],
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final list = await callListConditionReports(launchId: 'cathedral_park');

      expect(list, hasLength(1));
      expect(list.first.message, 'Choppy');
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

      final digest = await callSummarizeLaunchReports(launchId: 'sellwood');

      expect(digest.digestText, 'Quiet day.');
      verify(() => functions.httpsCallable('summarizeLaunchReports')).called(1);
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

      final text = await callSummarizeConditions({'launchId': 'test'});

      expect(text, 'Retry ok.');
      expect(calls, 2);
    });

    test('callSummarizeConditions throws when cancel token is cancelled', () {
      final token = CancelToken()..cancel('test');

      expect(
        () => callSummarizeConditions({'launchId': 'test'}, cancelToken: token),
        throwsA(isA<DioException>()),
      );
    });
  });
}

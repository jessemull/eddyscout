import 'package:cloud_functions/cloud_functions.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/data/repositories/condition_report_submit_repository_impl.dart';
import 'package:eddyscout_conditions/src/data/repositories/condition_reports_repository_impl.dart';
import 'package:eddyscout_conditions/src/data/repositories/conditions_ai_summary_repository_impl.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
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
  });

  setUp(ConditionsCallablesTestHooks.reset);
  tearDown(ConditionsCallablesTestHooks.reset);

  group('repository implementations', () {
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

    test('ConditionsAiSummaryRepositoryImpl returns summary text', () async {
      when(() => result.data).thenReturn({'summaryText': 'ok'});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      const launch = LaunchPoint(
        id: 'id',
        name: 'n',
        latitude: 0,
        longitude: 0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      );

      final repo = const ConditionsAiSummaryRepositoryImpl();
      final res = await repo.summarize(
        launch: launch,
        snapshot: ConditionsSnapshot(fetchedAt: DateTime(2026)),
        goNoGo: GoNoGoResult(
          verdict: GoNoGoVerdict.go,
          reasons: const [],
          computedAt: DateTime(2026),
        ),
        skillProfile: GoNoGoProfile.beginner,
      );
      expect(res.valueOrNull, 'ok');
    });

    test('ConditionReportSubmitRepositoryImpl submits successfully', () async {
      when(() => result.data).thenReturn(<String, dynamic>{});
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final repo = const ConditionReportSubmitRepositoryImpl();
      final res = await repo.submit(launchId: 'l', message: 'm');
      expect(res.isSuccess, isTrue);
    });

    test('ConditionReportsRepositoryImpl lists reports', () async {
      when(() => result.data).thenReturn({
        'reports': [
          {
            'message': 'hi',
            'createdAt': '2026-06-15T12:00:00-07:00',
            'isMine': false,
          },
        ],
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final repo = const ConditionReportsRepositoryImpl();
      final res = await repo.listReports('l');
      expect(res.isSuccess, isTrue);
      expect(res.valueOrNull, hasLength(1));
    });

    test('ConditionReportsRepositoryImpl summarizes launch reports', () async {
      when(() => result.data).thenReturn({
        'digestText': 'ok',
        'cached': false,
      });
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenAnswer((_) async => result);

      final repo = const ConditionReportsRepositoryImpl();
      final res = await repo.summarizeLaunchReports(launchId: 'l');
      expect(res.isSuccess, isTrue);
      expect(res.valueOrNull?.digestText, 'ok');
    });

    test('repo maps callable exceptions to failure', () async {
      when(
        () => callable.call<Map<String, dynamic>>(any<Map<String, dynamic>>()),
      ).thenThrow(
        FirebaseFunctionsException(code: 'internal', message: 'nope'),
      );

      final repo = const ConditionReportsRepositoryImpl();
      final res = await repo.summarizeLaunchReports(launchId: 'l');
      expect(res.isFailure, isTrue);
      expect(res.errorOrNull, isA<AppFailure>());
    });
  });
}

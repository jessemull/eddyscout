import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConditionReportModerationRepository extends Mock
    implements ConditionReportModerationRepository {}

void main() {
  late _MockConditionReportModerationRepository repo;

  setUp(() {
    repo = _MockConditionReportModerationRepository();
    registerFallbackValue(CancelToken());
  });

  test('returns true when moderator access check succeeds', () async {
    when(
      () => repo.checkModeratorAccess(cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => const Result.success(true));

    final container = ProviderContainer(
      overrides: [
        conditionReportModerationRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(moderatorAccessProvider.future), isTrue);
  });
}

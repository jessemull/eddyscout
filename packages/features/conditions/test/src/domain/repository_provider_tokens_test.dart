import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('conditionsRepositoryProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(conditionsRepositoryProvider),
      throwsA(
        predicate(
          (e) =>
              e.toString().contains('UnimplementedError') ||
              e.toString().contains('conditionsRepositoryProvider'),
        ),
      ),
    );
  });

  test('goNoGoProfileRepositoryProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(goNoGoProfileRepositoryProvider),
      throwsA(
        predicate(
          (e) =>
              e.toString().contains('UnimplementedError') ||
              e.toString().contains('goNoGoProfileRepositoryProvider'),
        ),
      ),
    );
  });

  test('conditionReportModerationRepositoryProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(conditionReportModerationRepositoryProvider),
      throwsA(
        predicate(
          (Object? e) => e.toString().contains('UnimplementedError'),
        ),
      ),
    );
  });

  test('conditionReportSubmitRepositoryProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(conditionReportSubmitRepositoryProvider),
      throwsA(
        predicate(
          (Object? e) => e.toString().contains('UnimplementedError'),
        ),
      ),
    );
  });

  test('conditionsAiSummaryRepositoryProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(conditionsAiSummaryRepositoryProvider),
      throwsA(
        predicate(
          (Object? e) => e.toString().contains('UnimplementedError'),
        ),
      ),
    );
  });
}

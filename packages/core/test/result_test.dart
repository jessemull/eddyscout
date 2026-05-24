import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success holds value', () {
      const result = Result<int, String>.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, isNull);
    });

    test('Failure holds error', () {
      const result = Result<int, String>.failure('oops');
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, 'oops');
    });

    test('when dispatches correctly', () {
      const success = Result<int, String>.success(1);
      final value = success.when(success: (v) => v * 2, failure: (_) => -1);
      expect(value, 2);
    });
  });
}

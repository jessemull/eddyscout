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

    test('when dispatches failure correctly', () {
      const failure = Result<int, String>.failure('nope');
      final value = failure.when(success: (v) => v * 2, failure: (e) => e);
      expect(value, 'nope');
    });

    test('Success equality/hashCode are based on value', () {
      const a = Success<int, String>(1);
      const b = Success<int, String>(1);
      const c = Success<int, String>(2);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('Failure equality/hashCode are based on error', () {
      const a = Failure<int, String>('e');
      const b = Failure<int, String>('e');
      const c = Failure<int, String>('other');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('toString includes variant name', () {
      const s = Result<int, String>.success(1);
      const f = Result<int, String>.failure('x');
      expect(s.toString(), contains('Success('));
      expect(f.toString(), contains('Failure('));
    });
  });
}

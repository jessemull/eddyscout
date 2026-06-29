import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/firebase/callable_cancel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ensureCallableNotCancelled', () {
    test('does nothing when token is null', () {
      expect(() => ensureCallableNotCancelled(null), returnsNormally);
    });

    test('does nothing when token is active', () {
      expect(() => ensureCallableNotCancelled(CancelToken()), returnsNormally);
    });

    test('throws DioException when token is cancelled', () {
      final token = CancelToken()..cancel('test');
      expect(
        () => ensureCallableNotCancelled(token),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
    });
  });
}

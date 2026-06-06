import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/app_failure_mapper.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapToAppFailure preserves AppFailure', () {
    const original = NetworkFailure(message: 'test');
    expect(mapToAppFailure(original), same(original));
  });

  test('mapToAppFailure maps cancel DioException', () {
    final failure = mapToAppFailure(
      DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.cancel,
      ),
    );
    expect(failure, isA<NetworkFailure>());
    expect(failure.message, contains('cancelled'));
  });

  test('mapToAppFailure maps unauthenticated FirebaseFunctionsException', () {
    final failure = mapToAppFailure(
      FirebaseFunctionsException(code: 'unauthenticated', message: 'stale'),
    );
    expect(failure, isA<NetworkFailure>());
    expect(failure.message.toLowerCase(), contains('unauthenticated'));
  });

  test('mapToAppFailure maps internal FirebaseFunctionsException message', () {
    final failure = mapToAppFailure(
      FirebaseFunctionsException(code: 'internal', message: 'nope'),
    );
    expect(failure, isA<UnexpectedFailure>());
    expect(failure.message, 'nope');
  });

  test('mapToAppFailure maps FirebaseAuthException', () {
    final failure = mapToAppFailure(
      FirebaseAuthException(
        code: 'no-current-user',
        message: 'Not signed in',
      ),
    );
    expect(failure, isA<UnexpectedFailure>());
    expect(failure.message, 'Not signed in');
  });
}

import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/app_failure_mapper.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
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
}

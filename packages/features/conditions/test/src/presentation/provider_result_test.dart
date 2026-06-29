import 'package:eddyscout_conditions/src/presentation/provider_result.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('unwrapResultForAsyncProvider', () {
    test('returns success value', () {
      const result = Result<String, AppFailure>.success('ok');
      expect(unwrapResultForAsyncProvider(result), 'ok');
    });

    test('throws AppFailure on failure', () {
      const failure = NetworkFailure(message: 'offline');
      const result = Result<String, AppFailure>.failure(failure);
      expect(
        () => unwrapResultForAsyncProvider(result),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}

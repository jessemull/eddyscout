import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure', () {
    test('NetworkFailure toString returns message', () {
      const failure = NetworkFailure(message: 'timeout', statusCode: 504);
      expect(failure.toString(), 'timeout');
      expect(failure.statusCode, 504);
    });

    test('StorageFailure and UnexpectedFailure expose message', () {
      const storage = StorageFailure(message: 'disk full');
      const unexpected = UnexpectedFailure(message: 'unknown');
      expect(storage.message, 'disk full');
      expect(unexpected.message, 'unknown');
    });
  });
}

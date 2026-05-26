import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure', () {
    test('toString returns message', () {
      const failure = NetworkFailure(message: 'no network');
      expect(failure.toString(), 'no network');
    });

    test('subtypes hold optional fields', () {
      final trace = StackTrace.current;
      final failure = NetworkFailure(
        message: 'server',
        statusCode: 503,
        stackTrace: trace,
      );

      expect(failure.statusCode, 503);
      expect(failure.stackTrace, same(trace));
    });

    test('storage and unexpected failures construct', () {
      const storage = StorageFailure(message: 'disk');
      const unexpected = UnexpectedFailure(message: 'boom');

      expect(storage.message, 'disk');
      expect(unexpected.message, 'boom');
    });
  });
}

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure', () {
    test('toString returns message', () {
      const failure = NetworkFailure(message: 'no network');
      expect(failure.toString(), 'no network');
    });

    test('failures implement Exception', () {
      expect(const NetworkFailure(message: 'x'), isA<Exception>());
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

    test('not found failure constructs and toString returns message', () {
      const failure = NotFoundFailure(message: 'No launch with id: missing');
      expect(failure.message, 'No launch with id: missing');
      expect(failure.toString(), 'No launch with id: missing');
    });

    test('parse failure constructs and toString returns message', () {
      final trace = StackTrace.current;
      const failure = ParseFailure();
      final failureWithTrace = ParseFailure(stackTrace: trace);

      expect(failure.message, 'parse_failure');
      expect(failure.toString(), 'parse_failure');
      expect(failureWithTrace.stackTrace, same(trace));
    });

    test('asset load failure constructs and toString returns message', () {
      final trace = StackTrace.current;
      const failure = AssetLoadFailure();
      final failureWithTrace = AssetLoadFailure(stackTrace: trace);

      expect(failure.message, 'asset_load_failure');
      expect(failure.toString(), 'asset_load_failure');
      expect(failureWithTrace.stackTrace, same(trace));
    });
  });
}

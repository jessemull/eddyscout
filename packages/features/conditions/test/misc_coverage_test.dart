import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/app_failure_mapper.dart';
import 'package:eddyscout_conditions/src/data/conditions_http_provider.dart';
import 'package:eddyscout_conditions/src/data/firebase/firebase_bootstrap.dart';
import 'package:eddyscout_conditions/src/data/firebase/firebase_flags.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapToAppFailure', () {
    test('preserves AppFailure', () {
      const f = StorageFailure(message: 'x');
      expect(mapToAppFailure(f), f);
    });

    test('maps cancelled DioException', () {
      final ex = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.cancel,
      );
      final f = mapToAppFailure(ex);
      expect(f, isA<NetworkFailure>());
      expect(f.message.toLowerCase(), contains('cancel'));
    });

    test('maps 5xx DioException with status', () {
      final ex = DioException(
        requestOptions: RequestOptions(path: '/'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/'),
          statusCode: 503,
        ),
      );
      final f = mapToAppFailure(ex) as NetworkFailure;
      expect(f.statusCode, 503);
    });

    test('maps unknown errors with network-ish message', () {
      final f = mapToAppFailure(Exception('socket failed'));
      expect(f, isA<NetworkFailure>());
    });

    test('maps other errors to UnexpectedFailure', () {
      final f = mapToAppFailure(Exception('boom'));
      expect(f, isA<UnexpectedFailure>());
    });
  });

  group('firebase flags/bootstrap', () {
    test('firebaseCallablesAvailable is false by default', () {
      expect(kUseFirebase, isFalse);
      expect(firebaseCallablesAvailable, isFalse);
    });

    test('FirebaseBootstrap hintForLastError returns null when unset', () {
      FirebaseBootstrap.lastError = null;
      expect(FirebaseBootstrap.hintForLastError(), isNull);
    });

    test(
      'FirebaseBootstrap hintForLastError returns guidance for known auth codes',
      () {
        FirebaseBootstrap.lastError = 'admin-restricted-operation';
        expect(FirebaseBootstrap.hintForLastError(), isNotNull);
      },
    );
  });

  group('conditions_http_provider', () {
    test('creates client and closes on container dispose', () {
      final container = ProviderContainer();
      container.read(conditionsHttpClientProvider);
      expect(container.dispose, returnsNormally);
    });
  });

  group('models + exceptions smoke', () {
    test('conditions models can be constructed', () {
      const weather = WeatherConditions(source: WeatherDataSource.nws);
      final event = TideEvent(type: 'H', time: DateTime(2026));
      final snapshot = ConditionsSnapshot(
        fetchedAt: DateTime(2026),
        weather: weather,
        tides: TideSummary(
          stationId: 's',
          datumLabel: 'MLLW',
          events: [event],
        ),
      );
      expect(snapshot.weather?.source, WeatherDataSource.nws);
      expect(snapshot.tides?.events.first.type, 'H');
    });
  });
}

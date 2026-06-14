import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('geodesy', () {
    test('haversineMeters returns zero for identical points', () {
      expect(haversineMeters(45.5, -122.6, 45.5, -122.6), 0);
    });

    test('haversineMeters returns positive distance for offset points', () {
      final meters = haversineMeters(45.5, -122.6, 45.51, -122.6);
      expect(meters, greaterThan(1000));
      expect(meters, lessThan(1200));
    });
  });

  group('AppFailureException', () {
    test('wraps failure and appFailureFrom extracts it', () {
      const failure = NetworkFailure(message: 'offline');
      const exception = AppFailureException(failure);

      expect(exception.failure, failure);
      expect(exception.toString(), 'offline');
      expect(appFailureFrom(exception), failure);
    });

    test('appFailureFrom returns AppFailure directly', () {
      const failure = StorageFailure(message: 'disk');
      expect(appFailureFrom(failure), failure);
    });

    test('appFailureFrom returns null for unknown errors', () {
      expect(appFailureFrom(Exception('other')), isNull);
    });
  });

  group('GpxFailure', () {
    test('constructs with code', () {
      const failure = GpxFailure(code: GpxFailureCode.emptyInput);
      expect(failure.code, GpxFailureCode.emptyInput);
    });
  });

  group('gpxFailureCodeFromAppFailure', () {
    test('maps known storage messages', () {
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'gpx_file_read_failed'),
        ),
        GpxFailureCode.fileReadFailed,
      );
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'gpx_file_write_failed'),
        ),
        GpxFailureCode.fileWriteFailed,
      );
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'gpx_share_failed'),
        ),
        GpxFailureCode.shareFailed,
      );
    });

    test(
      'defaults unknown storage and non-storage failures to fileReadFailed',
      () {
        expect(
          gpxFailureCodeFromAppFailure(
            const StorageFailure(message: 'other'),
          ),
          GpxFailureCode.fileReadFailed,
        );
        expect(
          gpxFailureCodeFromAppFailure(
            const NetworkFailure(message: 'offline'),
          ),
          GpxFailureCode.fileReadFailed,
        );
      },
    );
  });

  group('PlannedRoute', () {
    test('toPolylineLonLat maps longitude before latitude', () {
      const route = PlannedRoute(
        points: [
          GpxPoint(latitude: 45.5, longitude: -122.6),
          GpxPoint(latitude: 45.51, longitude: -122.61),
        ],
      );

      expect(
        route.toPolylineLonLat(),
        [
          [-122.6, 45.5],
          [-122.61, 45.51],
        ],
      );
    });
  });

  group('RoutePlanningFailure', () {
    test('holds optional reach metadata', () {
      const failure = RoutePlanningFailure(
        code: RouteFailureCode.disconnectedReach,
        riverSystemName: 'Willamette',
        putInReachId: 'a',
        takeOutReachId: 'b',
      );

      expect(failure.code, RouteFailureCode.disconnectedReach);
      expect(failure.riverSystemName, 'Willamette');
      expect(failure.putInReachId, 'a');
      expect(failure.takeOutReachId, 'b');
    });
  });
}

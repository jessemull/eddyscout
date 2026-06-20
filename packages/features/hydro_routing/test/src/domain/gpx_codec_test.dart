import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

LaunchPoint _launch({required String id, required String name}) {
  return LaunchPoint(
    id: id,
    name: name,
    latitude: 45.5621,
    longitude: -122.7328,
    shortNote: 'Test',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );
}

void main() {
  group('GpxCodec', () {
    final putIn = _launch(id: 'a', name: 'Put-in');
    final takeOut = _launch(id: 'b', name: 'Take-out');

    PlannedRoute sampleRoute() => PlannedRoute(
      points: const [
        GpxPoint(latitude: 45.56, longitude: -122.73),
        GpxPoint(latitude: 45.47, longitude: -122.66),
      ],
      putIn: putIn,
      takeOut: takeOut,
      lengthMeters: 12000,
      name: 'Put-in → Take-out',
      origin: RouteOrigin.planner,
    );

    test('serialize and parse round-trip preserves point count', () {
      final route = sampleRoute();
      final serialized = GpxCodec.serialize(route);
      expect(serialized.isSuccess, isTrue);

      final parsed = GpxCodec.parse(serialized.valueOrNull!);
      expect(parsed.isSuccess, isTrue);
      expect(parsed.valueOrNull!.points.length, route.points.length);
      expect(parsed.valueOrNull!.points.first.latitude, closeTo(45.56, 0.001));
      expect(
        parsed.valueOrNull!.points.first.longitude,
        closeTo(-122.73, 0.001),
      );
      expect(parsed.valueOrNull!.lengthMeters, isNotNull);
      expect(parsed.valueOrNull!.lengthMeters, greaterThan(0));
    });

    test('fromRouteSuccess maps polyline lon/lat order', () {
      final success =
          RouteResult.success(
                polylineLonLat: [
                  [-122.73, 45.56],
                  [-122.66, 45.47],
                ],
                lengthMeters: 5000,
              )
              as RouteSuccess;

      final route = plannedRouteFromRouteSuccess(
        success,
        putIn: putIn,
        takeOut: takeOut,
      );

      expect(route.toPolylineLonLat(), success.polylineLonLat);
    });

    test('parse returns emptyInput for blank string', () {
      final result = GpxCodec.parse('   ');
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, GpxFailureCode.emptyInput);
    });

    test('parse returns malformedXml for invalid XML', () {
      final result = GpxCodec.parse('<not-gpx');
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, GpxFailureCode.malformedXml);
    });

    test('parse returns noGeometry when file has no points', () {
      const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <metadata><name>Empty</name></metadata>
</gpx>''';
      final result = GpxCodec.parse(xml);
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, GpxFailureCode.noGeometry);
    });

    test('parse returns tooFewPoints for single track point', () {
      const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk><trkseg><trkpt lat="45.5" lon="-122.6"/></trkseg></trk>
</gpx>''';
      final result = GpxCodec.parse(xml);
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, GpxFailureCode.tooFewPoints);
    });

    test('parse reads route rtept when no tracks', () {
      const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <rte>
    <rtept lat="45.50" lon="-122.60"/>
    <rtept lat="45.47" lon="-122.66"/>
  </rte>
</gpx>''';
      final result = GpxCodec.parse(xml);
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.points.length, 2);
    });

    test('serialize fails with tooFewPoints', () {
      final result = GpxCodec.serialize(
        const PlannedRoute(
          points: [GpxPoint(latitude: 45.5, longitude: -122.6)],
        ),
      );
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.code, GpxFailureCode.tooFewPoints);
    });
  });
}

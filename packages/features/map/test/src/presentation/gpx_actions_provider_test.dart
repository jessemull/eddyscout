import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGpxFileGateway extends Mock implements GpxFileGateway {}

const _sampleGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk><trkseg>
    <trkpt lat="45.5620" lon="-122.7320"/>
    <trkpt lat="45.4710" lon="-122.6610"/>
  </trkseg></trk>
</gpx>''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockGpxFileGateway gateway;
  late RecordingAnalyticsClient analytics;

  setUp(() {
    gateway = _MockGpxFileGateway();
    analytics = RecordingAnalyticsClient();
  });

  ProviderContainer containerWithPlanning({
    required List<List<double>> polyline,
  }) {
    return ProviderContainer(
      overrides: [
        gpxFileGatewayProvider.overrideWithValue(gateway),
        analyticsClientProvider.overrideWithValue(analytics),
        routePlanningProvider.overrideWith(
          () => _PlannedRoutePlanning(polyline),
        ),
      ],
    );
  }

  test('exportRoute logs gpx_export_success when share succeeds', () async {
    when(
      () => gateway.writeAndShareGpx(
        filename: any(named: 'filename'),
        gpxXml: any(named: 'gpxXml'),
      ),
    ).thenAnswer((_) async => const Result.success(null));

    final container = containerWithPlanning(
      polyline: [
        [-122.73, 45.56],
        [-122.66, 45.47],
      ],
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(gpxActionsProvider.notifier)
        .exportRoute();

    expect(outcome, isA<GpxActionSuccess>());
    expect(analytics.events.single.name, AnalyticsEvents.gpxExportSuccess);
  });

  test('exportRoute returns failure when no polyline', () async {
    final container = ProviderContainer(
      overrides: [
        gpxFileGatewayProvider.overrideWithValue(gateway),
        analyticsClientProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(gpxActionsProvider.notifier)
        .exportRoute();

    expect(outcome, isA<GpxActionFailure>());
    expect(
      (outcome as GpxActionFailure).failure,
      isA<GpxFailure>().having(
        (f) => f.code,
        'code',
        GpxFailureCode.noRouteToExport,
      ),
    );
    expect(analytics.events.single.name, AnalyticsEvents.gpxExportFailure);
  });

  test('importRoute parses GPX and logs gpx_import_success', () async {
    when(() => gateway.pickAndReadGpx()).thenAnswer(
      (_) async => const Result.success(_sampleGpx),
    );

    final container = ProviderContainer(
      overrides: [
        gpxFileGatewayProvider.overrideWithValue(gateway),
        analyticsClientProvider.overrideWithValue(analytics),
        mapboxMapControllerProvider.overrideWith(MapboxMapController.new),
      ],
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(gpxActionsProvider.notifier)
        .importRoute();

    expect(outcome, isA<GpxActionSuccess>());
    expect(analytics.events.single.name, AnalyticsEvents.gpxImportSuccess);
    final planning = container.read(routePlanningProvider);
    expect(planning.polylineLonLat?.length, 2);
    expect(planning.routeOrigin, RouteOrigin.imported);
  });

  test('importRoute returns cancelled when picker dismissed', () async {
    when(() => gateway.pickAndReadGpx()).thenAnswer(
      (_) async => const Result.failure(
        StorageFailure(message: kGpxPickCancelledMessage),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        gpxFileGatewayProvider.overrideWithValue(gateway),
        analyticsClientProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(gpxActionsProvider.notifier)
        .importRoute();

    expect(outcome, isA<GpxActionCancelled>());
    expect(analytics.events, isEmpty);
  });
}

class _PlannedRoutePlanning extends RoutePlanning {
  _PlannedRoutePlanning(this.polyline);

  final List<List<double>> polyline;

  @override
  RoutePlanningState build() => RoutePlanningState(
    planningMode: true,
    putIn: kLaunchPoints.first,
    takeOut: kLaunchPoints[1],
    routeLengthKm: 10,
    polylineLonLat: polyline,
    routeOrigin: RouteOrigin.planner,
  );
}

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

const _outsidePnwGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk><trkseg>
    <trkpt lat="40.0" lon="-74.0"/>
    <trkpt lat="41.0" lon="-75.0"/>
  </trkseg></trk>
</gpx>''';

const _pnwFarFromLaunchesGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk><trkseg>
    <trkpt lat="44.058" lon="-121.315"/>
    <trkpt lat="44.060" lon="-121.310"/>
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

  ProviderContainer containerForImport() {
    return ProviderContainer(
      overrides: [
        gpxFileGatewayProvider.overrideWithValue(gateway),
        analyticsClientProvider.overrideWithValue(analytics),
        mapboxMapControllerProvider.overrideWith(MapboxMapController.new),
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

  test(
    'exportRoute logs gpx_export_failure when temp file write fails',
    () async {
      when(
        () => gateway.writeAndShareGpx(
          filename: any(named: 'filename'),
          gpxXml: any(named: 'gpxXml'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          StorageFailure(message: 'gpx_file_write_failed'),
        ),
      );

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

      expect(outcome, isA<GpxActionFailure>());
      final failure = (outcome as GpxActionFailure).failure;
      expect(failure, isA<GpxPlatformActionFailure>());
      expect(
        (failure as GpxPlatformActionFailure).failure,
        isA<StorageFailure>().having(
          (f) => f.message,
          'message',
          'gpx_file_write_failed',
        ),
      );
      expect(analytics.events.single.name, AnalyticsEvents.gpxExportFailure);
      expect(
        analytics.events.single.parameters['failure_code'],
        GpxFailureCode.fileWriteFailed.name,
      );
    },
  );

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
    final failure = (outcome as GpxActionFailure).failure;
    expect(failure, isA<GpxCodecActionFailure>());
    expect(
      (failure as GpxCodecActionFailure).failure.code,
      GpxFailureCode.noRouteToExport,
    );
    expect(analytics.events.single.name, AnalyticsEvents.gpxExportFailure);
  });

  test('importRoute parses GPX and logs gpx_import_success', () async {
    when(() => gateway.pickAndReadGpx()).thenAnswer(
      (_) async => const Result.success(_sampleGpx),
    );

    final container = containerForImport();
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

  test(
    'importRoute returns malformed failure and logs gpx_import_failure',
    () async {
      when(() => gateway.pickAndReadGpx()).thenAnswer(
        (_) async => const Result.success('<<<not gpx xml>>>'),
      );

      final container = containerForImport();
      addTearDown(container.dispose);

      final outcome = await container
          .read(gpxActionsProvider.notifier)
          .importRoute();

      expect(outcome, isA<GpxActionFailure>());
      final failure = (outcome as GpxActionFailure).failure;
      expect(failure, isA<GpxCodecActionFailure>());
      expect(
        (failure as GpxCodecActionFailure).failure.code,
        GpxFailureCode.malformedXml,
      );
      expect(analytics.events.single.name, AnalyticsEvents.gpxImportFailure);
      expect(
        analytics.events.single.parameters['failure_code'],
        GpxFailureCode.malformedXml.name,
      );
    },
  );

  test(
    'importRoute warns outsidePnw when all points are outside bbox',
    () async {
      when(() => gateway.pickAndReadGpx()).thenAnswer(
        (_) async => const Result.success(_outsidePnwGpx),
      );

      final container = containerForImport();
      addTearDown(container.dispose);

      final outcome = await container
          .read(gpxActionsProvider.notifier)
          .importRoute();

      expect(outcome, isA<GpxActionSuccess>());
      expect(
        (outcome as GpxActionSuccess).warnings,
        contains(GpxImportWarning.outsidePnw),
      );
    },
  );

  test(
    'importRoute warns launchSnapFailed when endpoints exceed snap threshold',
    () async {
      when(() => gateway.pickAndReadGpx()).thenAnswer(
        (_) async => const Result.success(_pnwFarFromLaunchesGpx),
      );

      final container = containerForImport();
      addTearDown(container.dispose);

      final outcome = await container
          .read(gpxActionsProvider.notifier)
          .importRoute();

      expect(outcome, isA<GpxActionSuccess>());
      final success = outcome as GpxActionSuccess;
      expect(success.warnings, contains(GpxImportWarning.launchSnapFailed));
      expect(success.warnings, isNot(contains(GpxImportWarning.outsidePnw)));
    },
  );

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

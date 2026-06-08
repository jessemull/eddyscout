import 'dart:convert' show utf8;
import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/data/gpx_file_gateway_impl.dart';
import 'package:eddyscout_map/src/domain/gpx_file_gateway.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

class _MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePicker {}

class _TestSharePlatform extends SharePlatform {
  _TestSharePlatform(this.onShare);

  final Future<ShareResult> Function(ShareParams params) onShare;

  @override
  Future<ShareResult> share(ShareParams params) => onShare(params);
}

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.tempPath);

  final String? tempPath;

  @override
  Future<String?> getTemporaryPath() async => tempPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockFilePicker filePicker;
  late PathProviderPlatform originalPathProvider;
  late SharePlatform originalSharePlatform;
  late FilePicker originalFilePicker;

  const gateway = GpxFileGatewayImpl();

  setUpAll(() {
    FilePicker.platform = _MockFilePicker();
    registerFallbackValue(FileType.custom);
    registerFallbackValue(<String>[]);
    registerFallbackValue(ShareParams(files: []));
  });

  setUp(() {
    filePicker = _MockFilePicker();
    originalPathProvider = PathProviderPlatform.instance;
    originalSharePlatform = SharePlatform.instance;
    originalFilePicker = FilePicker.platform;
    FilePicker.platform = filePicker;
  });

  tearDown(() {
    PathProviderPlatform.instance = originalPathProvider;
    SharePlatform.instance = originalSharePlatform;
    FilePicker.platform = originalFilePicker;
  });

  group('gpxFailureCodeFromAppFailure', () {
    test('maps file read failures', () {
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'gpx_file_read_failed'),
        ),
        GpxFailureCode.fileReadFailed,
      );
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'gpx_read_failed'),
        ),
        GpxFailureCode.fileReadFailed,
      );
    });

    test('maps file write and share failures', () {
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

    test('maps unknown storage messages to fileReadFailed', () {
      expect(
        gpxFailureCodeFromAppFailure(
          const StorageFailure(message: 'other'),
        ),
        GpxFailureCode.fileReadFailed,
      );
    });

    test('maps non-storage failures to fileReadFailed', () {
      expect(
        gpxFailureCodeFromAppFailure(const ParseFailure()),
        GpxFailureCode.fileReadFailed,
      );
    });
  });

  group('GpxFileGatewayImpl.pickAndReadGpx', () {
    Future<void> stubPickFiles({required FilePickerResult? result}) {
      when(
        () => filePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          withData: any(named: 'withData'),
        ),
      ).thenAnswer((_) async => result);
      return Future<void>.value();
    }

    test('returns cancelled when picker dismissed', () async {
      await stubPickFiles(result: null);

      final outcome = await gateway.pickAndReadGpx();

      expect(outcome.isFailure, isTrue);
      expect(
        outcome.errorOrNull,
        isA<StorageFailure>().having(
          (f) => f.message,
          'message',
          kGpxPickCancelledMessage,
        ),
      );
    });

    test('returns decoded bytes when picker supplies in-memory data', () async {
      const xml = '<gpx version="1.1"></gpx>';
      await stubPickFiles(
        result: FilePickerResult([
          PlatformFile(
            name: 'route.gpx',
            size: xml.length,
            bytes: utf8.encode(xml),
          ),
        ]),
      );

      final outcome = await gateway.pickAndReadGpx();

      expect(outcome.valueOrNull, xml);
    });

    test('reads file from path when bytes are absent', () async {
      final dir = await Directory.systemTemp.createTemp('gpx_gateway_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/route.gpx');
      const xml = '<gpx version="1.1"><trk/></gpx>';
      await file.writeAsString(xml);

      await stubPickFiles(
        result: FilePickerResult([
          PlatformFile(
            name: 'route.gpx',
            size: xml.length,
            path: file.path,
          ),
        ]),
      );

      final outcome = await gateway.pickAndReadGpx();

      expect(outcome.valueOrNull, xml);
    });

    test('returns file read failure when path is missing', () async {
      await stubPickFiles(
        result: FilePickerResult([
          PlatformFile(name: 'route.gpx', size: 0),
        ]),
      );

      final outcome = await gateway.pickAndReadGpx();

      expect(
        outcome.errorOrNull,
        isA<StorageFailure>().having(
          (f) => f.message,
          'message',
          'gpx_file_read_failed',
        ),
      );
    });

    test('returns read failure when picker throws', () async {
      when(
        () => filePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          withData: any(named: 'withData'),
        ),
      ).thenThrow(Exception('picker failed'));

      final outcome = await gateway.pickAndReadGpx();

      expect(
        outcome.errorOrNull,
        isA<StorageFailure>().having(
          (f) => f.message,
          'message',
          'gpx_read_failed',
        ),
      );
    });
  });

  group('GpxFileGatewayImpl.writeAndShareGpx', () {
    test(
      'returns file write failure when temp directory is unavailable',
      () async {
        PathProviderPlatform.instance = _FakePathProvider(null);

        final outcome = await gateway.writeAndShareGpx(
          filename: 'route.gpx',
          gpxXml: '<gpx/>',
        );

        expect(
          outcome.errorOrNull,
          isA<StorageFailure>().having(
            (f) => f.message,
            'message',
            'gpx_file_write_failed',
          ),
        );
      },
    );

    test('returns success when share completes', () async {
      final dir = await Directory.systemTemp.createTemp('gpx_gateway_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      PathProviderPlatform.instance = _FakePathProvider(dir.path);
      SharePlatform.instance = _TestSharePlatform(
        (_) async => const ShareResult('', ShareResultStatus.success),
      );

      final outcome = await gateway.writeAndShareGpx(
        filename: 'route.gpx',
        gpxXml: '<gpx version="1.1"></gpx>',
      );

      expect(outcome.isSuccess, isTrue);
    });

    test('returns share failure when share sheet is unavailable', () async {
      final dir = await Directory.systemTemp.createTemp('gpx_gateway_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      PathProviderPlatform.instance = _FakePathProvider(dir.path);
      SharePlatform.instance = _TestSharePlatform(
        (_) async => const ShareResult('', ShareResultStatus.unavailable),
      );

      final outcome = await gateway.writeAndShareGpx(
        filename: 'route.gpx',
        gpxXml: '<gpx version="1.1"></gpx>',
      );

      expect(
        outcome.errorOrNull,
        isA<StorageFailure>().having(
          (f) => f.message,
          'message',
          'gpx_share_failed',
        ),
      );
    });

    test('returns share failure when share throws', () async {
      final dir = await Directory.systemTemp.createTemp('gpx_gateway_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      PathProviderPlatform.instance = _FakePathProvider(dir.path);
      SharePlatform.instance = _TestSharePlatform(
        (_) async => throw Exception('share failed'),
      );

      final outcome = await gateway.writeAndShareGpx(
        filename: 'route.gpx',
        gpxXml: '<gpx version="1.1"></gpx>',
      );

      expect(
        outcome.errorOrNull,
        isA<StorageFailure>().having(
          (f) => f.message,
          'message',
          'gpx_share_failed',
        ),
      );
    });
  });
}

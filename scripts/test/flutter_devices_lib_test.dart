import 'package:test/test.dart';

import '../flutter_devices_lib.dart';

void main() {
  group('isAndroidPlatform', () {
    test('accepts android targets', () {
      expect(isAndroidPlatform('android-arm64'), isTrue);
    });

    test('rejects ios and desktop', () {
      expect(isAndroidPlatform('ios'), isFalse);
      expect(isAndroidPlatform('darwin'), isFalse);
    });
  });

  group('parseFlutterDevicesMachineJson', () {
    test('keeps android devices and drops ios/desktop', () {
      const json = '''
[
  {"id": "emulator-5554", "name": "Pixel 9", "emulator": true, "targetPlatform": "android-arm64"},
  {"id": "00008101-000", "name": "iPhone", "emulator": false, "targetPlatform": "ios"},
  {"id": "macos", "name": "macOS", "emulator": false, "targetPlatform": "darwin"}
]
''';
      final devices = parseFlutterDevicesMachineJson(json);
      expect(devices, hasLength(1));
      expect(devices.single.id, 'emulator-5554');
      expect(devices.single.emulator, isTrue);
    });

    test('returns empty list for blank input', () {
      expect(parseFlutterDevicesMachineJson(''), isEmpty);
    });
  });

  group('parseFlutterEmulatorsOutput', () {
    const sample = '''
Id                  • Name                • Manufacturer • Platform

Pixel_9             • Pixel 9             • Google       • android
iPhone_16           • iPhone 16           • Apple        • ios
Pixel_7             • Pixel 7             • Google       • android
''';

    test('includes android AVDs only', () {
      final emulators = parseFlutterEmulatorsOutput(sample, runningAvdIds: {});
      expect(emulators.map((e) => e.id), ['Pixel_9', 'Pixel_7']);
      expect(
        emulators.first.label,
        'Pixel 9 — Android simulator (start Pixel_9)',
      );
    });

    test('skips AVDs that are already running', () {
      final emulators = parseFlutterEmulatorsOutput(
        sample,
        runningAvdIds: {'Pixel_9'},
      );
      expect(emulators.map((e) => e.id), ['Pixel_7']);
    });

    test('skips header and malformed lines', () {
      final emulators = parseFlutterEmulatorsOutput(
        'Id • Name • Manufacturer • Platform\n'
        'no bullet line\n'
        'OnlyThree • Parts • Here\n',
        runningAvdIds: {},
      );
      expect(emulators, isEmpty);
    });
  });

  group('buildRunTargets', () {
    test('orders connected run targets before launch rows', () {
      final targets = buildRunTargets(
        connected: [(id: 'emulator-5554', label: 'connected')],
        launchable: [(id: 'Pixel_9', label: 'start Pixel 9')],
      );
      expect(targets, [
        (action: 'run', id: 'emulator-5554', label: 'connected'),
        (action: 'launch', id: 'Pixel_9', label: 'start Pixel 9'),
      ]);
    });
  });

  group('displayAvdName', () {
    test('replaces underscores with spaces', () {
      expect(displayAvdName('Pixel_9'), 'Pixel 9');
    });
  });
}

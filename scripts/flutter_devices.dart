// Flutter device/emulator helpers for make dev (no extra deps beyond Dart SDK).
//
// Usage:
//   dart scripts/flutter_devices.dart list-run-targets
//     action<TAB>id<TAB>label
//     action: "run" (connected) | "launch" (AVD not already running)
//   dart scripts/flutter_devices.dart connected-ids
//   dart scripts/flutter_devices.dart first-new-booted-device <known-id>...
import 'dart:io';

import 'flutter_devices_lib.dart';

Future<void> main(List<String> args) async {
  final command = args.isNotEmpty ? args[0] : '';
  switch (command) {
    case 'list-run-targets':
      _printRunTargets(await _listRunTargets());
    case 'connected-ids':
      for (final id in await _connectedMobileDeviceIds()) {
        stdout.writeln(id);
      }
    case 'first-new-booted-device':
      var expectedAvd = '';
      final before = <String>{};
      for (var i = 1; i < args.length; i++) {
        final arg = args[i];
        if (arg == '--avd' && i + 1 < args.length) {
          expectedAvd = args[++i];
        } else if (arg.isNotEmpty) {
          before.add(arg);
        }
      }
      final id = await _firstNewBootedDevice(
        before,
        expectedAvd: expectedAvd.isEmpty ? null : expectedAvd,
      );
      if (id != null) {
        stdout.writeln(id);
      }
    default:
      stderr.writeln(
        'Usage: dart scripts/flutter_devices.dart '
        '<list-run-targets|connected-ids|first-new-booted-device>',
      );
      exit(64);
  }
}

void _printRunTargets(List<RunTarget> items) {
  for (final item in items) {
    stdout.writeln('${item.action}\t${item.id}\t${item.label}');
  }
}

Future<List<ConnectedDevice>> _listConnectedAndroidDevicesRaw() async {
  final result = await Process.run('flutter', ['devices', '--machine']);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  return parseFlutterDevicesMachineJson('${result.stdout}');
}

Future<List<String>> _connectedMobileDeviceIds() async {
  return (await _listConnectedAndroidDevicesRaw()).map((d) => d.id).toList();
}

Future<String?> _avdNameForDevice(String deviceId) async {
  final result = await Process.run('adb', [
    '-s',
    deviceId,
    'shell',
    'getprop',
    'ro.boot.qemu.avd_name',
  ]);
  if (result.exitCode != 0) {
    return null;
  }
  final name = '${result.stdout}'.trim();
  return name.isEmpty ? null : name;
}

Future<bool> _isBootCompleted(String deviceId) async {
  final result = await Process.run('adb', [
    '-s',
    deviceId,
    'shell',
    'getprop',
    'sys.boot_completed',
  ]);
  if (result.exitCode != 0) {
    return false;
  }
  return '${result.stdout}'.trim() == '1';
}

Future<Set<String>> _runningAvdIds() async {
  final running = <String>{};
  for (final device in await _listConnectedAndroidDevicesRaw()) {
    if (!device.emulator) {
      continue;
    }
    final avdName = await _avdNameForDevice(device.id);
    if (avdName != null) {
      running.add(avdName);
    }
  }
  return running;
}

Future<List<({String id, String label})>> _listConnectedRunTargets() async {
  final targets = <({String id, String label})>[];
  for (final device in await _listConnectedAndroidDevicesRaw()) {
    if (device.emulator) {
      final avdName = await _avdNameForDevice(device.id);
      final friendly = avdName != null ? displayAvdName(avdName) : device.name;
      targets.add((
        id: device.id,
        label: '$friendly — Android emulator (connected, ${device.id})',
      ));
    } else {
      targets.add((
        id: device.id,
        label: '${device.name} — Android device (connected, ${device.id})',
      ));
    }
  }
  return targets;
}

Future<List<EmulatorTarget>> _listLaunchableEmulators(
  Set<String> runningAvdIds,
) async {
  final result = await Process.run('flutter', ['emulators']);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  return parseFlutterEmulatorsOutput(
    '${result.stdout}',
    runningAvdIds: runningAvdIds,
  );
}

Future<List<RunTarget>> _listRunTargets() async {
  final runningAvds = await _runningAvdIds();
  return buildRunTargets(
    connected: await _listConnectedRunTargets(),
    launchable: await _listLaunchableEmulators(runningAvds),
  );
}

Future<String?> _firstNewBootedDevice(
  Set<String> before, {
  String? expectedAvd,
}) async {
  for (final device in await _listConnectedAndroidDevicesRaw()) {
    if (before.contains(device.id)) {
      continue;
    }
    if (!await _isBootCompleted(device.id)) {
      continue;
    }
    if (expectedAvd != null) {
      final avdName = await _avdNameForDevice(device.id);
      if (avdName != expectedAvd) {
        continue;
      }
    }
    return device.id;
  }
  return null;
}

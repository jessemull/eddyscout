// Flutter device/emulator helpers for make dev (no extra deps beyond Dart SDK).
//
// Usage:
//   dart scripts/flutter_devices.dart list-run-targets
//     action<TAB>id<TAB>label
//     action: "run" (connected) | "launch" (AVD not already running)
//   dart scripts/flutter_devices.dart connected-ids
//   dart scripts/flutter_devices.dart first-new-booted-device <known-id>...
import 'dart:convert';
import 'dart:io';

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
      final before = args.skip(1).toSet();
      final id = await _firstNewBootedDevice(before);
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

void _printRunTargets(List<({String action, String id, String label})> items) {
  for (final item in items) {
    stdout.writeln('${item.action}\t${item.id}\t${item.label}');
  }
}

bool _isMobilePlatform(String platform) {
  return platform.startsWith('android') || platform.startsWith('ios');
}

Future<List<({String id, String name, bool emulator})>>
_listConnectedMobileDevicesRaw() async {
  final result = await Process.run('flutter', ['devices', '--machine']);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  final raw = jsonDecode('${result.stdout}') as List<dynamic>;
  final devices = <({String id, String name, bool emulator})>[];
  for (final entry in raw) {
    final map = Map<String, dynamic>.from(entry as Map);
    final platform = '${map['targetPlatform'] ?? ''}';
    if (!_isMobilePlatform(platform)) {
      continue;
    }
    final id = '${map['id'] ?? ''}';
    if (id.isEmpty) {
      continue;
    }
    devices.add((
      id: id,
      name: '${map['name'] ?? id}',
      emulator: map['emulator'] == true,
    ));
  }
  return devices;
}

Future<List<String>> _connectedMobileDeviceIds() async {
  return (await _listConnectedMobileDevicesRaw()).map((d) => d.id).toList();
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
  for (final device in await _listConnectedMobileDevicesRaw()) {
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

String _displayAvdName(String avdId) {
  return avdId.replaceAll('_', ' ');
}

Future<List<({String id, String label})>> _listConnectedRunTargets() async {
  final targets = <({String id, String label})>[];
  for (final device in await _listConnectedMobileDevicesRaw()) {
    final os = device.id.contains('ios') ? 'iOS' : 'Android';
    if (device.emulator) {
      final avdName = await _avdNameForDevice(device.id);
      final friendly = avdName != null ? _displayAvdName(avdName) : device.name;
      targets.add((
        id: device.id,
        label: '$friendly — $os emulator (connected, ${device.id})',
      ));
    } else {
      targets.add((
        id: device.id,
        label: '${device.name} — $os device (connected, ${device.id})',
      ));
    }
  }
  return targets;
}

Future<List<({String id, String label})>> _listLaunchableEmulators(
  Set<String> runningAvdIds,
) async {
  final result = await Process.run('flutter', ['emulators']);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  final emulators = <({String id, String label})>[];
  for (final line in '${result.stdout}'.split('\n')) {
    if (!line.contains('•')) {
      continue;
    }
    final parts = line.split('•').map((part) => part.trim()).toList();
    if (parts.length < 4) {
      continue;
    }
    final platform = parts[3].toLowerCase();
    if (platform != 'android' && platform != 'ios') {
      continue;
    }
    final id = parts[0];
    final name = parts[1];
    if (id.isEmpty || id == 'Id' || runningAvdIds.contains(id)) {
      continue;
    }
    final os = platform == 'ios' ? 'iOS' : 'Android';
    emulators.add((id: id, label: '$name — $os simulator (start $id)'));
  }
  return emulators;
}

Future<List<({String action, String id, String label})>>
_listRunTargets() async {
  final targets = <({String action, String id, String label})>[];
  final runningAvds = await _runningAvdIds();

  for (final device in await _listConnectedRunTargets()) {
    targets.add((action: 'run', id: device.id, label: device.label));
  }
  for (final emulator in await _listLaunchableEmulators(runningAvds)) {
    targets.add((action: 'launch', id: emulator.id, label: emulator.label));
  }
  return targets;
}

Future<String?> _firstNewBootedDevice(Set<String> before) async {
  for (final device in await _listConnectedMobileDevicesRaw()) {
    if (before.contains(device.id)) {
      continue;
    }
    if (await _isBootCompleted(device.id)) {
      return device.id;
    }
  }
  return null;
}

// Flutter device/emulator helpers for make dev (no extra deps beyond Dart SDK).
//
// Usage:
//   dart scripts/flutter_devices.dart list-run-targets
//     action<TAB>id<TAB>label — action is "run" (connected) or "launch" (AVD)
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final command = args.isNotEmpty ? args[0] : '';
  switch (command) {
    case 'list-run-targets':
      _printRunTargets(await _listRunTargets());
    default:
      stderr.writeln(
        'Usage: dart scripts/flutter_devices.dart list-run-targets',
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

Future<List<({String id, String label})>> _listConnectedMobileDevices() async {
  final result = await Process.run('flutter', ['devices', '--machine']);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  final raw = jsonDecode('${result.stdout}') as List<dynamic>;
  final devices = <({String id, String label})>[];
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
    final name = '${map['name'] ?? id}';
    final os = platform.startsWith('ios') ? 'iOS' : 'Android';
    final emulator = map['emulator'] == true;
    final kind = emulator ? 'emulator' : 'device';
    devices.add((id: id, label: '$name — $os $kind (connected)'));
  }
  return devices;
}

Future<List<({String id, String label})>> _listMobileEmulators() async {
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
    if (id.isEmpty || id == 'Id') {
      continue;
    }
    final os = platform == 'ios' ? 'iOS' : 'Android';
    emulators.add((id: id, label: '$name — $os simulator (launch)'));
  }
  return emulators;
}

Future<List<({String action, String id, String label})>>
_listRunTargets() async {
  final targets = <({String action, String id, String label})>[];
  for (final device in await _listConnectedMobileDevices()) {
    targets.add((action: 'run', id: device.id, label: device.label));
  }
  for (final emulator in await _listMobileEmulators()) {
    targets.add((action: 'launch', id: emulator.id, label: emulator.label));
  }
  return targets;
}

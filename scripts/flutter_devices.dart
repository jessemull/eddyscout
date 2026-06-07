// Flutter device/emulator helpers for make dev (no extra deps beyond Dart SDK).
//
// Usage:
//   dart scripts/flutter_devices.dart android-emulators   # id<TAB>label per line
//   dart scripts/flutter_devices.dart android-devices     # id<TAB>label per line
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final command = args.isNotEmpty ? args[0] : '';
  switch (command) {
    case 'android-emulators':
      _printPairs(await _listAndroidEmulators());
    case 'android-devices':
      _printPairs(await _listAndroidDevices());
    default:
      stderr.writeln(
        'Usage: dart scripts/flutter_devices.dart '
        '<android-emulators|android-devices>',
      );
      exit(64);
  }
}

void _printPairs(List<({String id, String label})> items) {
  for (final item in items) {
    stdout.writeln('${item.id}\t${item.label}');
  }
}

Future<List<({String id, String label})>> _listAndroidEmulators() async {
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
    if (platform != 'android') {
      continue;
    }
    final id = parts[0];
    final name = parts[1];
    if (id.isEmpty || id == 'Id') {
      continue;
    }
    emulators.add((id: id, label: '$name ($id)'));
  }
  return emulators;
}

Future<List<({String id, String label})>> _listAndroidDevices() async {
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
    if (!platform.startsWith('android')) {
      continue;
    }
    final id = '${map['id'] ?? ''}';
    if (id.isEmpty) {
      continue;
    }
    final name = '${map['name'] ?? id}';
    final emulator = map['emulator'] == true;
    final suffix = emulator ? ' (emulator)' : '';
    devices.add((id: id, label: '$name$suffix'));
  }
  return devices;
}

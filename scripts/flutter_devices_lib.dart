// Pure parsing helpers for scripts/flutter_devices.dart (unit-testable).
library;

import 'dart:convert';

/// Connected mobile device from `flutter devices --machine`.
typedef ConnectedDevice = ({
  String id,
  String name,
  bool emulator,
  String targetPlatform,
});

/// Launchable emulator row for the make dev menu.
typedef EmulatorTarget = ({String id, String label});

/// Menu row: run an already-connected device or launch an AVD.
typedef RunTarget = ({String action, String id, String label});

/// make dev supports Android only until dev.sh routes iOS through flutter run.
bool isAndroidPlatform(String platform) => platform.startsWith('android');

/// Parses `flutter devices --machine` JSON; keeps Android targets only.
List<ConnectedDevice> parseFlutterDevicesMachineJson(String jsonText) {
  final raw = jsonText.trim();
  if (raw.isEmpty) {
    return [];
  }
  final decoded = jsonDecode(raw);
  if (decoded is! List<dynamic>) {
    return [];
  }
  final devices = <ConnectedDevice>[];
  for (final entry in decoded) {
    if (entry is! Map) {
      continue;
    }
    final map = Map<String, dynamic>.from(entry);
    final platform = '${map['targetPlatform'] ?? ''}';
    if (!isAndroidPlatform(platform)) {
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
      targetPlatform: platform,
    ));
  }
  return devices;
}

/// Parses `flutter emulators` text; Android AVDs only (iOS deferred).
List<EmulatorTarget> parseFlutterEmulatorsOutput(
  String output, {
  required Set<String> runningAvdIds,
}) {
  final emulators = <EmulatorTarget>[];
  for (final line in output.split('\n')) {
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
    if (id.isEmpty || id == 'Id' || runningAvdIds.contains(id)) {
      continue;
    }
    emulators.add((id: id, label: '$name — Android simulator (start $id)'));
  }
  return emulators;
}

/// Merges connected devices and launchable AVDs into make dev menu rows.
List<RunTarget> buildRunTargets({
  required List<({String id, String label})> connected,
  required List<EmulatorTarget> launchable,
}) {
  final targets = <RunTarget>[];
  for (final device in connected) {
    targets.add((action: 'run', id: device.id, label: device.label));
  }
  for (final emulator in launchable) {
    targets.add((action: 'launch', id: emulator.id, label: emulator.label));
  }
  return targets;
}

String displayAvdName(String avdId) => avdId.replaceAll('_', ' ');

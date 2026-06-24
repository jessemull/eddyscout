import 'dart:convert';
import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bundled launch reachability index asset', () {
    const assetPath = 'assets/data/launch_reachability_index.json';

    test('$assetPath exists and parses with expected schema', () {
      final file = File(assetPath);
      expect(file.existsSync(), isTrue, reason: 'missing asset $assetPath');

      final index = parseLaunchReachabilityIndex(file.readAsStringSync());

      expect(index.schemaVersion, 1);
      expect(index.distanceModel, 'graph_plus_snap');
      expect(index.snapMaxMeters, kReachabilitySnapMaxMeters);
      expect(index.thresholdsMi, kReachabilityThresholdsMi);
      expect(index.crossSystemReachability, isTrue);
      expect(index.entries, isNotEmpty);

      for (final launch in kLaunchPoints) {
        expect(
          index.entries.containsKey(launch.id),
          isTrue,
          reason: 'missing entry for ${launch.id}',
        );
        final entry = index.entries[launch.id]!;
        for (final band in [
          entry.within5Mi,
          entry.within10Mi,
          entry.within20Mi,
        ]) {
          for (final targetId in band) {
            expect(
              kLaunchPoints.any((l) => l.id == targetId),
              isTrue,
              reason: 'unknown target launch $targetId',
            );
            expect(targetId, isNot(launch.id));
          }
        }
      }
    });

    test('$assetPath is valid JSON with required top-level keys', () {
      final root =
          jsonDecode(File(assetPath).readAsStringSync())
              as Map<String, dynamic>;

      expect(root['schemaVersion'], isA<int>());
      expect(root['generatedAt'], isA<String>());
      expect(root['distanceModel'], isA<String>());
      expect(root['snapMaxMeters'], isA<num>());
      expect(root['thresholdsMi'], isA<List<dynamic>>());
      expect(root['crossSystemReachability'], isA<bool>());

      final entries = root['entries'] as Map<String, dynamic>;
      expect(entries, isNotEmpty);

      for (final entry in entries.values) {
        final bands = entry as Map<String, dynamic>;
        expect(bands.keys, containsAll(['5mi', '10mi', '20mi']));
        for (final band in bands.values) {
          expect(band, isA<List<dynamic>>());
        }
      }
    });
  });
}

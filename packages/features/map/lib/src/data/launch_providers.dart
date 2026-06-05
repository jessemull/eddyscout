import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/data/launch_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves a curated launch by id.
final Provider<LaunchPoint> Function(String) launchPointByIdProvider =
    Provider.family<LaunchPoint, String>((ref, id) {
      return kLaunchPoints.firstWhere((launch) => launch.id == id);
    });

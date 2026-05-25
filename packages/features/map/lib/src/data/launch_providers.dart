import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'launch_points.dart';

/// Resolves a curated launch by id.
final ProviderFamily<LaunchPoint, String> launchPointByIdProvider =
    Provider.family<LaunchPoint, String>((ref, id) {
      return kLaunchPoints.firstWhere((launch) => launch.id == id);
    });

import '../data/launch_points.dart';
import '../domain/launch_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves a curated launch by id.
final launchPointByIdProvider = Provider.family<LaunchPoint, String>((ref, id) {
  return kLaunchPoints.firstWhere((launch) => launch.id == id);
});

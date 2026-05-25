import 'package:eddyscout/conditions/conditions_models.dart';
import 'package:eddyscout/conditions/conditions_service.dart';
import 'package:eddyscout/data/launch_models.dart';
import 'package:eddyscout/data/launch_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves a curated launch by id.
final launchPointByIdProvider = Provider.family<LaunchPoint, String>((ref, id) {
  return kLaunchPoints.firstWhere((launch) => launch.id == id);
});

/// Shared conditions fetcher for launch detail and future feature code.
final conditionsServiceProvider = Provider<ConditionsService>((ref) {
  return ConditionsService();
});

/// Loads environmental conditions for a launch id.
final conditionsSnapshotProvider = FutureProvider.autoDispose
    .family<ConditionsSnapshot, String>((ref, launchId) {
      final launch = ref.watch(launchPointByIdProvider(launchId));
      return ref.watch(conditionsServiceProvider).load(launch);
    });

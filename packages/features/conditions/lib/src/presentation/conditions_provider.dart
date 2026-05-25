import 'package:eddyscout_conditions/src/data/conditions_http_provider.dart';
import 'package:eddyscout_conditions/src/data/conditions_service.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared conditions fetcher for launch detail and future feature code.
final Provider<ConditionsService> conditionsServiceProvider =
    Provider<ConditionsService>((ref) {
      return ConditionsService(ref.watch(conditionsHttpClientProvider));
    });

/// Loads environmental conditions for a launch.
final AutoDisposeFutureProviderFamily<ConditionsSnapshot, LaunchPoint>
conditionsSnapshotProvider = FutureProvider.autoDispose
    .family<ConditionsSnapshot, LaunchPoint>((ref, launch) {
      return ref.watch(conditionsServiceProvider).load(launch);
    });

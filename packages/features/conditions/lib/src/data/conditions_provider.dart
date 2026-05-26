import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/conditions_http_provider.dart';
import 'package:eddyscout_conditions/src/data/conditions_service.dart';
import 'package:eddyscout_conditions/src/domain/conditions_load_exception.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/repositories/conditions_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared conditions repository (HTTP-backed [ConditionsService]).
final Provider<ConditionsRepository> conditionsRepositoryProvider =
    Provider<ConditionsRepository>((ref) {
      return ConditionsService(ref.watch(conditionsHttpClientProvider));
    });

/// Alias for tests and overrides that need the concrete service type.
final Provider<ConditionsService> conditionsServiceProvider =
    Provider<ConditionsService>((ref) {
      final repo = ref.watch(conditionsRepositoryProvider);
      return repo as ConditionsService;
    });

/// Loads environmental conditions for a launch.
final AutoDisposeFutureProviderFamily<ConditionsSnapshot, LaunchPoint>
conditionsSnapshotProvider = FutureProvider.autoDispose
    .family<ConditionsSnapshot, LaunchPoint>((ref, launch) async {
      final cancelToken = CancelToken();
      ref.onDispose(() {
        if (!cancelToken.isCancelled) {
          cancelToken.cancel('conditionsSnapshotProvider disposed');
        }
      });
      final result = await ref
          .watch(conditionsRepositoryProvider)
          .load(launch, cancelToken: cancelToken);
      return result.when(
        success: (value) => value,
        failure: (error) => throw ConditionsLoadException(error),
      );
    });

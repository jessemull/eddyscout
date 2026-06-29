import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/presentation/conditions_debug_log.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_go_no_go_provider.g.dart';

/// Inputs for [launchGoNoGoResultProvider].
typedef LaunchGoNoGoParams = ({
  LaunchPoint launch,
  ConditionsSnapshot snapshot,
  GoNoGoProfile profile,
});

/// Go/no-go evaluation for a launch and conditions snapshot.
@riverpod
GoNoGoResult launchGoNoGoResult(Ref ref, LaunchGoNoGoParams params) {
  final result = GoNoGoEvaluator.evaluate(
    params.launch,
    params.snapshot,
    profile: params.profile,
  );
  conditionsDebugLogGoNoGo('evaluate', params.launch, result);
  return result;
}

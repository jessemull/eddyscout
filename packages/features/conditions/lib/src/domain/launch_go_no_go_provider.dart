import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inputs for [launchGoNoGoResultProvider].
typedef LaunchGoNoGoParams = ({
  LaunchPoint launch,
  ConditionsSnapshot snapshot,
  GoNoGoProfile profile,
});

/// Go/no-go evaluation for a launch and conditions snapshot.
final Provider<GoNoGoResult> Function(LaunchGoNoGoParams)
launchGoNoGoResultProvider = Provider.autoDispose
    .family<GoNoGoResult, LaunchGoNoGoParams>(
      (ref, params) => GoNoGoEvaluator.evaluate(
        params.launch,
        params.snapshot,
        profile: params.profile,
      ),
    );

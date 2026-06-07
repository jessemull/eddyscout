import 'dart:async' show unawaited;

import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/launch_go_no_go_provider.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_profile_provider.dart';
import 'package:eddyscout_conditions/src/presentation/launch_detail/launch_detail_providers.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'helpers.dart';
part 'widgets_ai_summary.dart';
part 'widgets_conditions_helpers.dart';
part 'widgets_go_no_go.dart';
part 'widgets_launch_detail_body.dart';
part 'widgets_reports.dart';
part 'widgets_snapshot_cards.dart';

/// Launch conditions, go/no-go, Firebase reports, and skill profile controls.
class LaunchDetailScreen extends ConsumerWidget {
  /// Creates a detail view for [launch].
  const LaunchDetailScreen({required this.launch, super.key});

  /// Launch shown on this screen.
  final LaunchPoint launch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillProfileAsync = ref.watch(goNoGoProfileProvider);
    final conditionsAsync = ref.watch(conditionsSnapshotProvider(launch));
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(launch.name)),
      body: skillProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(
          message: _launchDetailSkillProfileErrorMessage(l10n, error),
        ),
        data: (skillProfile) => conditionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorBody(
            message: _launchDetailConditionsErrorMessage(l10n, error),
          ),
          data: (data) => _LaunchDetailBody(
            launch: launch,
            skillProfile: skillProfile,
            data: data,
          ),
        ),
      ),
    );
  }
}

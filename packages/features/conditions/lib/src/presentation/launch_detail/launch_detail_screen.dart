import 'dart:async' show unawaited;

import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/launch_go_no_go_provider.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_profile_provider.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/condition_report_submit_provider.dart';
import '../../data/condition_reports_provider.dart';
import '../../data/conditions_ai_summary_provider.dart';
import '../../data/conditions_provider.dart';
import '../../data/firebase/firebase_bootstrap.dart';
import '../../data/firebase/firebase_flags.dart';

part 'helpers.dart';
part 'widgets_conditions.dart';
part 'widgets_reports.dart';

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
          data: (data) {
            final goNoGo = ref.watch(
              launchGoNoGoResultProvider((
                launch: launch,
                snapshot: data,
                profile: skillProfile,
              )),
            );
            return ListView(
              padding: const EdgeInsets.all(Spacing.md),
              children: [
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: [
                    Semantics(
                      label: l10n.launchDetailWindExposureSemantics(
                        launch.windExposure.label,
                      ),
                      child: Chip(
                        label: Text(launch.windExposure.label),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    Semantics(
                      label: l10n.launchDetailRiverSemantics(
                        _launchDetailRiverLabel(l10n, launch.riverSystem),
                      ),
                      child: Chip(
                        label: Text(
                          _launchDetailRiverLabel(l10n, launch.riverSystem),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    Semantics(
                      label: l10n.launchDetailTideRelevanceSemantics(
                        launch.tideRelevance.shortLabel,
                      ),
                      child: Chip(
                        label: Text(launch.tideRelevance.shortLabel),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md - Spacing.xs),
                Text(
                  l10n.launchDetailSkillSectionTitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: Spacing.sm),
                Semantics(
                  label: l10n.launchDetailSkillSectionTitle,
                  child: SegmentedButton<GoNoGoProfile>(
                    segments: [
                      ButtonSegment(
                        value: GoNoGoProfile.beginner,
                        label: Text(l10n.launchDetailSkillBeginner),
                      ),
                      ButtonSegment(
                        value: GoNoGoProfile.intermediate,
                        label: Text(l10n.launchDetailSkillIntermediate),
                      ),
                      ButtonSegment(
                        value: GoNoGoProfile.advanced,
                        label: Text(l10n.launchDetailSkillAdvanced),
                      ),
                    ],
                    selected: {skillProfile},
                    onSelectionChanged: (next) {
                      unawaited(
                        ref
                            .read(goNoGoProfileProvider.notifier)
                            .setProfile(next.single),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Spacing.md - Spacing.xs),
                Text(
                  launch.shortNote,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _GoNoGoCard(result: goNoGo),
                if (firebaseCallablesAvailable) ...[
                  const SizedBox(height: 16),
                  _AiSummaryCard(
                    launch: launch,
                    snapshot: data,
                    goNoGo: goNoGo,
                    skillProfile: skillProfile,
                  ),
                  const SizedBox(height: 16),
                  _LaunchReportsDigestCard(launchId: launch.id),
                  const SizedBox(height: 16),
                  _RecentConditionReports(launchId: launch.id),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.feedback_outlined),
                    title: Text(l10n.launchDetailReportConditionsTitle),
                    subtitle: Text(l10n.launchDetailReportConditionsSubtitle),
                    onTap: () => _openLaunchDetailConditionReportSheet(
                      ref,
                      context,
                      launch,
                      data.fetchedAt,
                    ),
                  ),
                ] else if (kUseFirebase && !kIsWeb) ...[
                  const SizedBox(height: 12),
                  Text(
                    _launchDetailFirebaseUnavailableMessage(l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FirebaseBootstrap.lastError != null
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.launchDetailConditionsSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _WeatherCard(snapshot: data),
                if (data.riverFlow != null || data.riverError != null) ...[
                  const SizedBox(height: 12),
                  _RiverCard(snapshot: data),
                ],
                if (launch.tideRelevance != TideRelevance.none) ...[
                  const SizedBox(height: 12),
                  _TideCard(snapshot: data, launch: launch),
                ],
                if (launch.marineZoneId case final zoneId?) ...[
                  const SizedBox(height: 12),
                  _MarineCard(snapshot: data, zoneId: zoneId),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.launchDetailDisclaimerTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.launchDetailDisclaimerBody,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.launchDetailDataSourcesTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _launchDetailAttributionLines(l10n, data),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

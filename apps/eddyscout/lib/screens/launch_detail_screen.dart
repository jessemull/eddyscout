import 'dart:async' show unawaited;

import 'package:eddyscout/preferences/go_no_go_profile_provider.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'launch_detail/helpers.dart';
part 'launch_detail/widgets_conditions.dart';
part 'launch_detail/widgets_reports.dart';

/// Launch conditions, go/no-go, Firebase reports, and skill profile controls.
class LaunchDetailScreen extends ConsumerWidget {
  const LaunchDetailScreen({required this.launch, super.key});

  final LaunchPoint launch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillProfile =
        ref.watch(goNoGoProfileProvider).value ?? GoNoGoProfile.intermediate;
    final conditionsAsync = ref.watch(conditionsSnapshotProvider(launch));
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(launch.name)),
      body: conditionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(
          message: launchDetailConditionsErrorMessage(l10n, error),
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
                      launchDetailRiverLabel(l10n, launch.riverSystem),
                    ),
                    child: Chip(
                      label: Text(
                        launchDetailRiverLabel(l10n, launch.riverSystem),
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
                  onTap: () => openLaunchDetailConditionReportSheet(
                    ref,
                    context,
                    launch,
                    data.fetchedAt,
                  ),
                ),
              ] else if (kUseFirebase && !kIsWeb) ...[
                const SizedBox(height: 12),
                Text(
                  launchDetailFirebaseUnavailableMessage(l10n),
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
                launchDetailAttributionLines(l10n, data),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

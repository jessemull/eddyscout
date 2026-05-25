import 'dart:async' show unawaited;

import 'package:eddyscout/preferences/go_no_go_profile_provider.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(launch.name)),
      body: conditionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(
          message: launchDetailConditionsErrorMessage(error),
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
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(launch.windExposure.label),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(launchDetailRiverLabel(launch.riverSystem)),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(launch.tideRelevance.shortLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Skill (wind thresholds)',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<GoNoGoProfile>(
                segments: const [
                  ButtonSegment(
                    value: GoNoGoProfile.beginner,
                    label: Text('Beginner'),
                  ),
                  ButtonSegment(
                    value: GoNoGoProfile.intermediate,
                    label: Text('Intermed.'),
                  ),
                  ButtonSegment(
                    value: GoNoGoProfile.advanced,
                    label: Text('Advanced'),
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
              const SizedBox(height: 12),
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
                  title: const Text('Report conditions'),
                  subtitle: const Text(
                    'Short note to help others (stored securely)',
                  ),
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
                  launchDetailFirebaseUnavailableMessage(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FirebaseBootstrap.lastError != null
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Conditions',
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
              Text('Disclaimer', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                'EddyScout shows third-party data for planning only. '
                'It is not a substitute for your judgment, skill assessment, '
                'or on-site scouting. '
                'River and marine conditions can change rapidly.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Data sources',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                launchDetailAttributionLines(data),
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

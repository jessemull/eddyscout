import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../conditions/conditions_models.dart';
import '../conditions/conditions_provider.dart';
import '../data/launch_models.dart';
import '../decision/go_no_go.dart';
import '../firebase/condition_reports_provider.dart';
import '../firebase/conditions_ai_summary_provider.dart';
import '../firebase/conditions_callables.dart';
import '../firebase/firebase_bootstrap.dart';
import '../firebase/firebase_flags.dart';
import '../preferences/go_no_go_profile_provider.dart';
import 'launch_detail_providers.dart';

class LaunchDetailScreen extends ConsumerWidget {
  const LaunchDetailScreen({super.key, required this.launch});

  final LaunchPoint launch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillProfile =
        ref.watch(goNoGoProfileProvider).value ?? GoNoGoProfile.intermediate;
    final conditionsAsync = ref.watch(conditionsSnapshotProvider(launch.id));
    return Scaffold(
      appBar: AppBar(title: Text(launch.name)),
      body: conditionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(message: '$error'),
        data: (data) {
          final goNoGo = GoNoGoEvaluator.evaluate(
            launch,
            data,
            profile: skillProfile,
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
                    label: Text(_riverLabel(launch.riverSystem)),
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
                  ref
                      .read(goNoGoProfileProvider.notifier)
                      .setProfile(next.single);
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
                  onTap: () => _openConditionReportSheet(
                    ref,
                    context,
                    launch,
                    data.fetchedAt,
                  ),
                ),
              ] else if (kUseFirebase && !kIsWeb) ...[
                const SizedBox(height: 12),
                Text(
                  _firebaseUnavailableMessage(),
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
              if (launch.marineZoneId != null) ...[
                const SizedBox(height: 12),
                _MarineCard(snapshot: data, zoneId: launch.marineZoneId!),
              ],
              const SizedBox(height: 24),
              Text('Disclaimer', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                'EddyScout shows third-party environmental data for planning only. '
                'It is not a substitute for your judgment, skill assessment, or on-site scouting. '
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
                _attributionLines(data),
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

String _firebaseUnavailableMessage() {
  if (FirebaseBootstrap.lastError != null) {
    final hint = FirebaseBootstrap.hintForLastError();
    final buf = StringBuffer()
      ..writeln(
        'Firebase did not start, so AI summary and reports are unavailable.',
      )
      ..writeln()
      ..writeln('Error: ${FirebaseBootstrap.lastError}')
      ..writeln();
    if (hint != null) {
      buf.writeln(hint);
      buf.writeln();
    }
    buf.writeln(
      'Otherwise check: correct `google-services.json` for package '
      '`com.eddyscout.eddyscout`, network, then full app restart (not hot reload).',
    );
    return buf.toString();
  }
  return 'Firebase features need a successful app init and anonymous sign-in. '
      'Add `google-services.json`, enable Anonymous auth, deploy functions, '
      'and rebuild with `USE_FIREBASE=true` in `.local.env` (`make run`).';
}

String _riverLabel(RiverSystem r) => switch (r) {
  RiverSystem.willamette => 'Willamette',
  RiverSystem.columbia => 'Columbia / regional',
  RiverSystem.clackamas => 'Clackamas',
  RiverSystem.slough => 'Slough / confluence',
};

Future<void> _openConditionReportSheet(
  WidgetRef ref,
  BuildContext context,
  LaunchPoint launch,
  DateTime conditionsFetchedAt,
) async {
  final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetCtx) {
      return _ConditionReportSheet(
        launch: launch,
        conditionsFetchedAt: conditionsFetchedAt,
        scaffoldMessenger: scaffoldMessenger,
        onSuccessFeedback: () {
          ref.read(conditionReportsRefreshTokenProvider.notifier).state++;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              return;
            }
            scaffoldMessenger?.showSnackBar(
              const SnackBar(content: Text('Thanks—report submitted.')),
            );
          });
        },
      );
    },
  );
}

class _LaunchReportsDigestCard extends ConsumerWidget {
  const _LaunchReportsDigestCard({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digestState = ref.watch(launchReportsDigestProvider(launchId));
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.groups_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Community digest (AI)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Paraphrases recent paddler notes below—not official conditions or river status.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (digestState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (digestState.errorMessage != null) ...[
              Text(
                digestState.errorMessage!,
                style: TextStyle(color: scheme.error, fontSize: 13),
              ),
              TextButton.icon(
                onPressed: () => ref
                    .read(launchReportsDigestProvider(launchId).notifier)
                    .summarize(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ] else if (digestState.result != null) ...[
              if (digestState.result!.noReports)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'No paddler reports to summarize yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(launchReportsDigestProvider(launchId).notifier)
                          .summarize(),
                      child: const Text('Check again'),
                    ),
                  ],
                )
              else ...[
                Text(
                  digestState.result!.digestText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (digestState.result!.cached) ...[
                  const SizedBox(height: 6),
                  Text(
                    'From cache (same reports; regenerate if someone just posted).',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Read individual reports below—summaries can miss nuance.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextButton(
                  onPressed: () => ref
                      .read(launchReportsDigestProvider(launchId).notifier)
                      .summarize(forceRefresh: true),
                  child: const Text('Regenerate'),
                ),
              ],
            ] else
              FilledButton.tonalIcon(
                onPressed: () => ref
                    .read(launchReportsDigestProvider(launchId).notifier)
                    .summarize(),
                icon: const Icon(Icons.topic_outlined),
                label: const Text('Summarize recent reports'),
              ),
          ],
        ),
      ),
    );
  }
}

String _recentReportsErrorMessage(Object error) {
  final msg = error.toString();
  final buf = StringBuffer('Could not load reports: $msg');
  if (msg.toLowerCase().contains('unauthenticated')) {
    buf.writeln();
    buf.writeln(
      'If this persists: fully stop the app and run again (not hot reload); '
      'confirm `listConditionReports` is deployed with Cloud Run invoker public '
      '(see firebase/DEPLOY.md); on emulators, use a Google Play system image.',
    );
  }
  return buf.toString();
}

String _formatConditionReportTime(BuildContext context, DateTime at) {
  final now = DateTime.now();
  var diff = now.difference(at);
  if (diff.isNegative) {
    diff = Duration.zero;
  }
  if (diff.inMinutes < 1) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }
  final loc = MaterialLocalizations.of(context);
  return loc.formatShortDate(at.toLocal());
}

class _RecentConditionReports extends ConsumerWidget {
  const _RecentConditionReports({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(conditionReportsListProvider(launchId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Recent reports', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Raw messages (newest first). Compare with the digest above.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        reportsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, _) => Text(
            _recentReportsErrorMessage(error),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Text(
                'No paddler reports yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _ConditionReportTile(report: items[i]),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ConditionReportTile extends StatelessWidget {
  const _ConditionReportTile({required this.report});

  final ConditionReportListItem report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final attribution = report.isMine ? 'You' : 'Anonymous paddler';
    final when = _formatConditionReportTime(context, report.createdAt);
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  attribution,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' · $when',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(report.message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet content: owns [TextEditingController] so it is disposed only after
/// the route removes this widget (avoids "used after being disposed" during IME teardown).
class _ConditionReportSheet extends StatefulWidget {
  const _ConditionReportSheet({
    required this.launch,
    required this.conditionsFetchedAt,
    required this.scaffoldMessenger,
    required this.onSuccessFeedback,
  });

  final LaunchPoint launch;
  final DateTime conditionsFetchedAt;
  final ScaffoldMessengerState? scaffoldMessenger;
  final VoidCallback onSuccessFeedback;

  @override
  State<_ConditionReportSheet> createState() => _ConditionReportSheetState();
}

class _ConditionReportSheetState extends State<_ConditionReportSheet> {
  late final TextEditingController _controller;

  /// After a successful submit, the [TextField] is removed before [Navigator.pop].
  /// Otherwise the IME / viewInsets teardown can rebuild [TextField] while the
  /// route disposal has already disposed [TextEditingController].
  bool _submittedClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      widget.scaffoldMessenger?.showSnackBar(
        const SnackBar(content: Text('Add a short message first.')),
      );
      return;
    }
    try {
      await callSubmitConditionReport(
        launchId: widget.launch.id,
        message: text,
        clientConditionsFetchedAt: widget.conditionsFetchedAt
            .toUtc()
            .toIso8601String(),
      );
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _submittedClosing = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onSuccessFeedback();
      });
    } catch (e) {
      widget.scaffoldMessenger?.showSnackBar(
        SnackBar(content: Text('Could not submit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedClosing) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Condition report',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLength: 800,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'What are you seeing on the water?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _submit, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}

class _AiSummaryCard extends ConsumerWidget {
  const _AiSummaryCard({
    required this.launch,
    required this.snapshot,
    required this.goNoGo,
    required this.skillProfile,
  });

  final LaunchPoint launch;
  final ConditionsSnapshot snapshot;
  final GoNoGoResult goNoGo;
  final GoNoGoProfile skillProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(conditionsAiSummaryProvider(launch.id));
    final scheme = Theme.of(context).colorScheme;
    Future<void> runSummary() => ref
        .read(conditionsAiSummaryProvider(launch.id).notifier)
        .summarize(
          launch: launch,
          snapshot: snapshot,
          goNoGo: goNoGo,
          skillProfile: skillProfile,
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  'AI summary',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (summaryState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (summaryState.errorMessage != null) ...[
              Text(
                summaryState.errorMessage!,
                style: TextStyle(color: scheme.error, fontSize: 13),
              ),
              TextButton.icon(
                onPressed: runSummary,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ] else if (summaryState.summary != null) ...[
              Text(
                summaryState.summary!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Verify against the raw data below—AI can misread or omit details.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextButton(
                onPressed: runSummary,
                child: const Text('Regenerate'),
              ),
            ] else
              FilledButton.tonalIcon(
                onPressed: runSummary,
                icon: const Icon(Icons.summarize_outlined),
                label: const Text('Summarize with AI'),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoNoGoCard extends StatelessWidget {
  const _GoNoGoCard({required this.result});

  final GoNoGoResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color onBg, IconData icon) = switch (result.verdict) {
      GoNoGoVerdict.go => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
      GoNoGoVerdict.marginal => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.warning_amber_outlined,
      ),
      GoNoGoVerdict.noGo => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.block_flipped,
      ),
      GoNoGoVerdict.insufficientData => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
        Icons.help_outline,
      ),
    };

    return Card(
      elevation: 0,
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: onBg, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Go / No-go (informational)',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: onBg),
                      ),
                      Text(
                        result.verdict.headline,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: onBg,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (result.reasons.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...result.reasons.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: onBg)),
                      Expanded(
                        child: Text(
                          r.message,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: onBg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (result.verdict == GoNoGoVerdict.go) ...[
              const SizedBox(height: 8),
              Text(
                'No stub warnings from wind, marine text, or flow thresholds for this launch.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: onBg),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Stub rules only—not a substitute for your judgment, skill, or scouting on site.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onBg.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

String _attributionLines(ConditionsSnapshot s) {
  final parts = <String>[
    'Launch list: curated for EddyScout (verify access locally).',
  ];
  if (s.weather != null) {
    parts.add('Weather: ${s.weather!.source.displayName}.');
  }
  if (s.tides != null) {
    parts.add(
      'Tides: NOAA CO-OPS (station ${s.tides!.stationId}, ${s.tides!.datumLabel}).',
    );
  }
  if (s.marine != null) {
    parts.add('Marine: NWS zone ${s.marine!.zoneId}.');
  }
  if (s.riverFlow != null) {
    parts.add('Flow: USGS NWIS (site ${s.riverFlow!.siteId}).');
  }
  return parts.join('\n');
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.snapshot});

  final ConditionsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final w = snapshot.weather;
    final err = snapshot.weatherError;
    if (w == null) {
      return Card(
        child: ListTile(
          title: const Text('Weather'),
          subtitle: Text(err ?? 'Unavailable'),
        ),
      );
    }
    final gust = w.windGustMph != null ? '${w.windGustMph} mph gusts' : null;
    final windParts = <String>[
      if (w.windSpeedMph != null) '${w.windSpeedMph} mph',
      if (w.windDirection != null) 'from ${w.windDirection}',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Weather', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                if (w.source == WeatherDataSource.openMeteo)
                  Text(
                    'Open-Meteo (backup)',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
              ],
            ),
            if (w.source == WeatherDataSource.nws)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'National Weather Service',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (w.temperatureF != null) Text('${w.temperatureF}°F'),
            if (windParts.isNotEmpty) Text('Wind: ${windParts.join(' ')}'),
            if (gust != null) Text(gust),
            if (w.shortForecast != null) Text(w.shortForecast!),
          ],
        ),
      ),
    );
  }
}

class _RiverCard extends StatelessWidget {
  const _RiverCard({required this.snapshot});

  final ConditionsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final r = snapshot.riverFlow;
    final err = snapshot.riverError;
    return Card(
      child: ListTile(
        title: const Text('River flow (USGS)'),
        subtitle: Text(
          r != null
              ? '${_formatCfs(r.cfs)} cfs · ${_formatTime(r.observedAt)}'
              : (err ?? 'No data'),
        ),
      ),
    );
  }
}

String _formatCfs(double v) {
  final n = v.round();
  final abs = n.abs().toString();
  final rev = abs.split('').reversed.toList();
  final buf = StringBuffer();
  for (var i = 0; i < rev.length; i++) {
    if (i > 0 && i % 3 == 0) buf.write(',');
    buf.write(rev[i]);
  }
  final withCommas = buf.toString().split('').reversed.join();
  return n < 0 ? '-$withCommas' : withCommas;
}

String _formatTime(DateTime t) {
  final local = t.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

class _TideCard extends StatelessWidget {
  const _TideCard({required this.snapshot, required this.launch});

  final ConditionsSnapshot snapshot;
  final LaunchPoint launch;

  @override
  Widget build(BuildContext context) {
    final t = snapshot.tides;
    final err = snapshot.tideError;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tides', style: Theme.of(context).textTheme.titleSmall),
            if (launch.tideRelevance == TideRelevance.minor) ...[
              const SizedBox(height: 4),
              Text(
                'Reference only — timing/height differs upriver from the station.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (t?.referenceNote != null) ...[
              const SizedBox(height: 4),
              Text(
                t!.referenceNote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (t == null)
              Text(err ?? 'No tide data')
            else
              ...t.events
                  .take(6)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${e.type} ${_formatHeight(e.heightFt)} · ${_formatTime(e.time)}',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

String _formatHeight(double? ft) {
  if (ft == null) return '—';
  return '${ft.toStringAsFixed(2)} ft';
}

class _MarineCard extends StatelessWidget {
  const _MarineCard({required this.snapshot, required this.zoneId});

  final ConditionsSnapshot snapshot;
  final String zoneId;

  @override
  Widget build(BuildContext context) {
    final m = snapshot.marine;
    final err = snapshot.marineError;
    if (m == null || m.periods.isEmpty) {
      return Card(
        child: ListTile(
          title: Text('Marine (NWS $zoneId)'),
          subtitle: Text(err ?? 'No marine forecast'),
        ),
      );
    }
    return Card(
      child: ExpansionTile(
        title: Text('Marine (NWS $zoneId)'),
        subtitle: Text(
          '${m.periods.length} period(s) · tap to read',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          for (var i = 0; i < m.periods.length; i++)
            ListTile(
              title: Text(
                m.periods[i].name.isEmpty
                    ? 'Period ${i + 1}'
                    : m.periods[i].name,
              ),
              subtitle: Text(m.periods[i].detailedForecast),
            ),
        ],
      ),
    );
  }
}

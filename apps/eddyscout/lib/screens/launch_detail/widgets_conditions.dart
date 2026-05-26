part of '../launch_detail_screen.dart';

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
    final l10n = context.l10n;
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
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.launchDetailAiSummaryTitle,
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
              TextButton.icon(
                onPressed: runSummary,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retryButton),
              ),
            ] else if (summaryState.summary != null) ...[
              Text(
                summaryState.summary!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.launchDetailAiSummaryVerifyHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextButton(
                onPressed: runSummary,
                child: Text(l10n.regenerateButton),
              ),
            ] else
              FilledButton.tonalIcon(
                onPressed: runSummary,
                icon: const Icon(Icons.summarize_outlined),
                label: Text(l10n.summarizeWithAiButton),
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
    final l10n = context.l10n;
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
        padding: const EdgeInsets.all(Spacing.md),
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
                        l10n.launchDetailGoNoGoTitle,
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
                l10n.launchDetailGoNoGoNoWarnings,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: onBg),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              l10n.launchDetailGoNoGoStubDisclaimer,
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

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.snapshot});

  final ConditionsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final w = snapshot.weather;
    final err = snapshot.weatherError;
    if (w == null) {
      return Card(
        child: ListTile(
          title: Text(l10n.launchDetailWeatherTitle),
          subtitle: Text(err ?? l10n.launchDetailUnavailable),
        ),
      );
    }
    final gust = w.windGustMph != null
        ? l10n.launchDetailWindGust(w.windGustMph.toString())
        : null;
    final windParts = <String>[
      if (w.windSpeedMph != null) '${w.windSpeedMph} mph',
      if (w.windDirection != null) 'from ${w.windDirection}',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.launchDetailWeatherTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (w.source == WeatherDataSource.openMeteo)
                  Text(
                    l10n.launchDetailWeatherSourceOpenMeteoBackup,
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
                  l10n.launchDetailWeatherSourceNws,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (w.temperatureF != null)
              Text(l10n.launchDetailTemperatureF(w.temperatureF.toString())),
            if (windParts.isNotEmpty)
              Text(l10n.launchDetailWindLine(windParts.join(' '))),
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
    final l10n = context.l10n;
    final r = snapshot.riverFlow;
    final err = snapshot.riverError;
    return Card(
      child: ListTile(
        title: Text(l10n.launchDetailRiverFlowTitle),
        subtitle: Text(
          r != null
              ? '${_formatCfs(r.cfs)} cfs · ${_formatTime(r.observedAt)}'
              : (err ?? l10n.launchDetailRiverFlowNoData),
        ),
      ),
    );
  }
}

class _TideCard extends StatelessWidget {
  const _TideCard({required this.snapshot, required this.launch});

  final ConditionsSnapshot snapshot;
  final LaunchPoint launch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = snapshot.tides;
    final err = snapshot.tideError;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.launchDetailTidesTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (launch.tideRelevance == TideRelevance.minor) ...[
              const SizedBox(height: 4),
              Text(
                l10n.launchDetailTideMinorReferenceNote,
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
              Text(err ?? l10n.launchDetailNoTideData)
            else
              ...t.events
                  .take(6)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${e.type} ${_formatHeight(e.heightFt)} · '
                        '${_formatTime(e.time)}',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _MarineCard extends StatelessWidget {
  const _MarineCard({required this.snapshot, required this.zoneId});

  final ConditionsSnapshot snapshot;
  final String zoneId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = snapshot.marine;
    final err = snapshot.marineError;
    if (m == null || m.periods.isEmpty) {
      return Card(
        child: ListTile(
          title: Text(l10n.launchDetailMarineTitle(zoneId)),
          subtitle: Text(err ?? l10n.launchDetailNoMarineForecast),
        ),
      );
    }
    return Card(
      child: ExpansionTile(
        title: Text(l10n.launchDetailMarineTitle(zoneId)),
        subtitle: Text(
          l10n.launchDetailMarineExpandHint(m.periods.length),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          for (var i = 0; i < m.periods.length; i++)
            ListTile(
              title: Text(
                m.periods[i].name.isEmpty
                    ? l10n.launchDetailMarinePeriodLabel(i + 1)
                    : m.periods[i].name,
              ),
              subtitle: Text(m.periods[i].detailedForecast),
            ),
        ],
      ),
    );
  }
}

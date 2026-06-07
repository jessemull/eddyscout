part of 'launch_detail_screen.dart';

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
          subtitle: Text(
            err == null
                ? l10n.launchDetailUnavailable
                : _localizedConditionsError(l10n, err),
          ),
        ),
      );
    }
    final gust = w.windGustMph != null
        ? l10n.launchDetailWindGust(w.windGustMph.toString())
        : null;
    final windParts = <String>[
      if (w.windSpeedMph != null) '${w.windSpeedMph} mph',
      if (w.windDirection != null)
        l10n.launchDetailWindFromDirection(w.windDirection!),
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
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  l10n.launchDetailWeatherSourceNws,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: Spacing.sm),
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
              ? l10n.launchDetailRiverFlowSubtitle(
                  _formatCfs(r.cfs),
                  _formatTime(r.observedAt),
                )
              : (err == null
                    ? l10n.launchDetailRiverFlowNoData
                    : _localizedConditionsError(l10n, err)),
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
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.launchDetailTideMinorReferenceNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (t?.referenceNote != null) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                t!.referenceNote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: Spacing.sm),
            if (t == null)
              Text(
                err == null
                    ? l10n.launchDetailNoTideData
                    : _localizedConditionsError(l10n, err),
              )
            else
              ...t.events
                  .take(6)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.xs),
                      child: Text(
                        l10n.launchDetailTideEventLine(
                          e.type,
                          e.heightFt == null
                              ? l10n.commonDash
                              : l10n.launchDetailFeetValue(
                                  e.heightFt!.toStringAsFixed(2),
                                ),
                          _formatTime(e.time),
                        ),
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
          subtitle: Text(
            err == null
                ? l10n.launchDetailNoMarineForecast
                : _localizedConditionsError(l10n, err),
          ),
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

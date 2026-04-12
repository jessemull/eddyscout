import 'package:flutter/material.dart';

import '../conditions/conditions_models.dart';
import '../conditions/conditions_service.dart';
import '../data/launch_models.dart';
import '../decision/go_no_go.dart';

class LaunchDetailScreen extends StatefulWidget {
  const LaunchDetailScreen({super.key, required this.launch});

  final LaunchPoint launch;

  @override
  State<LaunchDetailScreen> createState() => _LaunchDetailScreenState();
}

class _LaunchDetailScreenState extends State<LaunchDetailScreen> {
  late final Future<ConditionsSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = ConditionsService().load(widget.launch);
  }

  @override
  Widget build(BuildContext context) {
    final launch = widget.launch;
    return Scaffold(
      appBar: AppBar(
        title: Text(launch.name),
      ),
      body: FutureBuilder<ConditionsSnapshot>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorBody(message: '${snap.error}');
          }
          final data = snap.data!;
          final goNoGo = GoNoGoEvaluator.evaluate(launch, data);
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
                launch.shortNote,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _GoNoGoCard(result: goNoGo),
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
              Text(
                'Disclaimer',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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

  String _riverLabel(RiverSystem r) => switch (r) {
        RiverSystem.willamette => 'Willamette',
        RiverSystem.columbia => 'Columbia / regional',
        RiverSystem.clackamas => 'Clackamas',
        RiverSystem.slough => 'Slough / confluence',
      };
}

class _GoNoGoCard extends StatelessWidget {
  const _GoNoGoCard({required this.result});

  final GoNoGoResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color onBg, IconData icon) = switch (result.verdict) {
      GoNoGoVerdict.go => (scheme.primaryContainer, scheme.onPrimaryContainer, Icons.check_circle_outline),
      GoNoGoVerdict.marginal => (scheme.tertiaryContainer, scheme.onTertiaryContainer, Icons.warning_amber_outlined),
      GoNoGoVerdict.noGo => (scheme.errorContainer, scheme.onErrorContainer, Icons.block_flipped),
      GoNoGoVerdict.insufficientData => (scheme.surfaceContainerHighest, scheme.onSurface, Icons.help_outline),
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
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: onBg),
                      ),
                      Text(
                        result.verdict.headline,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onBg),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onBg),
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
                Text(
                  'Weather',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
              ...t.events.take(6).map(
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
              title: Text(m.periods[i].name.isEmpty ? 'Period ${i + 1}' : m.periods[i].name),
              subtitle: Text(m.periods[i].detailedForecast),
            ),
        ],
      ),
    );
  }
}

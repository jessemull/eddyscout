import 'package:flutter/material.dart';

/// Shown when `MAPBOX_ACCESS_TOKEN` is missing at compile time.
class MissingMapboxTokenScreen extends StatelessWidget {
  const MissingMapboxTokenScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('EddyScout')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.key_off_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Mapbox token required',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Local dev: create .local.env from the template and run via '
                'the script:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(
                'cp env.example .local.env\n'
                '# edit MAPBOX_ACCESS_TOKEN=pk....\n'
                './scripts/run_android.sh',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 16),
              Text(
                'Or pass at compile time:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(
                'flutter run --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_TOKEN',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 12),
              Text(
                'Never commit .local.env. Use a restricted public token in '
                'Mapbox.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

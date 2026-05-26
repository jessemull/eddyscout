import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

/// Shown when `MAPBOX_ACCESS_TOKEN` is missing at compile time.
class MissingMapboxTokenScreen extends StatelessWidget {
  const MissingMapboxTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mapScreenTitle)),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
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
                const SizedBox(height: Spacing.md),
                Text(
                  l10n.missingMapboxTokenTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.md - Spacing.xs),
                Text(
                  l10n.missingMapboxTokenDevIntro,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Spacing.sm),
                SelectableText(
                  'cp env.example .local.env\n'
                  '# edit MAPBOX_ACCESS_TOKEN=pk....\n'
                  './scripts/run_android.sh',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  l10n.missingMapboxTokenCompileIntro,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: Spacing.sm),
                SelectableText(
                  'flutter run --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_TOKEN',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
                const SizedBox(height: Spacing.md - Spacing.xs),
                Text(
                  l10n.missingMapboxTokenSecurityNote,
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
}

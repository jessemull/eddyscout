@Tags(['golden'])
library;

import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

class _ThemeGallery extends StatelessWidget {
  const _ThemeGallery({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = SemanticColors.of(context);
    return Material(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: Spacing.md),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                FilledButton(
                  onPressed: () {},
                  child: const Text('Filled'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text'),
                ),
                Chip(
                  label: const Text('Chip'),
                  backgroundColor: scheme.secondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                _Swatch(label: 'success', color: semantic.success),
                _Swatch(label: 'warning', color: semantic.warning),
                _Swatch(label: 'error', color: semantic.error),
                _Swatch(label: 'info', color: semantic.info),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 120,
    padding: const EdgeInsets.all(Spacing.sm),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    ),
  );
}

void main() {
  testGoldens('AppTheme renders stable light/dark gallery', (tester) async {
    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1.3)
      ..addScenario(
        'light',
        Theme(
          data: AppTheme.light(),
          child: const _ThemeGallery(label: 'Light theme'),
        ),
      )
      ..addScenario(
        'dark',
        Theme(
          data: AppTheme.dark(),
          child: const _ThemeGallery(label: 'Dark theme'),
        ),
      );

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(900, 520),
    );
    await screenMatchesGolden(tester, 'app_theme_gallery');
  });
}

@Tags(['golden'])
library;

import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('SemanticColors swatches render in light and dark', (
    tester,
  ) async {
    await loadAppFonts();

    Widget gallery(Brightness brightness) => MaterialApp(
      theme: brightness == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark(),
      home: Builder(
        builder: (context) {
          final semantic = SemanticColors.of(context);
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  _Swatch(label: 'success', color: semantic.success),
                  _Swatch(label: 'warning', color: semantic.warning),
                  _Swatch(label: 'error', color: semantic.error),
                  _Swatch(label: 'info', color: semantic.info),
                  _Swatch(label: 'surface', color: semantic.surface),
                  _Swatch(
                    label: 'onSurface',
                    color: semantic.onSurface,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1.2)
      ..addScenario('light', gallery(Brightness.light))
      ..addScenario('dark', gallery(Brightness.dark));

    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: const Size(720, 360),
    );
    await screenMatchesGolden(tester, 'semantic_colors_gallery');
  });
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 100,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    ),
  );
}

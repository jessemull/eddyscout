import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App settings for trip planning preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const EdgeInsets _contentPadding = EdgeInsets.symmetric(
    horizontal: Spacing.md,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final units = ref.watch(effectiveDisplayUnitsProvider);
    final paddleSpeedAsync = ref.watch(paddleSpeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsScreenTitle),
        centerTitle: AppBarMetrics.theme.centerTitle,
        leadingWidth: AppBarMetrics.leadingWidth,
        titleSpacing: AppBarMetrics.titleSpacing,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        children: [
          _SettingsUnitsSection(units: units),
          const SizedBox(height: Spacing.lg),
          paddleSpeedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Text(l10n.launchDetailSkillProfileErrorGeneric),
              ),
            ),
            data: (speedKmh) => _SettingsPaddleSpeedSection(
              speedKmh: speedKmh,
              units: units,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsUnitsSection extends ConsumerWidget {
  const _SettingsUnitsSection({required this.units});

  final DisplayUnitSystem units;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: SettingsScreen._contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsUnitsLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 1),
          Text(
            l10n.settingsUnitsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SegmentedButton<DisplayUnitSystem>(
            key: const Key('settings_display_units_segment'),
            segments: [
              ButtonSegment(
                value: DisplayUnitSystem.metric,
                label: Text(l10n.settingsUnitsMetric),
              ),
              ButtonSegment(
                value: DisplayUnitSystem.imperial,
                label: Text(l10n.settingsUnitsImperial),
              ),
            ],
            selected: {units},
            onSelectionChanged: (selection) => unawaited(
              ref
                  .read(displayUnitPreferenceProvider.notifier)
                  .setUnits(selection.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPaddleSpeedSection extends ConsumerWidget {
  const _SettingsPaddleSpeedSection({
    required this.speedKmh,
    required this.units,
  });

  final double speedKmh;
  final DisplayUnitSystem units;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: SettingsScreen._contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsPaddleSpeedLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 1),
          Text(
            l10n.settingsPaddleSpeedDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            _formatSpeedLabel(l10n, speedKmh, units),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: Spacing.xs),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              padding: EdgeInsets.zero,
            ),
            child: Slider(
              key: const Key('settings_paddle_speed_slider'),
              value: speedKmh,
              min: kMinPaddleSpeedKmh,
              max: kMaxPaddleSpeedKmh,
              divisions: kPaddleSpeedSliderDivisions,
              label: _formatSpeedLabel(l10n, speedKmh, units),
              onChanged: (value) => unawaited(
                ref.read(paddleSpeedProvider.notifier).setSpeed(value),
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('settings_paddle_speed_reset'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              onPressed: speedKmh == kDefaultKayakSpeedKmh
                  ? null
                  : () => unawaited(
                      ref.read(paddleSpeedProvider.notifier).resetToDefault(),
                    ),
              child: Text(l10n.settingsPaddleSpeedReset),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSpeedLabel(
    AppLocalizations l10n,
    double speedKmh,
    DisplayUnitSystem units,
  ) {
    final numeric = formatSpeedNumeric(speedKmh, units);
    return switch (units) {
      DisplayUnitSystem.metric => l10n.settingsPaddleSpeedValue(numeric),
      DisplayUnitSystem.imperial => l10n.settingsPaddleSpeedValueMph(numeric),
    };
  }
}

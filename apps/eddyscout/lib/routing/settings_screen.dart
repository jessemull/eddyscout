import 'dart:async' show unawaited;

import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
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
    final paddleSpeedAsync = ref.watch(paddleSpeedProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsScreenTitle)),
      body: paddleSpeedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Text(l10n.launchDetailSkillProfileErrorGeneric),
          ),
        ),
        data: (speedKmh) => ListView(
          padding: const EdgeInsets.symmetric(vertical: Spacing.md),
          children: [
            Padding(
              padding: _contentPadding,
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
                    l10n.settingsPaddleSpeedValue(_formatSpeed(speedKmh)),
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
                      label: l10n.settingsPaddleSpeedValue(
                        _formatSpeed(speedKmh),
                      ),
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
                              ref
                                  .read(paddleSpeedProvider.notifier)
                                  .resetToDefault(),
                            ),
                      child: Text(l10n.settingsPaddleSpeedReset),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSpeed(double speedKmh) => speedKmh.toStringAsFixed(1);
}

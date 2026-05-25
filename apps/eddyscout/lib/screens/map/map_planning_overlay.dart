import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';

/// Route-planning instructions and put-in / take-out summary over the map.
class MapPlanningOverlay extends StatelessWidget {
  const MapPlanningOverlay({
    required this.putIn,
    required this.takeOut,
    required this.routeLengthKm,
    required this.onClear,
    required this.onDone,
    super.key,
  });

  final LaunchPoint? putIn;
  final LaunchPoint? takeOut;
  final double? routeLengthKm;
  final VoidCallback onClear;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: scheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'River route (beta)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap a launch for put-in, then another for take-out. '
                    'The line follows bundled open hydro data (approximate '
                    'centerline)—not for navigation. '
                    'Several downtown launches sit close together; overlapping '
                    'pins are separate sites. '
                    'Clear removes the route line and picks so you can '
                    'start over. '
                    'Done closes this panel and clears the route.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (putIn != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Put-in: ${putIn!.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (takeOut != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Take-out: ${takeOut!.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (routeLengthKm != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Along river (estimate): '
                      '${routeLengthKm!.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onClear,
                        child: const Text('Clear'),
                      ),
                      TextButton(onPressed: onDone, child: const Text('Done')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

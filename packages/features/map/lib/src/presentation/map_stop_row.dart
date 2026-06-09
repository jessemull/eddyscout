import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';

/// A single stop row in the route planning sheet (Google Maps style).
class MapStopRow extends StatelessWidget {
  const MapStopRow({
    required this.icon,
    required this.label,
    required this.value,
    this.placeholder,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String? placeholder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final display = (value == null || value!.isEmpty)
        ? (placeholder ?? '')
        : value!;
    final isPlaceholder = value == null || value!.isEmpty;
    return Semantics(
      button: onTap != null,
      label: '$label: $display',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      display,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isPlaceholder
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.edit_outlined, size: 18, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

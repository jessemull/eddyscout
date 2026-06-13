import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';

/// Top-aligned sheet header icon with optional compact width (back arrow).
class MapSheetHeaderIconButton extends StatelessWidget {
  const MapSheetHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.alignment,
    required this.onPressed,
    this.compact = false,
    this.contentSized = false,
    super.key,
  });

  static const double iconSize = 24;
  static const double closeSlotWidth = 48;
  static const double compactSlotWidth = iconSize + Spacing.sm + Spacing.xs;

  final IconData icon;
  final String tooltip;
  final Alignment alignment;
  final VoidCallback onPressed;
  final bool compact;
  final bool contentSized;

  @override
  Widget build(BuildContext context) {
    final minWidth = compact ? compactSlotWidth : closeSlotWidth;
    final minHeight = contentSized ? iconSize : closeSlotWidth;
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: minWidth,
                minHeight: minHeight,
              ),
              child: Align(
                alignment: alignment,
                child: Icon(icon, size: iconSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

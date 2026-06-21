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

  static const double iconSize = 20;
  static const double closeSlotWidth = 48;
  static const double compactSlotWidth = iconSize + Spacing.sm + Spacing.xs;

  static const BoxConstraints _closeSlotConstraints = BoxConstraints(
    minWidth: closeSlotWidth,
    minHeight: closeSlotWidth,
  );
  static const BoxConstraints _closeContentSizedConstraints = BoxConstraints(
    minWidth: closeSlotWidth,
    minHeight: iconSize,
  );
  static const BoxConstraints _compactSlotConstraints = BoxConstraints(
    minWidth: compactSlotWidth,
    minHeight: closeSlotWidth,
  );
  static const BoxConstraints _compactContentSizedConstraints = BoxConstraints(
    minWidth: compactSlotWidth,
    minHeight: iconSize,
  );

  final IconData icon;
  final String tooltip;
  final Alignment alignment;
  final VoidCallback onPressed;
  final bool compact;
  final bool contentSized;

  BoxConstraints get _constraints {
    if (compact) {
      return contentSized
          ? _compactContentSizedConstraints
          : _compactSlotConstraints;
    }
    return contentSized ? _closeContentSizedConstraints : _closeSlotConstraints;
  }

  @override
  Widget build(BuildContext context) {
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
              constraints: _constraints,
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

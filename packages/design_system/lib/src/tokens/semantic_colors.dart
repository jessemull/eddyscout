import 'package:flutter/material.dart';

/// Semantic color accessors that resolve from the current [ColorScheme].
///
/// Usage: `SemanticColors.of(context).success`
class SemanticColors {
  const SemanticColors._(this._scheme);

  /// Resolves semantic colors from the nearest [Theme].
  factory SemanticColors.of(BuildContext context) =>
      SemanticColors._(Theme.of(context).colorScheme);

  final ColorScheme _scheme;

  /// Positive / success state color.
  Color get success => _scheme.primary;

  /// Warning / caution state color.
  Color get warning => _scheme.tertiary;

  /// Error / destructive state color.
  Color get error => _scheme.error;

  /// Informational accent color.
  Color get info => _scheme.secondary;

  /// Surface background color.
  Color get surface => _scheme.surface;

  /// Text/icon color on [surface].
  Color get onSurface => _scheme.onSurface;

  /// Alias for [surface] (Material 3 uses surface for backgrounds).
  Color get background => _scheme.surface;

  /// Alias for [onSurface].
  Color get onBackground => _scheme.onSurface;
}

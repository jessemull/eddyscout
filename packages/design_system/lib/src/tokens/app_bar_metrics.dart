import 'package:eddyscout_design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

/// Shared [AppBar] layout metrics for screens with a back button.
///
/// Keeps title text close to the leading affordance and aligned with
/// [Spacing.md] body content below the app bar.
abstract final class AppBarMetrics {
  /// Standard back-button touch target width.
  static const double leadingWidth = 48;

  /// Gap between the back icon and the title on back-navigation app bars.
  static const double titleSpacing = 0;

  /// [AppBarTheme] fragment for opt-in use on back-navigation app bars.
  static const AppBarTheme theme = AppBarTheme(
    centerTitle: false,
    leadingWidth: leadingWidth,
    titleSpacing: titleSpacing,
  );
}

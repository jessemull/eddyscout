import 'package:eddyscout_design_system/src/tokens/app_bar_metrics.dart';
import 'package:flutter/material.dart';

/// Builds the app-wide [ThemeData] from Material 3 seed color.
abstract final class AppTheme {
  static const _seedColor = Color(0xFF0077B6);

  /// Light theme using the EddyScout seed color.
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
    ),
    appBarTheme: AppBarMetrics.theme,
  );

  /// Dark theme using the EddyScout seed color.
  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarMetrics.theme,
  );
}

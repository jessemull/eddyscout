import 'package:flutter/material.dart';

/// Builds the app-wide [ThemeData] from Material 3 seed color.
abstract final class AppTheme {
  static const _seedColor = Color(0xFF0077B6);

  /// Light theme using the EddyScout seed color.
  static ThemeData light() =>
      ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seedColor));

  /// Dark theme using the EddyScout seed color.
  static ThemeData dark() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
  );
}

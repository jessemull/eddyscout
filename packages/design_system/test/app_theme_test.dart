import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppTheme light and dark use Material 3 seed color', () {
    final light = AppTheme.light();
    final dark = AppTheme.dark();
    expect(light.useMaterial3, isTrue);
    expect(dark.colorScheme.brightness, Brightness.dark);
    expect(light.colorScheme.primary, isNotNull);
    expect(light.appBarTheme.centerTitle, isFalse);
    expect(light.appBarTheme.leadingWidth, AppBarMetrics.leadingWidth);
    expect(light.appBarTheme.titleSpacing, AppBarMetrics.titleSpacing);
  });

  test('Spacing tokens are positive', () {
    expect(Spacing.md, greaterThan(Spacing.sm));
    expect(Spacing.xl, greaterThan(Spacing.md));
  });
}

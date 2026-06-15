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
    expect(light.appBarTheme.titleSpacing, isNull);
  });

  test('AppBarMetrics targets back-navigation app bars', () {
    expect(AppBarMetrics.theme.centerTitle, isFalse);
    expect(AppBarMetrics.leadingWidth, 48);
    expect(AppBarMetrics.titleSpacing, 0);
  });

  test('Spacing tokens are positive', () {
    expect(Spacing.md, greaterThan(Spacing.sm));
    expect(Spacing.xl, greaterThan(Spacing.md));
  });
}

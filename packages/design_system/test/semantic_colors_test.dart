import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SemanticColors resolves from ColorScheme', (tester) async {
    late SemanticColors colors;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) {
            colors = SemanticColors.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(colors.success, isA<Color>());
    expect(colors.warning, isA<Color>());
    expect(colors.error, isA<Color>());
    expect(colors.info, isA<Color>());
    expect(colors.surface, isA<Color>());
    expect(colors.onSurface, isA<Color>());
    expect(colors.background, colors.surface);
    expect(colors.onBackground, colors.onSurface);
  });
}

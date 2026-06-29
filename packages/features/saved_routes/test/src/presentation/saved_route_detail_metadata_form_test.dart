import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_metadata_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders metadata fields and dropdowns', (tester) async {
    final nameController = TextEditingController(text: 'Morning paddle');
    final descriptionController = TextEditingController();
    final notesController = TextEditingController();
    final durationController = TextEditingController(text: '90');
    addTearDown(nameController.dispose);
    addTearDown(descriptionController.dispose);
    addTearDown(notesController.dispose);
    addTearDown(durationController.dispose);

    var fieldChanges = 0;
    RouteDifficulty? difficulty;
    RecommendedSkillLevel? skill;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SavedRouteDetailMetadataForm(
            nameController: nameController,
            descriptionController: descriptionController,
            notesController: notesController,
            durationController: durationController,
            difficulty: difficulty,
            skillLevel: skill,
            onFieldChanged: () => fieldChanges++,
            onDifficultyChanged: (value) => difficulty = value,
            onSkillChanged: (value) => skill = value,
          ),
        ),
      ),
    );

    expect(find.text('Morning paddle'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Updated name');
    expect(fieldChanges, greaterThan(0));
  });
}

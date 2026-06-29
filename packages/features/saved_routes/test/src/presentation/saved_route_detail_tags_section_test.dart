import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_tags_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toggles category chips and custom tags', (tester) async {
    final customTagController = TextEditingController();
    addTearDown(customTagController.dispose);

    RouteCategory? toggledCategory;
    var toggledSelected = false;
    String? deletedTag;
    var addTagCalls = 0;

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
          body: SavedRouteDetailTagsSection(
            selectedCategories: const {RouteCategory.scenic},
            customTags: const ['sunrise'],
            customTagController: customTagController,
            onCategorySelected: (category, {required selected}) {
              toggledCategory = category;
              toggledSelected = selected;
            },
            onCustomTagDeleted: (tag) => deletedTag = tag,
            onAddCustomTag: () => addTagCalls++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Training'));
    await tester.pumpAndSettle();
    expect(toggledCategory, RouteCategory.training);
    expect(toggledSelected, isTrue);

    await tester.tap(find.byIcon(Icons.clear).first);
    await tester.pumpAndSettle();
    expect(deletedTag, 'sunrise');

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(addTagCalls, 1);
  });
}

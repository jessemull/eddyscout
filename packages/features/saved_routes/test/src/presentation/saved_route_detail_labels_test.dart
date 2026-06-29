import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('saved route labels resolve enum values', (tester) async {
    late AppLocalizations l10n;

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: SizedBox.shrink(),
      ),
    );
    l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));

    expect(
      savedRouteDifficultyLabel(l10n, RouteDifficulty.moderate),
      l10n.savedRoutesDifficultyModerate,
    );
    expect(
      savedRouteSkillLabel(l10n, RecommendedSkillLevel.intermediate),
      l10n.launchDetailSkillIntermediate,
    );
    expect(
      savedRouteCategoryLabel(l10n, RouteCategory.scenic),
      l10n.savedRoutesCategoryScenic,
    );
  });
}

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/presentation/map_route_failure_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('localizeMapPlannerMessage covers route failure codes', (
    tester,
  ) async {
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

    final cases = <Object, String>{
      const RouteFailure(code: RouteFailureCode.sameLaunch):
          l10n.mapRouteFailureSameLaunch,
      const RouteFailure(code: RouteFailureCode.differentSystem):
          l10n.mapRouteFailureDifferentSystem,
      const RouteFailure(
        code: RouteFailureCode.noBundledLine,
        riverSystemName: 'Willamette',
      ): l10n.mapRouteFailureNoBundledLine(
        'Willamette',
      ),
      const RouteFailure(code: RouteFailureCode.noRiverGeometryLoaded):
          l10n.mapRouteFailureNoData,
      const RouteFailure(code: RouteFailureCode.putInTooFar):
          l10n.mapRouteFailurePutInTooFar,
      const RouteFailure(code: RouteFailureCode.takeOutTooFar):
          l10n.mapRouteFailureTakeOutTooFar,
      const RouteFailure(code: RouteFailureCode.noConnectedPath):
          l10n.mapRouteFailureNoConnectedPath,
      const ParseFailure(): l10n.mapRiverDataReadFailed,
      const AssetLoadFailure(): l10n.mapRiverDataUnavailable,
      'plain text': 'plain text',
      42: l10n.launchDetailUnavailable,
    };

    for (final entry in cases.entries) {
      expect(
        localizeMapPlannerMessage(l10n: l10n, message: entry.key),
        entry.value,
      );
    }
  });
}

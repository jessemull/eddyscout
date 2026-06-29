import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/trips_from_here_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('map launch and reachability labels resolve', (tester) async {
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
      mapLaunchRiverLabel(l10n, RiverSystem.willamette),
      l10n.launchDetailRiverWillamette,
    );
    expect(
      reachabilityBandLabel(l10n, ReachabilityBand.within5Mi),
      l10n.tripsFromHereBand5Mi,
    );
    expect(
      reachabilityBandEmptyMessage(l10n, ReachabilityBand.within10Mi),
      l10n.tripsFromHereBandEmpty10Mi,
    );
    expect(
      reachabilityBandSemanticsLabel(l10n, ReachabilityBand.within20Mi, 3),
      l10n.tripsFromHereBandSemantics(l10n.tripsFromHereBand20Mi, 3),
    );
  });
}

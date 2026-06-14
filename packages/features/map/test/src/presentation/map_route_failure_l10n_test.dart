import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/presentation/gpx_actions_provider.dart';
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
      const RoutePlanningFailure(code: RouteFailureCode.sameLaunch):
          l10n.mapRouteFailureSameLaunch,
      const RoutePlanningFailure(code: RouteFailureCode.differentSystem):
          l10n.mapRouteFailureDifferentSystem,
      const RoutePlanningFailure(
        code: RouteFailureCode.noBundledLine,
        riverSystemName: 'Willamette',
      ): l10n.mapRouteFailureNoBundledLine(
        'Willamette',
      ),
      const RoutePlanningFailure(code: RouteFailureCode.noRiverGeometryLoaded):
          l10n.mapRouteFailureNoData,
      const RoutePlanningFailure(code: RouteFailureCode.putInTooFar):
          l10n.mapRouteFailurePutInTooFar,
      const RoutePlanningFailure(code: RouteFailureCode.takeOutTooFar):
          l10n.mapRouteFailureTakeOutTooFar,
      const RoutePlanningFailure(code: RouteFailureCode.noConnectedPath):
          l10n.mapRouteFailureNoConnectedPath,
      const RoutePlanningFailure(code: RouteFailureCode.disconnectedReach):
          l10n.mapRouteFailureDisconnectedReach,
      const RoutePlanningFailure(
        code: RouteFailureCode.disconnectedReach,
        putInReachId: 'willamette_portland',
        takeOutReachId: 'columbia_gorge',
      ): l10n.mapRouteFailureDisconnectedReachNamed(
        'willamette_portland',
        'columbia_gorge',
      ),
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

  testWidgets('localizeGpxActionFailure covers platform failures', (
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

    expect(
      localizeGpxActionFailure(
        l10n: l10n,
        failure: const GpxCodecActionFailure(
          GpxFailure(code: GpxFailureCode.malformedXml),
        ),
      ),
      l10n.mapGpxFailureMalformed,
    );
    expect(
      localizeGpxActionFailure(
        l10n: l10n,
        failure: const GpxPlatformActionFailure(
          StorageFailure(message: 'gpx_share_failed'),
        ),
      ),
      l10n.mapGpxFailureShare,
    );
    expect(
      localizeGpxActionFailure(
        l10n: l10n,
        failure: const GpxPlatformActionFailure(
          NetworkFailure(message: 'offline'),
        ),
      ),
      l10n.mapGpxFailureGeneric,
    );
  });

  testWidgets('localizeGpxStorageFailure maps storage messages', (
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

    expect(
      localizeGpxStorageFailure(l10n, 'gpx_file_read_failed'),
      l10n.mapGpxFailureFileRead,
    );
  });
}

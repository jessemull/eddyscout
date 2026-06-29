import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_conditions/src/data/firebase/go_no_go_reason_fallback_message.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_l10n.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('localizeGoNoGoReason covers all reason codes', (tester) async {
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

    final cases = <GoNoGoReason, String>{
      const GoNoGoReason(
        code: GoNoGoReasonCode.coldWaterSeason,
        severity: GoNoGoReasonSeverity.info,
      ): l10n.launchDetailGoNoGoReasonColdWaterSeason,
      const GoNoGoReason(
        code: GoNoGoReasonCode.weatherMissing,
        severity: GoNoGoReasonSeverity.info,
      ): l10n.launchDetailGoNoGoReasonWeatherMissing,
      GoNoGoReason(
        code: GoNoGoReasonCode.weatherMissing,
        severity: GoNoGoReasonSeverity.info,
        weatherError: 'weather_nws_error',
      ): l10n.launchDetailGoNoGoReasonWeatherMissingWithError(
        'weather_nws_error',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.windUnknown,
        severity: GoNoGoReasonSeverity.marginal,
      ): l10n.launchDetailGoNoGoReasonWindUnknown,
      const GoNoGoReason(
        code: GoNoGoReasonCode.windHigh,
        severity: GoNoGoReasonSeverity.noGo,
        windMph: 28,
        exposure: 'exposed',
      ): l10n.launchDetailGoNoGoReasonWindHigh(
        28,
        'exposed',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.windElevated,
        severity: GoNoGoReasonSeverity.marginal,
        windMph: 18,
        exposure: 'moderate',
      ): l10n.launchDetailGoNoGoReasonWindElevated(
        18,
        'moderate',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.marineSevere,
        severity: GoNoGoReasonSeverity.noGo,
        pattern: 'storm warning',
      ): l10n.launchDetailGoNoGoReasonMarineSevere(
        'storm warning',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.marineAdvisory,
        severity: GoNoGoReasonSeverity.marginal,
        pattern: 'small craft advisory',
      ): l10n.launchDetailGoNoGoReasonMarineAdvisory(
        'small craft advisory',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.forecastLowLightHours,
        severity: GoNoGoReasonSeverity.info,
      ): l10n.launchDetailGoNoGoReasonForecastLowLight,
      const GoNoGoReason(
        code: GoNoGoReasonCode.flowVeryHigh,
        severity: GoNoGoReasonSeverity.noGo,
        cfs: '40k',
        siteId: '14211720',
        usesLaunchFlowBands: true,
      ): l10n.launchDetailGoNoGoReasonFlowVeryHigh(
        '40k',
        '14211720',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.flowVeryHigh,
        severity: GoNoGoReasonSeverity.noGo,
        cfs: '40k',
        siteId: '14211720',
        usesLaunchFlowBands: false,
      ): l10n.launchDetailGoNoGoReasonFlowVeryHigh(
        '40k',
        '14211720',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.flowHigh,
        severity: GoNoGoReasonSeverity.marginal,
        cfs: '6000',
        siteId: 'x',
        usesLaunchFlowBands: true,
      ): l10n.launchDetailGoNoGoReasonFlowApproximate(
        '6000',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.flowHigh,
        severity: GoNoGoReasonSeverity.marginal,
        cfs: '6000',
        siteId: 'x',
        usesLaunchFlowBands: false,
      ): l10n.launchDetailGoNoGoReasonFlowApproximate(
        '6000',
      ),
      const GoNoGoReason(
        code: GoNoGoReasonCode.flowLow,
        severity: GoNoGoReasonSeverity.marginal,
        cfs: '200',
        siteId: 'x',
        usesLaunchFlowBands: true,
      ): l10n.launchDetailGoNoGoReasonFlowApproximate(
        '200',
      ),
    };

    for (final entry in cases.entries) {
      expect(localizeGoNoGoReason(l10n, entry.key), entry.value);
      expect(entry.value, isNotEmpty);
    }
  });

  testWidgets('localizeGoNoGoVerdict covers all verdicts', (tester) async {
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
      localizeGoNoGoVerdict(l10n, GoNoGoVerdict.go),
      l10n.launchDetailGoNoGoVerdictGo,
    );
    expect(
      localizeGoNoGoVerdict(l10n, GoNoGoVerdict.marginal),
      l10n.launchDetailGoNoGoVerdictMarginal,
    );
    expect(
      localizeGoNoGoVerdict(l10n, GoNoGoVerdict.noGo),
      l10n.launchDetailGoNoGoVerdictNoGo,
    );
    expect(
      localizeGoNoGoVerdict(l10n, GoNoGoVerdict.insufficientData),
      l10n.launchDetailGoNoGoVerdictInsufficientData,
    );
  });

  test('GoNoGoReasonCode serializes to snake_case wire values', () {
    const reason = GoNoGoReason(
      code: GoNoGoReasonCode.windHigh,
      severity: GoNoGoReasonSeverity.noGo,
      windMph: 25,
      exposure: 'exposed',
    );
    final json = reason.toJson();
    expect(json['code'], 'wind_high');
    expect(json.containsKey('message'), isFalse);

    final roundTrip = GoNoGoReason.fromJson(json);
    expect(roundTrip.code, GoNoGoReasonCode.windHigh);
    expect(roundTrip.windMph, 25);
  });

  test('goNoGoReasonFallbackMessage generates English for Firebase', () {
    const reason = GoNoGoReason(
      code: GoNoGoReasonCode.windHigh,
      severity: GoNoGoReasonSeverity.noGo,
      windMph: 28,
      exposure: 'exposed',
    );
    final message = goNoGoReasonFallbackMessage(reason);
    expect(message, contains('28'));
    expect(message, contains('exposed'));
  });

  testWidgets('localizeRouteGoNoGoRollupErrorMessage returns generic copy', (
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
      localizeRouteGoNoGoRollupErrorMessage(
        l10n,
        const NetworkFailure(message: 'offline'),
      ),
      l10n.routeGoNoGoErrorGeneric,
    );
  });

  testWidgets(
    'localizeRouteGoNoGoFailureMessage localizes partial-stop errors',
    (
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
        localizeRouteGoNoGoFailureMessage(
          l10n,
          const NotFoundFailure(message: 'missing_launch'),
        ),
        l10n.routeGoNoGoLaunchNotFound,
      );
      expect(
        localizeRouteGoNoGoFailureMessage(
          l10n,
          const NetworkFailure(message: 'network down'),
        ),
        l10n.routeGoNoGoStopConditionsUnavailable,
      );
      expect(
        localizeRouteGoNoGoFailureMessage(
          l10n,
          const NetworkFailure(message: 'network down'),
        ),
        isNot(contains('network down')),
      );
    },
  );

  testWidgets('goNoGoReasonFallbackMessage matches ARB for windHigh', (
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

    const reason = GoNoGoReason(
      code: GoNoGoReasonCode.windHigh,
      severity: GoNoGoReasonSeverity.noGo,
      windMph: 28,
      exposure: 'moderate',
    );
    expect(
      goNoGoReasonFallbackMessage(reason),
      localizeGoNoGoReason(l10n, reason),
    );
  });

  test('goNoGoReasonFallbackMessage covers remaining reason codes', () {
    const cases = <GoNoGoReason>[
      GoNoGoReason(
        code: GoNoGoReasonCode.coldWaterSeason,
        severity: GoNoGoReasonSeverity.info,
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.weatherMissing,
        severity: GoNoGoReasonSeverity.info,
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.weatherMissing,
        severity: GoNoGoReasonSeverity.info,
        weatherError: 'timeout',
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.windUnknown,
        severity: GoNoGoReasonSeverity.marginal,
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.windElevated,
        severity: GoNoGoReasonSeverity.marginal,
        windMph: 18,
        exposure: 'exposed',
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.marineSevere,
        severity: GoNoGoReasonSeverity.noGo,
        pattern: 'gale warning',
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.marineAdvisory,
        severity: GoNoGoReasonSeverity.marginal,
        pattern: 'small craft advisory',
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.forecastLowLightHours,
        severity: GoNoGoReasonSeverity.info,
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.flowVeryHigh,
        severity: GoNoGoReasonSeverity.noGo,
        cfs: '12000',
        siteId: '14211720',
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.flowHigh,
        severity: GoNoGoReasonSeverity.marginal,
        cfs: '8000',
      ),
      GoNoGoReason(
        code: GoNoGoReasonCode.flowLow,
        severity: GoNoGoReasonSeverity.marginal,
        cfs: '1200',
      ),
    ];

    for (final reason in cases) {
      expect(goNoGoReasonFallbackMessage(reason), isNotEmpty);
    }
  });
}

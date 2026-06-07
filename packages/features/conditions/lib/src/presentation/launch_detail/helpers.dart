part of 'launch_detail_screen.dart';

String? _launchDetailFirebaseHint(
  AppLocalizations l10n,
  FirebaseBootstrapHintKind kind,
) => switch (kind) {
  FirebaseBootstrapHintKind.missingNativeConfig =>
    l10n.launchDetailFirebaseHintMissingNativeConfig,
  FirebaseBootstrapHintKind.anonymousAuthDisabled =>
    l10n.launchDetailFirebaseHintAnonymousAuth,
  FirebaseBootstrapHintKind.none => null,
};

String _launchDetailFirebaseUnavailableMessage(AppLocalizations l10n) {
  if (FirebaseBootstrap.lastError != null) {
    final hint = _launchDetailFirebaseHint(l10n, FirebaseBootstrap.hintKind);
    final buf = StringBuffer()
      ..writeln(l10n.launchDetailFirebaseUnavailableIntro)
      ..writeln()
      ..writeln(
        l10n.launchDetailFirebaseErrorLabel(FirebaseBootstrap.lastError!),
      )
      ..writeln();
    if (hint != null) {
      buf
        ..writeln(hint)
        ..writeln();
    }
    return buf.toString();
  }
  return l10n.launchDetailFirebaseUnavailableBody;
}

String _launchDetailFailureMessage(Object error) =>
    error is AppFailure ? error.message : error.toString();

String _launchDetailConditionsErrorMessage(
  AppLocalizations l10n,
  Object error,
) {
  if (error is AppFailure) {
    return _launchDetailFailureMessage(error);
  }
  final msg = _launchDetailFailureMessage(error).toLowerCase();
  if (msg.contains('socket') || msg.contains('network')) {
    return l10n.launchDetailConditionsErrorNetwork;
  }
  return l10n.launchDetailConditionsErrorGeneric;
}

String _launchDetailRiverLabel(AppLocalizations l10n, RiverSystem r) =>
    switch (r) {
      RiverSystem.willamette => l10n.launchDetailRiverWillamette,
      RiverSystem.columbia => l10n.launchDetailRiverColumbia,
      RiverSystem.clackamas => l10n.launchDetailRiverClackamas,
      RiverSystem.slough => l10n.launchDetailRiverSlough,
    };

Future<void> _openLaunchDetailConditionReportSheet(
  WidgetRef ref,
  BuildContext context,
  LaunchPoint launch,
  DateTime conditionsFetchedAt,
) async {
  final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetCtx) => _ConditionReportSheet(
      launch: launch,
      conditionsFetchedAt: conditionsFetchedAt,
      scaffoldMessenger: scaffoldMessenger,
      onSuccessFeedback: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          scaffoldMessenger?.showSnackBar(
            SnackBar(content: Text(sheetCtx.l10n.launchDetailReportThanks)),
          );
        });
      },
    ),
  );
}

String _recentReportsErrorMessage(AppLocalizations l10n, Object error) {
  final msg = _launchDetailFailureMessage(error);
  final buf = StringBuffer(l10n.launchDetailReportsLoadError(msg));
  if (msg.toLowerCase().contains('unauthenticated')) {
    buf
      ..writeln()
      ..writeln(l10n.launchDetailReportsUnauthHint);
  }
  return buf.toString();
}

String _formatConditionReportTime(
  BuildContext context,
  AppLocalizations l10n,
  DateTime at,
) {
  final now = DateTime.now();
  var diff = now.difference(at);
  if (diff.isNegative) {
    diff = Duration.zero;
  }
  if (diff.inMinutes < 1) {
    return l10n.launchDetailTimeJustNow;
  }
  if (diff.inMinutes < 60) {
    return l10n.launchDetailTimeMinutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    return l10n.launchDetailTimeHoursAgo(diff.inHours);
  }
  if (diff.inDays < 7) {
    return l10n.launchDetailTimeDaysAgo(diff.inDays);
  }
  final loc = MaterialLocalizations.of(context);
  return loc.formatShortDate(at.toLocal());
}

String _launchDetailAttributionLines(
  AppLocalizations l10n,
  ConditionsSnapshot s,
) {
  final parts = <String>[l10n.launchDetailAttributionLaunchList];
  if (s.weather != null) {
    final weatherSource = switch (s.weather!.source) {
      WeatherDataSource.nws => l10n.launchDetailWeatherSourceNws,
      WeatherDataSource.openMeteo => l10n.launchDetailWeatherSourceOpenMeteo,
    };
    parts.add(
      l10n.launchDetailAttributionWeather(weatherSource),
    );
  }
  if (s.tides != null) {
    parts.add(
      l10n.launchDetailAttributionTides(
        s.tides!.stationId,
        s.tides!.datumLabel,
      ),
    );
  }
  if (s.marine != null) {
    parts.add(l10n.launchDetailAttributionMarine(s.marine!.zoneId));
  }
  if (s.riverFlow != null) {
    parts.add(l10n.launchDetailAttributionFlow(s.riverFlow!.siteId));
  }
  return parts.join('\n');
}

String _formatCfs(double v) {
  final n = v.round();
  final abs = n.abs().toString();
  final rev = abs.split('').reversed.toList();
  final buf = StringBuffer();
  for (var i = 0; i < rev.length; i++) {
    if (i > 0 && i % 3 == 0) buf.write(',');
    buf.write(rev[i]);
  }
  final withCommas = buf.toString().split('').reversed.join();
  return n < 0 ? '-$withCommas' : withCommas;
}

String _formatTime(DateTime t) {
  final local = t.toLocal();
  final y = local.year;
  final mo = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final mi = local.minute.toString().padLeft(2, '0');
  return '$y-$mo-$d $h:$mi';
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
  );
}

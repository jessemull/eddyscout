part of '../launch_detail_screen.dart';

String launchDetailFirebaseUnavailableMessage() {
  if (FirebaseBootstrap.lastError != null) {
    final hint = FirebaseBootstrap.hintForLastError();
    final buf = StringBuffer()
      ..writeln(
        'Firebase did not start, so AI summary and reports are unavailable.',
      )
      ..writeln()
      ..writeln('Error: ${FirebaseBootstrap.lastError}')
      ..writeln();
    if (hint != null) {
      buf
        ..writeln(hint)
        ..writeln();
    }
    buf.writeln(
      'Otherwise check: correct `google-services.json` for package '
      '`com.eddyscout.eddyscout`, network, then full app restart '
      '(not hot reload).',
    );
    return buf.toString();
  }
  return 'Firebase features need a successful app init and anonymous sign-in. '
      'Add `google-services.json`, enable Anonymous auth, deploy functions, '
      'and rebuild with `USE_FIREBASE=true` in `.local.env` (`make run`).';
}

String launchDetailRiverLabel(RiverSystem r) => switch (r) {
  RiverSystem.willamette => 'Willamette',
  RiverSystem.columbia => 'Columbia / regional',
  RiverSystem.clackamas => 'Clackamas',
  RiverSystem.slough => 'Slough / confluence',
};

Future<void> openLaunchDetailConditionReportSheet(
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
        ref.read(conditionReportsRefreshTokenProvider.notifier).state++;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          scaffoldMessenger?.showSnackBar(
            const SnackBar(content: Text('Thanks—report submitted.')),
          );
        });
      },
    ),
  );
}

String _recentReportsErrorMessage(Object error) {
  final msg = error.toString();
  final buf = StringBuffer('Could not load reports: $msg');
  if (msg.toLowerCase().contains('unauthenticated')) {
    buf
      ..writeln()
      ..writeln(
        'If this persists: fully stop the app and run again (not hot reload); '
        'confirm `listConditionReports` is deployed with Cloud Run invoker '
        'public (see firebase/DEPLOY.md); on emulators, use a Google Play '
        'system image.',
      );
  }
  return buf.toString();
}

String _formatConditionReportTime(BuildContext context, DateTime at) {
  final now = DateTime.now();
  var diff = now.difference(at);
  if (diff.isNegative) {
    diff = Duration.zero;
  }
  if (diff.inMinutes < 1) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }
  final loc = MaterialLocalizations.of(context);
  return loc.formatShortDate(at.toLocal());
}

String launchDetailAttributionLines(ConditionsSnapshot s) {
  final parts = <String>[
    'Launch list: curated for EddyScout (verify access locally).',
  ];
  if (s.weather != null) {
    parts.add('Weather: ${s.weather!.source.displayName}.');
  }
  if (s.tides != null) {
    parts.add(
      'Tides: NOAA CO-OPS (station ${s.tides!.stationId}, '
      '${s.tides!.datumLabel}).',
    );
  }
  if (s.marine != null) {
    parts.add('Marine: NWS zone ${s.marine!.zoneId}.');
  }
  if (s.riverFlow != null) {
    parts.add('Flow: USGS NWIS (site ${s.riverFlow!.siteId}).');
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

String _formatHeight(double? ft) {
  if (ft == null) return '—';
  return '${ft.toStringAsFixed(2)} ft';
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
  );
}

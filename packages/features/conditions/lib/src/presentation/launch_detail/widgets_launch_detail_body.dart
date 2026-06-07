part of 'launch_detail_screen.dart';

class _LaunchDetailBody extends ConsumerWidget {
  const _LaunchDetailBody({
    required this.launch,
    required this.skillProfile,
    required this.data,
  });

  final LaunchPoint launch;
  final GoNoGoProfile skillProfile;
  final ConditionsSnapshot data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goNoGo = ref.watch(
      launchGoNoGoResultProvider((
        launch: launch,
        snapshot: data,
        profile: skillProfile,
      )),
    );
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            Semantics(
              label: l10n.launchDetailWindExposureSemantics(
                launch.windExposure.label,
              ),
              child: Chip(
                label: Text(launch.windExposure.label),
                visualDensity: VisualDensity.compact,
              ),
            ),
            Semantics(
              label: l10n.launchDetailRiverSemantics(
                _launchDetailRiverLabel(l10n, launch.riverSystem),
              ),
              child: Chip(
                label: Text(
                  _launchDetailRiverLabel(l10n, launch.riverSystem),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
            Semantics(
              label: l10n.launchDetailTideRelevanceSemantics(
                launch.tideRelevance.shortLabel,
              ),
              child: Chip(
                label: Text(launch.tideRelevance.shortLabel),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md - Spacing.xs),
        Text(
          l10n.launchDetailSkillSectionTitle,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: Spacing.sm),
        Semantics(
          label: l10n.launchDetailSkillSectionTitle,
          child: SegmentedButton<GoNoGoProfile>(
            segments: [
              ButtonSegment(
                value: GoNoGoProfile.beginner,
                label: Text(l10n.launchDetailSkillBeginner),
              ),
              ButtonSegment(
                value: GoNoGoProfile.intermediate,
                label: Text(l10n.launchDetailSkillIntermediate),
              ),
              ButtonSegment(
                value: GoNoGoProfile.advanced,
                label: Text(l10n.launchDetailSkillAdvanced),
              ),
            ],
            selected: {skillProfile},
            onSelectionChanged: (next) {
              unawaited(
                ref
                    .read(goNoGoProfileProvider.notifier)
                    .setProfile(next.single),
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.md - Spacing.xs),
        Text(
          launch.shortNote,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: Spacing.md),
        _GoNoGoCard(result: goNoGo),
        if (firebaseCallablesAvailable) ...[
          const SizedBox(height: Spacing.md),
          _AiSummaryCard(
            launch: launch,
            snapshot: data,
            goNoGo: goNoGo,
            skillProfile: skillProfile,
          ),
          const SizedBox(height: Spacing.md),
          _LaunchReportsDigestCard(launchId: launch.id),
          const SizedBox(height: Spacing.md),
          _RecentConditionReports(launchId: launch.id),
          const SizedBox(height: Spacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.feedback_outlined),
            title: Text(l10n.launchDetailReportConditionsTitle),
            subtitle: Text(l10n.launchDetailReportConditionsSubtitle),
            onTap: () => _openLaunchDetailConditionReportSheet(
              ref,
              context,
              launch,
              data.fetchedAt,
            ),
          ),
        ] else if (kUseFirebase && !kIsWeb) ...[
          const SizedBox(height: Spacing.sm + Spacing.xs),
          Text(
            _launchDetailFirebaseUnavailableMessage(l10n),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: FirebaseBootstrap.lastError != null
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: Spacing.lg),
        Text(
          l10n.launchDetailConditionsSection,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: Spacing.sm),
        _WeatherCard(snapshot: data),
        if (data.riverFlow != null || data.riverError != null) ...[
          const SizedBox(height: Spacing.sm + Spacing.xs),
          _RiverCard(snapshot: data),
        ],
        if (launch.tideRelevance != TideRelevance.none) ...[
          const SizedBox(height: Spacing.sm + Spacing.xs),
          _TideCard(snapshot: data, launch: launch),
        ],
        if (launch.marineZoneId case final zoneId?) ...[
          const SizedBox(height: Spacing.sm + Spacing.xs),
          _MarineCard(snapshot: data, zoneId: zoneId),
        ],
        const SizedBox(height: Spacing.lg),
        Text(
          l10n.launchDetailDisclaimerTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.launchDetailDisclaimerBody,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          l10n.launchDetailDataSourcesTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          _launchDetailAttributionLines(l10n, data),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

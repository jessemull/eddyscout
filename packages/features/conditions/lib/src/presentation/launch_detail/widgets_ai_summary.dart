part of 'launch_detail_screen.dart';

class _AiSummaryCard extends ConsumerWidget {
  const _AiSummaryCard({
    required this.launch,
    required this.snapshot,
    required this.goNoGo,
    required this.skillProfile,
  });

  final LaunchPoint launch;
  final ConditionsSnapshot snapshot;
  final GoNoGoResult goNoGo;
  final GoNoGoProfile skillProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(conditionsAiSummaryProvider(launch.id));
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    Future<void> runSummary() => ref
        .read(conditionsAiSummaryProvider(launch.id).notifier)
        .summarize(
          launch: launch,
          snapshot: snapshot,
          goNoGo: goNoGo,
          skillProfile: skillProfile,
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: scheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(
                  l10n.launchDetailAiSummaryTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            if (summaryState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Spacing.sm + Spacing.xs,
                ),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (summaryState.errorMessage != null) ...[
              Text(
                summaryState.errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
              TextButton.icon(
                onPressed: runSummary,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retryButton),
              ),
            ] else if (summaryState.summary != null) ...[
              Text(
                summaryState.summary!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.launchDetailAiSummaryVerifyHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextButton(
                onPressed: runSummary,
                child: Text(l10n.regenerateButton),
              ),
            ] else
              FilledButton.tonalIcon(
                onPressed: runSummary,
                icon: const Icon(Icons.summarize_outlined),
                label: Text(l10n.summarizeWithAiButton),
              ),
          ],
        ),
      ),
    );
  }
}

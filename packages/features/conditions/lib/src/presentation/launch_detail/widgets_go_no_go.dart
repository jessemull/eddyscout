part of 'launch_detail_screen.dart';

class _GoNoGoCard extends StatelessWidget {
  const _GoNoGoCard({required this.result});

  final GoNoGoResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color onBg, IconData icon) = switch (result.verdict) {
      GoNoGoVerdict.go => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
      GoNoGoVerdict.marginal => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.warning_amber_outlined,
      ),
      GoNoGoVerdict.noGo => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.block_flipped,
      ),
      GoNoGoVerdict.insufficientData => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
        Icons.help_outline,
      ),
    };

    return Card(
      elevation: 0,
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: onBg, size: 28),
                const SizedBox(width: Spacing.sm + Spacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.launchDetailGoNoGoTitle,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: onBg),
                      ),
                      Text(
                        result.verdict.headline,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: onBg,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (result.reasons.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm + Spacing.xs),
              ...result.reasons.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.commonBullet,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: onBg),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          r.message,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: onBg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (result.verdict == GoNoGoVerdict.go) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.launchDetailGoNoGoNoWarnings,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: onBg),
              ),
            ],
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.launchDetailGoNoGoStubDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onBg.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

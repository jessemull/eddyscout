import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/route_go_no_go.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_l10n.dart';
import 'package:eddyscout_conditions/src/presentation/route_go_no_go_rollup_provider.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Route-level go/no-go rollup for map preview and saved route detail.
class RouteGoNoGoSummarySection extends ConsumerWidget {
  /// Creates a section that loads rollup for [launchIdsInOrder].
  const RouteGoNoGoSummarySection({
    required this.launchIdsInOrder,
    super.key,
  });

  /// Ordered catalog launch ids along the route.
  final RouteGoNoGoWaypointsKey launchIdsInOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (launchIdsInOrder.length < 2) {
      return const SizedBox.shrink();
    }

    final rollupAsync = ref.watch(
      routeGoNoGoRollupProvider(launchIdsInOrder),
    );

    return rollupAsync.when(
      loading: () => Semantics(
        label: context.l10n.routeGoNoGoLoading,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, _) => _RouteGoNoGoErrorCard(
        message: error is AppFailure
            ? error.message
            : context.l10n.routeGoNoGoErrorGeneric,
        onRetry: () => ref.invalidate(
          routeGoNoGoRollupProvider(launchIdsInOrder),
        ),
      ),
      data: (result) => _RouteGoNoGoDataCard(result: result),
    );
  }
}

class _RouteGoNoGoErrorCard extends StatelessWidget {
  const _RouteGoNoGoErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.routeGoNoGoTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteGoNoGoDataCard extends StatelessWidget {
  const _RouteGoNoGoDataCard({required this.result});

  final RouteGoNoGoResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color onBg, IconData icon) = _verdictStyle(
      scheme,
      result.verdict,
    );
    final stopName = result.triggeringWaypoint?.launchName;
    final semanticsLabel = stopName == null
        ? l10n.routeGoNoGoSemanticsVerdictOnly(
            localizeGoNoGoVerdict(l10n, result.verdict),
          )
        : l10n.routeGoNoGoSemanticsVerdictWithStop(
            localizeGoNoGoVerdict(l10n, result.verdict),
            stopName,
          );

    return Semantics(
      label: semanticsLabel,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        color: bg,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: onBg, size: 24),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.routeGoNoGoTitle,
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(color: onBg),
                        ),
                        Text(
                          localizeGoNoGoVerdict(l10n, result.verdict),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: onBg,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (stopName != null) ...[
                          const SizedBox(height: Spacing.xxs),
                          Text(
                            l10n.routeGoNoGoTriggeringStop(stopName),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: onBg),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (result.triggeringReasons.isNotEmpty) ...[
                const SizedBox(height: Spacing.sm),
                ...result.triggeringReasons.map(
                  (reason) => Semantics(
                    label: localizeGoNoGoReason(l10n, reason),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.xxs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.commonBullet,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: onBg),
                          ),
                          const SizedBox(width: Spacing.xxs),
                          Expanded(
                            child: Text(
                              localizeGoNoGoReason(l10n, reason),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: onBg),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (result.verdict == GoNoGoVerdict.go) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.launchDetailGoNoGoNoWarnings,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: onBg),
                ),
              ],
              if (result.waypointResults.length > 1) ...[
                const SizedBox(height: Spacing.xs),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: onBg.withValues(alpha: 0.2),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    iconColor: onBg,
                    collapsedIconColor: onBg,
                    title: Text(
                      l10n.routeGoNoGoAllStopsTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: onBg),
                    ),
                    children: [
                      for (final stop in result.waypointResults)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.routeGoNoGoStopLine(
                                  stop.orderIndex + 1,
                                  stop.launchName,
                                  localizeGoNoGoVerdict(
                                    l10n,
                                    stop.result.verdict,
                                  ),
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: onBg,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              for (final reason in stop.result.reasons.where(
                                (r) => r.severity != GoNoGoReasonSeverity.info,
                              ))
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: Spacing.sm,
                                    top: Spacing.xxs,
                                  ),
                                  child: Text(
                                    localizeGoNoGoReason(l10n, reason),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: onBg),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (result.waypointFailures.isNotEmpty) ...[
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.routeGoNoGoPartialFailuresTitle,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: onBg,
                  ),
                ),
                for (final failure in result.waypointFailures)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.xxs),
                    child: Text(
                      l10n.routeGoNoGoStopFailureLine(
                        failure.orderIndex + 1,
                        failure.launchName,
                        failure.failure.message,
                      ),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: onBg),
                    ),
                  ),
              ],
              const SizedBox(height: Spacing.xxs),
              Text(
                l10n.routeGoNoGoRouteDisclaimer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onBg.withValues(alpha: 0.85),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

(Color bg, Color onBg, IconData icon) _verdictStyle(
  ColorScheme scheme,
  GoNoGoVerdict verdict,
) => switch (verdict) {
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

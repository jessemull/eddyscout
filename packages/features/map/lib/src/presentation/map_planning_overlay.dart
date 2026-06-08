import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/presentation/map_planning_provider.dart';
import 'package:flutter/material.dart';

/// Route-planning instructions and put-in / take-out summary over the map.
class MapPlanningOverlay extends StatelessWidget {
  const MapPlanningOverlay({
    required this.phase,
    required this.putIn,
    required this.takeOut,
    required this.routeLengthKm,
    required this.riverSystem,
    required this.lastFailureCode,
    required this.onClear,
    required this.onDone,
    this.lastFailurePutInReachId,
    this.lastFailureTakeOutReachId,
    super.key,
  });

  final RoutePlanningPhase phase;
  final LaunchPoint? putIn;
  final LaunchPoint? takeOut;
  final double? routeLengthKm;
  final RiverSystem? riverSystem;
  final RouteFailureCode? lastFailureCode;
  final String? lastFailurePutInReachId;
  final String? lastFailureTakeOutReachId;
  final VoidCallback onClear;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md - Spacing.xs,
            Spacing.sm,
            Spacing.md - Spacing.xs,
            0,
          ),
          child: Semantics(
            container: true,
            label: l10n.mapPlanningSemanticsLabel,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: scheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md - Spacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.mapPlanningTitleBeta,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: Spacing.sm - 2),
                    Text(
                      _stepHint(l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (phase == RoutePlanningPhase.computingRoute) ...[
                      const SizedBox(height: Spacing.sm),
                      Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text(
                              l10n.mapPlanningComputingRoute,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (putIn != null) ...[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        l10n.mapPlanningPutInName(putIn!.name),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (takeOut != null) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        l10n.mapPlanningTakeOutName(takeOut!.name),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (phase == RoutePlanningPhase.routeReady &&
                        riverSystem != null) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        l10n.mapPlanningRiverSystem(riverSystem!.name),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (routeLengthKm != null) ...[
                      const SizedBox(height: Spacing.sm - 2),
                      Text(
                        l10n.mapPlanningRouteLengthKm(
                          routeLengthKm!.toStringAsFixed(1),
                        ),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                    if (phase == RoutePlanningPhase.routeError &&
                        lastFailureCode != null) ...[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        _inlineFailureMessage(
                          l10n,
                          lastFailureCode!,
                          putInReachId: lastFailurePutInReachId,
                          takeOutReachId: lastFailureTakeOutReachId,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.sm),
                    Wrap(
                      spacing: Spacing.sm,
                      runSpacing: Spacing.xs,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onClear,
                          child: Text(l10n.mapPlanningClearLabel),
                        ),
                        TextButton(
                          onPressed: onDone,
                          child: Text(l10n.mapPlanningDoneLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _stepHint(AppLocalizations l10n) => switch (phase) {
    RoutePlanningPhase.pickPutIn => l10n.mapPlanningStepPickPutIn,
    RoutePlanningPhase.pickTakeOut => l10n.mapPlanningStepPickTakeOut,
    RoutePlanningPhase.computingRoute => l10n.mapPlanningInstructions,
    RoutePlanningPhase.routeReady => l10n.mapPlanningInstructions,
    RoutePlanningPhase.routeError => l10n.mapPlanningInstructions,
  };

  String _inlineFailureMessage(
    AppLocalizations l10n,
    RouteFailureCode code, {
    String? putInReachId,
    String? takeOutReachId,
  }) => switch (code) {
    RouteFailureCode.sameLaunch => l10n.mapRouteFailureSameLaunch,
    RouteFailureCode.differentSystem => l10n.mapRouteFailureDifferentSystem,
    RouteFailureCode.noBundledLine => l10n.mapRouteFailureNoData,
    RouteFailureCode.noRiverGeometryLoaded => l10n.mapRouteFailureNoData,
    RouteFailureCode.putInTooFar => l10n.mapRouteFailurePutInTooFar,
    RouteFailureCode.takeOutTooFar => l10n.mapRouteFailureTakeOutTooFar,
    RouteFailureCode.noConnectedPath => l10n.mapRouteFailureNoConnectedPath,
    RouteFailureCode.disconnectedReach =>
      putInReachId != null &&
              takeOutReachId != null &&
              putInReachId.isNotEmpty &&
              takeOutReachId.isNotEmpty
          ? l10n.mapRouteFailureDisconnectedReachNamed(
              putInReachId,
              takeOutReachId,
            )
          : l10n.mapRouteFailureDisconnectedReach,
  };
}

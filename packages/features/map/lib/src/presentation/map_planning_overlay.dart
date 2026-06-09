import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/presentation/map_planning_provider.dart';
import 'package:eddyscout_map/src/presentation/map_route_failure_l10n.dart';
import 'package:flutter/material.dart';

/// Route-planning instructions and waypoint summary over the map.
class MapPlanningOverlay extends StatelessWidget {
  const MapPlanningOverlay({
    required this.phase,
    required this.waypoints,
    required this.routeLengthKm,
    required this.canSave,
    required this.canExportGpx,
    required this.gpxBusy,
    required this.onClear,
    required this.onDone,
    required this.onSave,
    required this.onExportGpx,
    required this.onImportGpx,
    this.lastFailureCode,
    this.lastFailureRiverSystemName,
    this.lastFailurePutInReachId,
    this.lastFailureTakeOutReachId,
    this.routeReachId,
    super.key,
  });

  final RoutePlanningPhase phase;
  final List<LaunchPoint> waypoints;
  final double? routeLengthKm;
  final bool canSave;
  final bool canExportGpx;
  final bool gpxBusy;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final VoidCallback onSave;
  final VoidCallback onExportGpx;
  final VoidCallback onImportGpx;
  final RouteFailureCode? lastFailureCode;
  final String? lastFailureRiverSystemName;
  final String? lastFailurePutInReachId;
  final String? lastFailureTakeOutReachId;
  final String? routeReachId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final putIn = waypoints.isNotEmpty ? waypoints.first : null;
    final takeOut = waypoints.length >= 2 ? waypoints.last : null;
    final riverSystem = putIn?.riverSystem;

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
                    if (waypoints.isNotEmpty) ...[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        l10n.mapPlanningWaypointCount(waypoints.length),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                    if (putIn != null) ...[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        l10n.mapPlanningPutInName(putIn.name),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (takeOut != null && waypoints.length == 2) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        l10n.mapPlanningTakeOutName(takeOut.name),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (phase == RoutePlanningPhase.routeReady &&
                        riverSystem != null) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        l10n.mapPlanningRiverSystem(riverSystem.name),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (phase == RoutePlanningPhase.routeReady &&
                        routeReachId != null &&
                        routeReachId!.isNotEmpty) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        l10n.mapPlanningRouteReach(routeReachId!),
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
                        localizeMapPlannerMessage(
                          l10n: l10n,
                          message: RouteFailure(
                            code: lastFailureCode!,
                            riverSystemName: lastFailureRiverSystemName,
                            putInReachId: lastFailurePutInReachId,
                            takeOutReachId: lastFailureTakeOutReachId,
                          ),
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
                        Semantics(
                          button: true,
                          label: l10n.mapGpxImportLabel,
                          child: TextButton(
                            onPressed: gpxBusy ? null : onImportGpx,
                            child: Text(l10n.mapGpxImportLabel),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: l10n.mapGpxExportLabel,
                          child: TextButton(
                            onPressed: canExportGpx && !gpxBusy
                                ? onExportGpx
                                : null,
                            child: Text(l10n.mapGpxExportLabel),
                          ),
                        ),
                        TextButton(
                          onPressed: gpxBusy ? null : onClear,
                          child: Text(l10n.mapPlanningClearLabel),
                        ),
                        if (canSave)
                          TextButton(
                            onPressed: onSave,
                            child: Text(l10n.mapPlanningSaveLabel),
                          ),
                        TextButton(
                          onPressed: gpxBusy ? null : onDone,
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

  String _stepHint(AppLocalizations l10n) {
    if (waypoints.length > 2) {
      return l10n.mapPlanningInstructions;
    }
    return switch (phase) {
      RoutePlanningPhase.pickPutIn => l10n.mapPlanningStepPickPutIn,
      RoutePlanningPhase.pickTakeOut => l10n.mapPlanningStepPickTakeOut,
      RoutePlanningPhase.computingRoute => l10n.mapPlanningInstructions,
      RoutePlanningPhase.routeReady => l10n.mapPlanningInstructions,
      RoutePlanningPhase.routeError => l10n.mapPlanningInstructions,
    };
  }
}

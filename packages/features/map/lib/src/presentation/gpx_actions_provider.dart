import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/data/gpx_file_gateway.dart';
import 'package:eddyscout_map/src/data/launch_points.dart';
import 'package:eddyscout_map/src/presentation/map_planning_provider.dart';
import 'package:eddyscout_map/src/presentation/mapbox/mapbox_map_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gpx_actions_provider.g.dart';

/// Non-blocking warnings after a successful GPX import.
enum GpxImportWarning {
  /// Every point lies outside the PNW bounding box.
  outsidePnw,

  /// Endpoints could not be matched to catalog launches.
  launchSnapFailed,
}

/// Outcome of a GPX export or import action for UI feedback.
sealed class GpxActionOutcome {
  const GpxActionOutcome();
}

/// Export or import completed successfully.
final class GpxActionSuccess extends GpxActionOutcome {
  /// Creates a [GpxActionSuccess] with optional [warnings].
  const GpxActionSuccess({this.warnings = const []});

  /// Non-blocking warnings (e.g. PNW bounds or launch snap).
  final List<GpxImportWarning> warnings;
}

/// Export or import failed with a localized message key or failure object.
final class GpxActionFailure extends GpxActionOutcome {
  /// Creates a [GpxActionFailure].
  const GpxActionFailure(this.failure);

  /// Failure surfaced to the UI layer.
  final Object failure;
}

/// User cancelled file pick — no snackbar.
final class GpxActionCancelled extends GpxActionOutcome {
  /// Creates a [GpxActionCancelled].
  const GpxActionCancelled();
}

@Riverpod(keepAlive: true)
class GpxActions extends _$GpxActions {
  @override
  FutureOr<void> build() {}

  /// Exports the active planned route to GPX and opens the share sheet.
  Future<GpxActionOutcome> exportRoute() async {
    final planning = ref.read(routePlanningProvider);
    final polyline = planning.polylineLonLat;
    if (polyline == null || polyline.length < 2) {
      await _logExportFailure(GpxFailureCode.noRouteToExport);
      return const GpxActionFailure(
        GpxFailure(code: GpxFailureCode.noRouteToExport),
      );
    }

    final route = PlannedRoute.fromRouteSuccess(
      RouteResult.success(
            polylineLonLat: polyline,
            lengthMeters: (planning.routeLengthKm ?? 0) * 1000,
          )
          as RouteSuccess,
      putIn: planning.putIn,
      takeOut: planning.takeOut,
    ).copyWith(origin: planning.routeOrigin ?? RouteOrigin.planner);

    final serialized = GpxCodec.serialize(route);
    if (serialized.isFailure) {
      final code = serialized.errorOrNull!.code;
      await _logExportFailure(code);
      return GpxActionFailure(serialized.errorOrNull!);
    }

    final now = DateTime.now().toUtc();
    final filename =
        'eddyscout-route-${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}.gpx';

    final shared = await ref
        .read(gpxFileGatewayProvider)
        .writeAndShareGpx(filename: filename, gpxXml: serialized.valueOrNull!);

    return shared.when(
      success: (_) async {
        await ref
            .read(analyticsClientProvider)
            .logEvent(
              AnalyticsEvent(
                name: AnalyticsEvents.gpxExportSuccess,
                parameters: {
                  'point_count': route.points.length,
                  'has_matched_launches':
                      planning.putIn != null && planning.takeOut != null,
                  'origin': (planning.routeOrigin ?? RouteOrigin.planner).name,
                },
              ),
            );
        return const GpxActionSuccess();
      },
      failure: (error) async {
        await _logExportFailure(_failureCodeFrom(error));
        return GpxActionFailure(error);
      },
    );
  }

  /// Imports a GPX file, snaps endpoints, and draws the route on the map.
  Future<GpxActionOutcome> importRoute() async {
    if (!ref.read(routePlanningProvider).planningMode) {
      ref.read(routePlanningProvider.notifier).togglePlanningMode();
    }

    final picked = await ref.read(gpxFileGatewayProvider).pickAndReadGpx();
    if (picked.isFailure) {
      final error = picked.errorOrNull!;
      if (error is StorageFailure &&
          error.message == kGpxPickCancelledMessage) {
        return const GpxActionCancelled();
      }
      await _logImportFailure(_failureCodeFrom(error));
      return GpxActionFailure(error);
    }

    final parsed = GpxCodec.parse(picked.valueOrNull!);
    if (parsed.isFailure) {
      await _logImportFailure(parsed.errorOrNull!.code);
      return GpxActionFailure(parsed.errorOrNull!);
    }

    final route = LaunchEndpointSnapper.snapEndpoints(
      route: parsed.valueOrNull!,
      catalog: kLaunchPoints,
    );

    final warnings = <GpxImportWarning>[];
    if (GpxBounds.isEntirelyOutsidePnw(route.points)) {
      warnings.add(GpxImportWarning.outsidePnw);
    }
    if (route.putIn == null || route.takeOut == null) {
      warnings.add(GpxImportWarning.launchSnapFailed);
    }

    await ref
        .read(mapboxMapControllerProvider.notifier)
        .applyImportedRoute(route);

    await ref
        .read(analyticsClientProvider)
        .logEvent(
          AnalyticsEvent(
            name: AnalyticsEvents.gpxImportSuccess,
            parameters: {
              'point_count': route.points.length,
              'has_matched_launches':
                  route.putIn != null && route.takeOut != null,
              'origin': RouteOrigin.imported.name,
            },
          ),
        );

    return GpxActionSuccess(warnings: warnings);
  }

  Future<void> _logExportFailure(GpxFailureCode code) {
    return ref
        .read(analyticsClientProvider)
        .logEvent(
          AnalyticsEvent(
            name: AnalyticsEvents.gpxExportFailure,
            parameters: {'failure_code': code.name},
          ),
        );
  }

  Future<void> _logImportFailure(GpxFailureCode code) {
    return ref
        .read(analyticsClientProvider)
        .logEvent(
          AnalyticsEvent(
            name: AnalyticsEvents.gpxImportFailure,
            parameters: {'failure_code': code.name},
          ),
        );
  }

  GpxFailureCode _failureCodeFrom(AppFailure error) =>
      gpxFailureCodeFromAppFailure(error);
}

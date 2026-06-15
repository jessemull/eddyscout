import 'package:eddyscout/bootstrap/map_gpx_service_adapter.dart';
import 'package:eddyscout/bootstrap/map_route_planner_adapter.dart';
import 'package:eddyscout/preferences/key_value_store_provider.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_conditions/eddyscout_conditions_data.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/eddyscout_map_data.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Shared [ProviderScope] overrides for production and integration tests.
List<Override> buildAppProviderOverrides({
  required KeyValueStore keyValueStore,
  ConditionReportsRepository? conditionReportsRepository,
  ConditionsRepository? conditionsRepository,
  String? mapboxTokenOverride,
  bool? mapInteractiveOverride,
  GpxFileGateway? gpxFileGatewayOverride,
}) {
  final overrides = <Override>[
    routesProvider.overrideWithValue($appRoutes),
    keyValueStoreProvider.overrideWith((ref) async => keyValueStore),
    conditionReportsRepositoryProvider.overrideWithValue(
      conditionReportsRepository ?? const ConditionReportsRepositoryImpl(),
    ),
    conditionsRepositoryProvider.overrideWith(
      (ref) => conditionsRepository ?? ref.watch(conditionsServiceProvider),
    ),
    conditionsAiSummaryRepositoryProvider.overrideWithValue(
      const ConditionsAiSummaryRepositoryImpl(),
    ),
    conditionReportSubmitRepositoryProvider.overrideWithValue(
      const ConditionReportSubmitRepositoryImpl(),
    ),
    goNoGoProfileRepositoryProvider.overrideWithValue(
      GoNoGoProfileRepositoryImpl(keyValueStore),
    ),
    mapKeyValueStoreProvider.overrideWith((ref) async => keyValueStore),
    hydroGeoJsonLoaderProvider.overrideWithValue(
      () async => [
        await rootBundle.loadString('assets/hydro/willamette_waterway.geojson'),
        await rootBundle.loadString(
          'assets/hydro/columbia_gorge_waterway.geojson',
        ),
      ],
    ),
    gpxFileGatewayProvider.overrideWithValue(
      gpxFileGatewayOverride ?? const GpxFileGatewayImpl(),
    ),
    mapRoutePlannerProvider.overrideWith((ref) async {
      await ref.read(riverRoutePlannerProvider.future);
      return HydroMapRoutePlanner(ref);
    }),
    mapGpxServiceProvider.overrideWith(
      (ref) async => const HydroMapGpxService(),
    ),
  ];

  if (mapboxTokenOverride != null) {
    overrides.add(
      mapboxAccessTokenProvider.overrideWithValue(mapboxTokenOverride),
    );
  }

  if (mapInteractiveOverride != null) {
    overrides.add(
      mapInteractiveProvider.overrideWithValue(mapInteractiveOverride),
    );
  }

  return overrides;
}

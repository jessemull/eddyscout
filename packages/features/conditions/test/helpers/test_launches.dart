import 'package:eddyscout_core/eddyscout_core.dart';

/// Fixtures for conditions presentation tests (no map feature import).
const testCathedralParkLaunch = LaunchPoint(
  id: 'cathedral_park',
  name: 'Cathedral Park Boat Ramp',
  latitude: 45.588002,
  longitude: -122.758764,
  shortNote:
      'Willamette put-in below St. Johns Bridge; '
      'motorboat traffic and current.',
  riverSystem: RiverSystem.willamette,
  windExposure: WindExposure.moderate,
  tideRelevance: TideRelevance.minor,
  noaaTideStationId: '9439221',
  usgsSiteId: '14211720',
  flowBands: kFlowBandsUsgs14211720WillamettePortland,
);

const testKelleyPointLaunch = LaunchPoint(
  id: 'kelley_point',
  name: 'Kelley Point Park (Slough launch)',
  latitude: 45.6463,
  longitude: -122.7580,
  shortNote:
      'Slough-side put-in near park entrance; confluence currents and '
      'Columbia tide influence—check park rules.',
  riverSystem: RiverSystem.slough,
  windExposure: WindExposure.exposed,
  tideRelevance: TideRelevance.major,
  noaaTideStationId: '9440083',
  marineZoneId: 'PZZ210',
);

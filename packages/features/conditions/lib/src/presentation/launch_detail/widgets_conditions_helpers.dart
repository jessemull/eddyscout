part of 'launch_detail_screen.dart';

String _localizedConditionsError(AppLocalizations l10n, String code) =>
    switch (code) {
      // Weather
      'weather_fallback_no_data' ||
      'weather_nws_points_failed' ||
      'weather_nws_hourly_url_missing' ||
      'weather_nws_hourly_failed' ||
      'weather_nws_hourly_parse_failed' ||
      'weather_nws_error' => l10n.launchDetailUnavailable,

      // Tides
      'tides_no_predictions' || 'tides_error' => l10n.launchDetailNoTideData,

      // Marine
      'marine_zone_lookup_failed' ||
      'marine_no_office_linked' ||
      'marine_office_list_unavailable' ||
      'marine_no_products_for_office' ||
      'marine_product_load_failed' ||
      'marine_product_no_text' ||
      'marine_zone_missing_in_product' ||
      'marine_error' => l10n.launchDetailNoMarineForecast,

      // River
      'river_request_failed' ||
      'river_unexpected_response' ||
      'river_error' => l10n.launchDetailRiverFlowNoData,
      'river_no_discharge_now' => l10n.launchDetailRiverFlowNoData,

      _ => l10n.launchDetailUnavailable,
    };

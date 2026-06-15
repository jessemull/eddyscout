# eddyscout_hydro_routing

River-line graph routing between launches on bundled hydro geometry.

Override `hydroGeoJsonLoaderProvider` in the app `ProviderScope`. The loader must
return a `Future<List<String>>` — one GeoJSON document string per bundled asset
(for example Willamette and Columbia gorge reach files). Documents are merged
into a single graph set keyed by `properties.river_system`.

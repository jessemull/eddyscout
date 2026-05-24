# Hydro line assets (river routing)

Bundled GeoJSON under `assets/hydro/` supplies **approximate** river centerlines for in-app routing. The app builds an undirected graph from `LineString` features and runs shortest-path between snapped launch points.

## Current files

- `willamette_waterway.geojson` — Willamette main stem from OpenStreetMap (`waterway=river`, ways 163656027 + 164125011 merged). Denser than a hand-drawn line so route polylines follow bends instead of long chords across the basemap river.

## Refreshing or extending data

1. **OpenStreetMap (Overpass API)**  
   Query `waterway=river` / `waterway=stream` inside a bounding box, export as GeoJSON. Merge ways, simplify with [mapshaper](https://mapshaper.org/) or QGIS if needed.  
   Set feature property `river_system` to match Dart enum names: `willamette`, `columbia`, `clackamas`, `slough`.

2. **US NHD (National Hydrography Dataset)**  
   Download flowlines for your HUC, clip to region, export GeoJSON LineStrings. Often better connectivity than OSM for US rivers.

3. **Replace or add assets**  
   Add new `.geojson` files, list them in `pubspec.yaml` under `flutter.assets`, and wire loading in `RiverRoutePlanner` (or a small registry) if you ship multiple rivers.

Coordinates must be **WGS84** `[longitude, latitude]` per GeoJSON.

## Disclaimer

These lines are for **planning visualization only**, not navigation. Verify flow direction, hazards, and access on the water.

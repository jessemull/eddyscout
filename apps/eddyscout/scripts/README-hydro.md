# Hydro line assets (river routing)

Bundled GeoJSON under `assets/hydro/` supplies **approximate** river centerlines for in-app routing. The app builds an undirected graph from `LineString` features and runs shortest-path between snapped launch points.

## Current files

| File | `river_system` | Notes |
|------|----------------|-------|
| `willamette_waterway.geojson` | `willamette` | Main stem from OpenStreetMap (`waterway=river`, ways 163656027 + 164125011 merged). |
| `columbia_lower_waterway.geojson` | `columbia` | Curated Portland-pool centerline from Willamette mouth to gorge segment start. Replace with OSM/NHD in R1. |
| `columbia_gorge_waterway.geojson` | `columbia` | Bonneville pool / gorge reach (OSM ways merged; north extension curated near Port of Camas). |
| `confluence_bridges.json` | — | Optional curated edges where geometry is missing but systems should connect (see below). |

Coordinates must be **WGS84** `[longitude, latitude]` per GeoJSON. Feature property `river_system` must match Dart enum names: `willamette`, `columbia`, `clackamas`, `slough`.

## Confluence bridges (`confluence_bridges.json`)

Use bridges only when two systems should route together but bundled GeoJSON does not yet share a vertex (within the 12 m merge threshold).

### Format

JSON array of objects:

```json
[
  {
    "id": "unique_stable_id",
    "a": { "lat": 45.6178872, "lon": -122.7909498 },
    "b": { "lat": 45.5856, "lon": -122.4244 }
  }
]
```

- **`id`** — logged at graph build; use snake_case; never reuse after removal.
- **`a` / `b`** — WGS84 endpoints. Each must snap to an existing graph vertex within **200 m** or the bridge is skipped.

Bridges add a single undirected edge weighted by haversine distance between the snapped vertices. Keep endpoints on the waterway centerline, not on launch pins.

### When to add or update bridges

1. **Prefer geometry first** — extend or add `*_waterway.geojson` so line endpoints meet at confluences. Remove redundant bridges when shared vertices connect the graph.
2. **After importing new GeoJSON** — re-run routing tests (`packages/features/hydro_routing`) and check debug logs for `addConfluenceBridges: skipped` or unexpectedly long bridge edges (> ~5 km).
3. **After moving a line endpoint** — update bridge `a`/`b` to the new mouth/confluence coordinates or delete the bridge if geometry now connects.
4. **Placeholder bridges** — keep entries whose `a`/`b` both lie on bundled geometry for future systems (e.g. Clackamas) even if one side has no line yet; they are skipped until both endpoints snap.

Loaded in production via `hydroConfluenceBridgesLoaderProvider` in `app_provider_overrides.dart`.

## Refreshing or extending data

1. **OpenStreetMap (Overpass API)**  
   Query `waterway=river` / `waterway=stream` inside a bounding box, export as GeoJSON. Merge ways, simplify with [mapshaper](https://mapshaper.org/) or QGIS if needed.

2. **US NHD (National Hydrography Dataset)**  
   Download flowlines for your HUC, clip to region, export GeoJSON LineStrings. Often better connectivity than OSM for US rivers.

3. **Replace or add assets**  
   Add new `.geojson` files, list them in `pubspec.yaml` under `flutter.assets`, and append paths in `hydroGeoJsonLoaderProvider` (`app_provider_overrides.dart`).

## Disclaimer

These lines are for **planning visualization only**, not navigation. Verify flow direction, hazards, and access on the water.

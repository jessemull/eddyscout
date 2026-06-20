# Hydro line assets (river routing)

Bundled GeoJSON under `assets/hydro/` supplies **approximate** river centerlines for in-app routing. The app builds an undirected graph from `LineString` features and runs shortest-path between snapped launch points.

## Current files

| File | `river_system` | Notes |
|------|----------------|-------|
| `willamette_waterway.geojson` | `willamette` | Main stem from OpenStreetMap (`waterway=river`, ways 163656027 + 164125011 merged). |
| `columbia_lower_waterway.geojson` | `columbia` | Willamette mouth → Camas from OSM Overpass merge (`scripts/overpass/fetch_columbia_waterway.py`); mouth shares Willamette end vertex. |
| `columbia_gorge_waterway.geojson` | `columbia` | Camas → Glenn Otto from OSM way 163917830 + Sandy River way 128946456. |
| `confluence_bridges.json` | — | Optional curated edges where geometry is missing but systems should connect (see below). |

Coordinates must be **WGS84** `[longitude, latitude]` per GeoJSON. Feature property `river_system` must match Dart enum names: `willamette`, `columbia`, `clackamas`, `slough`.

## Import pipeline (Columbia)

Regenerate Columbia assets from OpenStreetMap:

```bash
python3 scripts/overpass/fetch_columbia_waterway.py
./scripts/check_hydro_geometry.sh
```

The import script:

1. Reads the Willamette mouth from bundled `willamette_waterway.geojson`.
2. Merges connected `waterway=river|canal|fairway` ways via Overpass.
3. Routes mouth → Camas on the merged graph (no hand-drawn mouth connector).
4. Builds the gorge reach from OSM way `163917830` + Sandy River way `128946456`.
5. Writes assets and matching test fixtures.

CI / preflight runs `scripts/check_hydro_geometry.sh`, which fails when any edge exceeds **2000 m** or confluence gaps exceed **12 m** (same merge threshold as `RiverLineGraph`).

## Launch snap gaps (known)

| Launch | Gap to bundled geometry | Notes |
|--------|------------------------|-------|
| Port of Camas marina | ~2.2 km to Columbia mainstem | Not routable until Camas Slough OSM spur (way `130204446` or equivalent) is bundled; nearest slough point is ~890 m but not connected to mainstem within the 12 m merge threshold. |
| Washougal Waterfront Park | ~610 m to gorge mainstem | Within the 900 m route snap threshold; routes on gorge geometry. |

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
   Query `waterway=river` / `waterway=stream` inside a bounding box, export as GeoJSON. Use `scripts/overpass/fetch_columbia_waterway.py` for Columbia lower + gorge. Merge ways, simplify with [mapshaper](https://mapshaper.org/) or QGIS if needed.

2. **US NHD (National Hydrography Dataset)**  
   Download flowlines for your HUC via `scripts/nhd/` (`download.sh`, `convert.py`, `validate.py`). Often better connectivity than OSM for US rivers.

3. **Replace or add assets**  
   Add new `.geojson` files, list them in `pubspec.yaml` under `flutter.assets`, and append paths in `hydroGeoJsonLoaderProvider` (`app_provider_overrides.dart`).

## Disclaimer

These lines are for **planning visualization only**, not navigation. Verify flow direction, hazards, and access on the water.

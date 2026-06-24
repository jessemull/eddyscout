# Hydro line assets (river routing)

Bundled GeoJSON under `assets/hydro/` supplies **approximate** river centerlines for in-app routing. The app builds an undirected graph from `LineString` features and runs shortest-path between snapped launch points.

## Current files

| File | `river_system` | Notes |
|------|----------------|-------|
| `willamette_waterway.geojson` | `willamette` | Main stem from OpenStreetMap (`waterway=river`, ways 163656027 + 164125011 merged). |
| `columbia_lower_waterway.geojson` | `columbia` | **Multi-feature:** (0) Willamette mouth → Camas mainstem; (1) `camas_slough_spur` for Port of Camas marina. |
| `columbia_gorge_waterway.geojson` | `columbia` | Camas → Glenn Otto through-channel mainstem (OSM way 163917830 + Sandy River way 128946456). |
| `confluence_bridges.json` | — | Optional curated edges where geometry is missing but systems should connect (see below). |

Coordinates must be **WGS84** `[longitude, latitude]` per GeoJSON. Feature property `river_system` must match Dart enum names: `willamette`, `columbia`, `clackamas`, `slough`.

## Import pipeline (Columbia + Camas Slough)

Regenerate Columbia assets from OpenStreetMap:

```bash
python3 scripts/overpass/fetch_columbia_waterway.py
python3 scripts/overpass/fetch_slough_waterway.py
make hydro-check
```

The Columbia import script:

1. Reads the Willamette mouth from bundled `willamette_waterway.geojson`.
2. Merges connected `waterway=river|canal|fairway` ways via Overpass.
3. Routes mouth → Camas on the merged graph and **prunes backtrack loops** (Hayden Island / side-channel detours).
4. Builds the gorge reach as a **through-channel** subline on OSM way `163917830` (Camas → Sandy junction) plus Sandy River way `128946456` — launch pins are not inlined into mainstem geometry.
5. Writes assets and matching test fixtures (preserving an existing `camas_slough_spur` feature when re-running Columbia-only).

The slough import script:

1. Fetches OSM way `130204446` (Camas Slough) plus local connector ways.
2. Builds a spur from **Camas split** on `columbia_lower` mainstem through the slough toward Port of Camas marina (~890 m snap).
3. Appends the spur as feature `camas_slough_spur` in `columbia_lower_waterway.geojson`.

CI / preflight runs `make hydro-check` (`scripts/check_hydro_geometry.sh`), which fails when any edge exceeds **2000 m**, confluence gaps exceed **12 m**, or a LineString **revisits** a prior vertex within **12 m** (same merge threshold as `RiverLineGraph`).

## Launch snap gaps (known)

| Launch | Gap to bundled geometry | Notes |
|--------|------------------------|-------|
| Port of Camas marina | ~890 m to `camas_slough_spur` | Routable via slough spur connected to Columbia mainstem at Camas split. |
| Washougal Waterfront Park | ~965 m to nearest geometry | Beyond 900 m route snap; needs a future Washougal side-channel spur (not mainstem-inlined). |

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
   Query `waterway=river` / `waterway=stream` inside a bounding box, export as GeoJSON. Use `scripts/overpass/fetch_columbia_waterway.py` and `fetch_slough_waterway.py` for Columbia lower + gorge + Camas Slough. Merge ways, simplify with [mapshaper](https://mapshaper.org/) or QGIS if needed.

2. **US NHD (National Hydrography Dataset)**  
   Download flowlines for your HUC via `scripts/nhd/` (`download.sh`, `convert.py`, `validate.py`). Often better connectivity than OSM for US rivers.

3. **Replace or add assets**  
   Add new `.geojson` files, list them in `pubspec.yaml` under `flutter.assets`, and append paths in `hydroGeoJsonLoaderProvider` (`app_provider_overrides.dart`).

## Disclaimer

These lines are for **planning visualization only**, not navigation. Verify flow direction, hazards, and access on the water.

## Launch reachability index

Pre-computed graph-distance bands (5 / 10 / 20 statute miles, exclusive) per catalog launch live at `assets/data/launch_reachability_index.json`.

Regenerate after hydro geometry or catalog changes:

```bash
make gen-reachability
make gen-suggested-trips
make gen-reachability-check   # CI-friendly stale check
```

Expected runtime: **< 2 s** for the full catalog on CI hardware. Indexes use the same hydro bundle as production (Willamette + Columbia lower + gorge + confluence bridges) with **`crossSystemReachability: true`**.

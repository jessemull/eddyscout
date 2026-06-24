# Hydro line assets (river routing)

Bundled GeoJSON under `assets/hydro/` supplies **approximate** river centerlines for in-app routing. The app builds an undirected graph from `LineString` features and runs shortest-path between snapped launch points.

Coordinates must be **WGS84** `[longitude, latitude]` per GeoJSON.

## Bundled assets

| File | `river_system` | Reach / notes |
|------|----------------|---------------|
| `willamette_waterway.geojson` | `willamette` | Main stem Oregon City pool → Columbia mouth; launch anchor extensions (Willamette Park, Sportcraft / eNRG) |
| `columbia_lower_waterway.geojson` | `columbia` | Mouth → Camas split; Multnomah Channel spur (Scappoose); lower-pool spurs (Vancouver, St Helens, Frenchman's Bar) |
| `columbia_gorge_waterway.geojson` | `columbia` | Camas → Glenn Otto (Sandy tail on way `163917830` + `128946456`) |
| `clackamas_waterway.geojson` | `clackamas` | Main stem to Clackamette Park anchor |
| `slough_waterway.geojson` | `slough` | Multnomah / Smith & Bybee slough network; Kelley Point extension |
| `tualatin_waterway.geojson` | `tualatin` | Metro reach (no `RiverSystem.tualatin` enum or catalog launches yet) |
| `sandy_waterway.geojson` | `columbia` | Sandy River subline (`reach_id`: `sandy_main`) |
| `confluence_bridges.json` | — | Placeholder for temporary bridge edges; **geometry-first** policy (see below) |

Provenance is recorded in each feature's `source` property. Regenerate with the Overpass scripts under `scripts/overpass/` (see `scripts/overpass/README.md` for script-level detail).

### Confluence chain (endpoint gaps ≤ 12 m)

```
willamette_waterway.geojson
        ↓ Willamette mouth
columbia_lower_waterway.geojson
        ↓ Camas split
columbia_gorge_waterway.geojson
```

Clackamas and Sandy joins to Willamette/Columbia are validated for internal graph quality but are **informational only** in `check_geometry.py` until endpoint gaps are within 12 m (Clackamas ~300 m today).

### `confluence_bridges.json` policy

Prefer shared geometry vertices at confluences (≤ 12 m gap, same threshold as `RiverLineGraph`). Bridge entries in `confluence_bridges.json` are a **temporary** fallback only; cross-system routing logic lives on `feat/cross-system-routing` (PR #62). This branch bundles the placeholder file but does not load it in Dart.

Launch anchor extensions (Willamette Park, Sportcraft, Vancouver Wintler, Scappoose, St Helens) snap catalog pins to the graph when OSM centerlines end short. Frenchman's Bar uses a densified connector (up to ~12 km) when the Columbia River centerline is farther than the launch anchor from OSM.

## Refreshing data (Overpass)

Requires network access. Fetchers overwrite assets and mirror copies to `packages/features/hydro_routing/test/fixtures/`.

| Make target | Script |
|-------------|--------|
| `make hydro-fetch-willamette` | `scripts/overpass/fetch_willamette_waterway.py` |
| `make hydro-fetch-columbia` | `scripts/overpass/fetch_columbia_waterway.py` |
| `make hydro-fetch-clackamas` | `scripts/overpass/fetch_clackamas_waterway.py` |
| `make hydro-fetch-slough` | `scripts/overpass/fetch_slough_waterway.py` |
| `make hydro-fetch-tualatin` | `scripts/overpass/fetch_tualatin_waterway.py` |
| `make hydro-fetch-sandy` | `scripts/overpass/fetch_sandy_waterway.py` |
| `make hydro-fetch` | `scripts/overpass/fetch_all_portland_hydro.sh` (all of the above, in order) |
| `make hydro-sync-fixtures` | Copy `assets/hydro/` → test fixtures |

After changing geometry locally, run `make hydro-check` before committing.

## Validation gates

| Gate | Command / test | Threshold |
|------|----------------|-----------|
| Geometry (CI) | `make hydro-check` / `scripts/preflight.sh` | Max edge **2000 m**; declared confluence endpoint gaps **12 m** |
| Graph load | `packages/features/hydro_routing/test/bundled_hydro_connectivity_test.dart` | Non-empty graph per system; required confluences connected; informational gaps documented |
| Launch snap | `packages/features/hydro_routing/test/bundled_launch_snap_test.dart` | Each catalog launch on a system with geometry snaps within **900 m** (`kReachabilitySnapMaxMeters`) |
| Bundle size | `apps/eddyscout/test/assets/hydro_asset_bounds_test.dart` | Per-file ceilings + total **< 500 KB** |

## Launch reachability index

Pre-computed graph-distance bands (5 / 10 / 20 statute miles, exclusive) per catalog launch live at `assets/data/launch_reachability_index.json`.

Regenerate after hydro geometry or catalog changes:

```bash
make gen-reachability
make gen-reachability-check   # CI-friendly stale check
```

Expected runtime: **< 2 s** for the full catalog on CI hardware. Cross-system pairs are excluded until unified multi-system routing lands (`crossSystemReachability: false` in the JSON).

## PR #62 dependency

Cross-system route planning (`cathedral_park` → `glenn_otto_troutdale` without bridges) requires **`feat/cross-system-routing` (PR #62)** merged on top of this geometry. This branch keeps the per-system `RiverRoutePlanner` on `main` and validates confluence geometry only.

## Out of scope

- **Replacing bundled GeoJSON with NHD output** — compare/report only; see `scripts/nhd/`
- **Server-side / PostGIS routing** (R5)
- Loading `confluence_bridges.json` in the app (owned by PR #62)

## NHD alternative source

For higher-resolution US centerlines (dev-time compare only):

```bash
make hydro-nhd-run      # download → convert → validate (network + GDAL)
make hydro-nhd-compare  # OSM vs NHD report when output/ exists
```

See [`scripts/nhd/README.md`](../../../scripts/nhd/README.md).

## Confluence connectivity audit

| Pair | Gate | Typical gap | Bridge | Notes |
|------|------|-------------|--------|-------|
| Willamette → Columbia lower | **required** (CI) | 0 m | — | Shared mouth vertex |
| Columbia lower → gorge | **required** (CI) | 0 m | — | Camas split anchor |
| Clackamas → Willamette | informational | ~300 m | `clackamas_willamette_oc` placeholder | Extend geometry or bridge when cross-system Clackamas routing ships |
| Sandy → Columbia gorge | informational | 0 m at Glenn Otto (end↔end) | — | Sandy subline shares gorge endpoint |

Dart audit: `packages/features/hydro_routing/test/bundled_hydro_connectivity_test.dart`  
Python audit: `scripts/hydro/check_geometry.py` (`audit_confluence_connectivity`)

## Disclaimer

These lines are for **planning visualization only**, not navigation. Verify flow direction, hazards, and access on the water.

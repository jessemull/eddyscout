# Hydro line assets (river routing)

Bundled GeoJSON under `assets/hydro/` supplies **approximate** river centerlines for in-app routing. The app builds an undirected graph from `LineString` features and runs shortest-path between snapped launch points.

Coordinates must be **WGS84** `[longitude, latitude]` per GeoJSON.

## Bundled assets

| File | `river_system` | Reach / notes |
|------|----------------|---------------|
| `willamette_waterway.geojson` | `willamette` | Main stem Oregon City pool → Columbia mouth; launch anchor extensions (Willamette Park, Sportcraft / eNRG) |
| `columbia_lower_waterway.geojson` | `columbia` | Mouth → Camas split; launch spurs (Vancouver Wintler, Multnomah/Scappoose, lower pool); **`camas_slough_spur`** for Port of Camas marina |
| `columbia_gorge_waterway.geojson` | `columbia` | Camas → Glenn Otto through-channel mainstem (OSM way `163917830` + Sandy River way `128946456`; no launch pin inlining) |
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

Prefer shared geometry vertices at confluences (≤ 12 m gap, same threshold as `RiverLineGraph`). Bridge entries in `confluence_bridges.json` are a **temporary** fallback only; cross-system routing uses bundled geometry with `crossSystemReachability: true` in reachability indexes.

Launch anchor extensions (Willamette Park, Sportcraft, Vancouver Wintler, Scappoose, St Helens) snap catalog pins to the graph when OSM centerlines end short. Frenchman's Bar uses a densified connector (up to ~12 km) when the Columbia River centerline is farther than the launch anchor from OSM.

### Launch snap gaps (known)

All catalog launches use **access** + **water-entry** coordinates. Water-entry snap is gated at 200 m in CI; routability validation uses the 900 m reachability threshold. Side spurs for Port of Camas, Scappoose Bay Marina, and Washougal Waterfront are maintained via `scripts/hydro/patch_launch_spurs.py` (also run after Camas Slough Overpass import).

| Launch | Notes |
|--------|-------|
| Port of Camas marina | `camas_slough_spur` extended to catalog water-entry anchor |
| Scappoose Bay Marina | `scappoose_marina_spur` side branch from lower-pool geometry |
| Washougal Waterfront Park | `washougal_waterfront_spur` side branch from gorge mainstem |

## Refreshing data (Overpass)

Requires network access. Fetchers overwrite assets and mirror copies to `packages/features/hydro_routing/test/fixtures/`.

| Make target | Script |
|-------------|--------|
| `make hydro-fetch-willamette` | `scripts/overpass/fetch_willamette_waterway.py` |
| `make hydro-fetch-columbia` | `scripts/overpass/fetch_columbia_waterway.py` |
| `make hydro-fetch-camas-slough` | `scripts/overpass/fetch_camas_slough_waterway.py` (run after Columbia) |
| `make hydro-fetch-washougal` | `scripts/overpass/fetch_washougal_waterfront_spur.py` (run after Camas Slough) |
| `make hydro-fetch-clackamas` | `scripts/overpass/fetch_clackamas_waterway.py` |
| `make hydro-fetch-slough` | `scripts/overpass/fetch_slough_waterway.py` (Multnomah / Smith & Bybee) |
| `make hydro-fetch-tualatin` | `scripts/overpass/fetch_tualatin_waterway.py` |
| `make hydro-fetch-sandy` | `scripts/overpass/fetch_sandy_waterway.py` |
| `make hydro-fetch` | `scripts/overpass/fetch_all_portland_hydro.sh` (all of the above, in order) |
| `make hydro-sync-fixtures` | Copy `assets/hydro/` → test fixtures |

Columbia import (`fetch_columbia_waterway.py`):

1. Reads the Willamette mouth from bundled `willamette_waterway.geojson`.
2. Merges connected `waterway=river|canal|fairway` ways via Overpass.
3. Routes mouth → Camas on the merged graph and **prunes backtrack loops** (Hayden Island / side-channel detours).
4. Builds lower-pool launch spurs (Vancouver Wintler side branch, Multnomah/Scappoose, St Helens/Frenchman's Bar).
5. Builds the gorge reach as a **through-channel** subline on OSM way `163917830` (Camas → Sandy junction) plus Sandy River way `128946456` — launch pins are not inlined into mainstem geometry.
6. Preserves existing `camas_slough_spur` and `washougal_waterfront_spur` features when re-running Columbia-only.

Camas Slough import (`fetch_camas_slough_waterway.py`):

1. Fetches OSM way `130204446` (Camas Slough) plus local connector ways.
2. Builds a spur from **Camas split** on `columbia_lower` mainstem through the slough toward Port of Camas marina (catalog anchor via `scripts/hydro/launch_anchors.json`).
3. Appends the spur as feature `camas_slough_spur` in `columbia_lower_waterway.geojson`.

Washougal Waterfront import (`fetch_washougal_waterfront_spur.py`):

1. Requires `camas_slough_spur` in `columbia_lower_waterway.geojson`.
2. Builds a side spur from the nearest point on `camas_slough_spur` to the Washougal Waterfront catalog anchor (~220 m; not inlined into mainstem).
3. Appends feature `washougal_waterfront_spur` in `columbia_lower_waterway.geojson`.

After changing geometry locally, run `make hydro-check` before committing.

## Validation gates

| Gate | Command / test | Threshold |
|------|----------------|-----------|
| Geometry (CI) | `make hydro-check` / `scripts/preflight.sh` | Max edge **2000 m**; required confluence endpoint gaps **12 m**; backtrack loop detection within **12 m** |
| Graph load | `packages/features/hydro_routing/test/bundled_hydro_connectivity_test.dart` | Non-empty graph per system; required confluences connected; informational gaps documented |
| Launch snap (water entry) | `packages/features/hydro_routing/test/bundled_launch_snap_test.dart` | Each catalog launch **water-entry** coords snap within **200 m** (`kCatalogWaterEntrySnapMaxMeters`) |
| Launch routability | same test file | Routing validates at **900 m** (`kReachabilitySnapMaxMeters`) |
| Bundle size | `apps/eddyscout/test/assets/hydro_asset_bounds_test.dart` | Per-file ceilings + total **< 500 KB** |

## Launch reachability index

Pre-computed graph-distance bands (5 / 10 / 20 statute miles, exclusive) per catalog launch live at `assets/data/launch_reachability_index.json`.

Regenerate after hydro geometry or catalog changes:

```bash
make gen-reachability
make gen-suggested-trips
make gen-reachability-check   # CI-friendly stale check
```

Expected runtime: **< 2 s** for the full catalog on CI hardware. Indexes use the full bundled hydro set with **`crossSystemReachability: true`**.

## Out of scope

- **Replacing bundled GeoJSON with NHD output** — compare/report only; see `scripts/nhd/`
- **Server-side / PostGIS routing** (R5)

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
Anchor coordinates: `scripts/hydro/confluence_audit.json` (shared with NHD compare)

## Unified hydro graph binary

Precomputed graph at `assets/data/unified_hydro_graph.bin` speeds cold start (binary decode instead of GeoJSON parse at runtime). GeoJSON remains the source of truth for geometry edits.

Regenerate after hydro geometry or confluence bridge changes:

```bash
make gen-hydro-graph
make gen-hydro-graph-check   # CI-friendly stale check
```

The generator loads all files in `bundledHydroGeoJsonAssetFileNames` plus `confluence_bridges.json`, builds the unified graph, and writes a versioned binary (`EDHY` magic). The app prefers binary via `hydroGraphBinaryLoaderProvider` and falls back to GeoJSON when the asset is missing or corrupt.

## Launch water-entry snap validation

Build-time validation for catalog routing coordinates (`make gen-launch-snap-check`, wired into `make gen-check`):

```bash
make gen-launch-snap-check   # CI: 200 m gate for launches with water-entry coords
dart run scripts/generate_launch_water_entry_snaps.dart   # audit report (all launches)
```

Until catalog launches have explicit `waterEntryLatitude` / `waterEntryLongitude`, the CI gate is a no-op; the report lists snap distances for manual pin realignment (R3).

**200 m allowlist** (access pins inland of spur geometry; exempt from strict gate until R3): `washougal_waterfront`, `port_of_camas`, `scappoose_bay_marina`. Single source of truth: `kLaunchWaterEntrySnapAllowlist` in `packages/features/hydro_routing/lib/src/data/launch_water_entry_snap_generator.dart`.

## Disclaimer

These lines are for **planning visualization only**, not navigation. Verify flow direction, hazards, and access on the water.

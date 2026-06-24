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

Clackamas and Sandy joins to Willamette/Columbia are validated for internal graph quality but are **not** chained in `check_geometry.py` until OSM connectivity is stable end-to-end.

### `confluence_bridges.json` policy

Prefer shared geometry vertices at confluences (≤ 12 m gap, same threshold as `RiverLineGraph`). Bridge entries in `confluence_bridges.json` are a **temporary** fallback only; cross-system routing uses bundled geometry with `crossSystemReachability: true` in reachability indexes.

Launch anchor extensions (Willamette Park, Sportcraft, Vancouver Wintler, Scappoose, St Helens) snap catalog pins to the graph when OSM centerlines end short. Frenchman's Bar uses a densified connector (up to ~12 km) when the Columbia River centerline is farther than the launch anchor from OSM.

### Launch snap gaps (known)

| Launch | Gap to bundled geometry | Notes |
|--------|------------------------|-------|
| Port of Camas marina | ~890 m to `camas_slough_spur` | Routable via slough spur connected to Columbia mainstem at Camas split. |
| Washougal Waterfront Park | ~965 m to nearest geometry | Beyond 900 m route snap; needs a future Washougal side-channel spur (not mainstem-inlined). |

## Refreshing data (Overpass)

Requires network access. Fetchers overwrite assets and mirror copies to `packages/features/hydro_routing/test/fixtures/`.

| Make target | Script |
|-------------|--------|
| `make hydro-fetch-willamette` | `scripts/overpass/fetch_willamette_waterway.py` |
| `make hydro-fetch-columbia` | `scripts/overpass/fetch_columbia_waterway.py` |
| `make hydro-fetch-camas-slough` | `scripts/overpass/fetch_camas_slough_waterway.py` (run after Columbia) |
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
6. Preserves an existing `camas_slough_spur` feature when re-running Columbia-only.

Camas Slough import (`fetch_camas_slough_waterway.py`):

1. Fetches OSM way `130204446` (Camas Slough) plus local connector ways.
2. Builds a spur from **Camas split** on `columbia_lower` mainstem through the slough toward Port of Camas marina (~890 m snap).
3. Appends the spur as feature `camas_slough_spur` in `columbia_lower_waterway.geojson`.

After changing geometry locally, run `make hydro-check` before committing.

## Validation gates

| Gate | Command / test | Threshold |
|------|----------------|-----------|
| Geometry (CI) | `make hydro-check` / `scripts/preflight.sh` | Max edge **2000 m**; declared confluence endpoint gaps **12 m**; backtrack loop detection within **12 m** |
| Graph load | `packages/features/hydro_routing/test/bundled_hydro_connectivity_test.dart` | Non-empty graph per expected `river_system` |
| Launch snap | `packages/features/hydro_routing/test/bundled_launch_snap_test.dart` | Each catalog launch on a system with geometry snaps within **900 m** (`kReachabilitySnapMaxMeters`) |
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

- **NHD download / conversion** — see `scripts/nhd/` (separate R1 item)
- **Server-side / PostGIS routing** (R5)
- **Two-pin launch model** — catalog coordinates unchanged; side spurs only

## Disclaimer

These lines are for **planning visualization only**, not navigation. Verify flow direction, hazards, and access on the water.

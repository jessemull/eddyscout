# OpenStreetMap Overpass import scripts for bundled hydro assets.

App-facing documentation (asset table, validation gates, make targets) lives in
[`apps/eddyscout/scripts/README-hydro.md`](../../apps/eddyscout/scripts/README-hydro.md).

## Columbia lower + gorge

```bash
python3 scripts/overpass/fetch_columbia_waterway.py
```

Fetches connected `waterway=river|canal|fairway` ways for the Portland–Columbia
corridor, then:

1. **Lower reach** — shortest OSM path from the Willamette mouth (read from bundled
   `willamette_waterway.geojson`) to the Camas split anchor; backtrack loops pruned;
   launch spurs for Vancouver Wintler, Multnomah/Scappoose, and lower pool.
2. **Gorge reach** — through-channel OSM subline on Columbia way `163917830` from
   Camas to Sandy junction, plus Sandy River way `128946456` to Glenn Otto (no launch
   pin inlining on mainstem).

Outputs are written to:

- `apps/eddyscout/assets/hydro/columbia_lower_waterway.geojson` (mainstem + launch spurs;
  re-run preserves an existing `camas_slough_spur` feature when present)
- `apps/eddyscout/assets/hydro/columbia_gorge_waterway.geojson`
- matching copies under `packages/features/hydro_routing/test/fixtures/`

## Camas Slough spur

```bash
python3 scripts/overpass/fetch_camas_slough_waterway.py
```

Run **after** `fetch_columbia_waterway.py`. Fetches OSM way `130204446` (Camas Slough)
and local connector ways, then appends a `camas_slough_spur` feature to
`columbia_lower_waterway.geojson` (shared Camas split vertex with mainstem + gorge).

## Washougal Waterfront spur

```bash
python3 scripts/overpass/fetch_washougal_waterfront_spur.py
```

Run **after** `fetch_camas_slough_waterway.py`. Builds `washougal_waterfront_spur`
branching from `camas_slough_spur` to the Washougal Waterfront catalog anchor.

## Portland slough network

```bash
python3 scripts/overpass/fetch_slough_waterway.py
```

Imports Multnomah Channel / Smith & Bybee slough geometry (separate from Camas Slough).

## Validation

Bundled assets, confluence bridges, and known launch snap gaps are documented in
[`apps/eddyscout/scripts/README-hydro.md`](../../apps/eddyscout/scripts/README-hydro.md#launch-snap-gaps-known).

```bash
make hydro-check
```

Runs bundled geometry validation plus `scripts/hydro/` unit tests. Fails when any
bundled edge exceeds **2000 m**, required confluence gaps exceed **12 m**, or a polyline
revisits a prior vertex within **12 m** (the same merge threshold as
`RiverLineGraph`). Also runs NHD script unit tests when present.

Unit tests only:

```bash
python3 -m unittest discover -s scripts/hydro -p 'test_*.py'
```

For US NHD centerlines as an alternative/supplement to Overpass, see [`scripts/nhd/README.md`](../nhd/README.md).

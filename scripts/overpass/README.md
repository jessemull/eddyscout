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
   `willamette_waterway.geojson`) to the Camas split anchor.
2. **Gorge reach** — OSM subline on Columbia way `163917830` from Camas to the
   Washougal mainstem, plus a shortest path on local Sandy River / side-channel
   ways to the Glenn Otto Park anchor.

Outputs are written to:

- `apps/eddyscout/assets/hydro/columbia_lower_waterway.geojson`
- `apps/eddyscout/assets/hydro/columbia_gorge_waterway.geojson`
- matching copies under `packages/features/hydro_routing/test/fixtures/`

Sparse OSM segments longer than 2 km are densified along the existing segment
before write so bundled geometry passes `scripts/check_hydro_geometry.sh`.

## Validation

```bash
./scripts/check_hydro_geometry.sh
```

Fails when any bundled edge exceeds **2000 m** or confluence gaps exceed **12 m**
(the same merge threshold as `RiverLineGraph`).

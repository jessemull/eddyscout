# NHD conversion pipeline

Download USGS **National Hydrography Dataset (NHD) High Resolution** shapefiles for Portland-metro HUC regions, convert them to GeoJSON compatible with EddyScout's hydro routing loader, validate connectivity, and compare against existing OSM/Overpass geometry.

This directory is **dev-time tooling only**. Generated GeoJSON is written to `output/` for human review before any bundling into `apps/eddyscout/assets/hydro/`.

## Data provenance

| Field | Value |
|-------|-------|
| Source | USGS National Hydrography Dataset (NHD) High Resolution |
| License | Public domain (US government work) |
| Download | [The National Map staged products](https://prd-tnm.s3.amazonaws.com/StagedProducts/Hydrography/NHD/HU4/HighResolution/) |
| Layer | `NHDFlowline` |
| Citation | U.S. Geological Survey, National Hydrography Dataset High Resolution |

NHD provides higher-resolution centerlines than OSM for many US streams, including smaller tributaries and river-mile alignment. EddyScout uses NHD as a **Phase C / R1** alternative or supplement to Overpass-derived geometry (see `docs/ROADMAP.md` § Waterway routing strategy).

## HUC regions

Portland metro coverage uses two HU4 regions:

| HUC-4 | Name | Rivers (typical) |
|-------|------|------------------|
| **1709** | Willamette | Willamette main stem, Clackamas, Tualatin |
| **1708** | Lower Columbia | Columbia (Portland reach), Sandy, sloughs |

Conversion clips to the Portland metro bounding box in `config.json` (`portland_metro_bbox`).

## Output format

Each file is `output/<river_system>_waterway.geojson`:

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "river_system": "willamette",
        "reach_id": "17090001000025",
        "name": "Willamette River (NHD flowline)",
        "source": "USGS National Hydrography Dataset (NHD) High Resolution. NHDFlowline ReachCode 17090001000025."
      },
      "geometry": {
        "type": "LineString",
        "coordinates": [[-122.6580634, 45.4109061], [-122.6578973, 45.4121871]]
      }
    }
  ]
}
```

### Property mapping

| NHD field | GeoJSON property | Notes |
|-----------|------------------|-------|
| `GNIS_Name` | `name` | Appended with `(NHD flowline)` |
| `GNIS_Name` | `river_system` | Classified via `river_system_rules` in `config.json` |
| `ReachCode` / `NHDPlusID` | `reach_id` | Unique segment identifier |
| (constant) | `source` | Provenance string for reviewers |

### `river_system` values

The script emits intended system keys. The app loads bundled hydro GeoJSON via
`hydroGeoJsonLoaderProvider` (multi-file list merged in
`packages/features/hydro_routing/lib/src/data/hydro_geojson_merge.dart`).

| System | Bundled in app today? | Notes |
|--------|------------------------|-------|
| `willamette` | Yes | `assets/hydro/willamette_waterway.geojson` (OSM) |
| `columbia` | Partial | `assets/hydro/columbia_gorge_waterway.geojson` — gorge / Bonneville pool reach only (OSM) |
| `clackamas` | No | NHD output → review → separate bundling PR |
| `slough` | No | NHD output → review → separate bundling PR |
| `tualatin` | No | Future `RiverSystem` enum value may be required |
| `sandy` | No | Future `RiverSystem` enum value may be required |

NHD `convert.py` writes `output/columbia_waterway.geojson` for the full Portland-metro
Columbia reach. That is **not** the same file as bundled `columbia_gorge_waterway.geojson`.
After review, add new assets to `apps/eddyscout/assets/hydro/`, declare them in
`pubspec.yaml`, and append paths in `hydroGeoJsonLoaderProvider`
(`apps/eddyscout/lib/bootstrap/app_provider_overrides.dart`).

The Dart parser (`packages/features/hydro_routing/lib/src/data/river_geojson.dart`)
requires `properties.river_system` to match `RiverSystem.name` for routing.

`reach_id` is included for provenance; the current routing graph does not use it.

## Prerequisites

### System tools

- `curl`, `unzip`
- Python **3.10+**
- GDAL shared libraries (required by `fiona`; on macOS: `brew install gdal`)

### Python packages

```bash
cd scripts/nhd
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Usage

### All-in-one

```bash
cd scripts/nhd
python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
chmod +x run.sh download.sh
./run.sh
```

Pass `convert.py` flags after `--`:

```bash
./run.sh -- --system willamette --no-simplify
```

### 1. Download shapefiles

```bash
cd scripts/nhd
chmod +x download.sh
./download.sh
```

Downloads HU4 zips into `raw/` and extracts `NHDFlowline.shp` per region. Idempotent — skips regions already extracted.

### 2. Convert to GeoJSON

```bash
source .venv/bin/activate
python3 convert.py
```

Options:

| Flag | Description |
|------|-------------|
| `--system willamette` | Convert one river system only |
| `--no-simplify` | Skip Douglas-Peucker simplification (full NHD density) |
| `--raw-dir PATH` | Override shapefile search root |
| `--output-dir PATH` | Override output directory |

Default simplification tolerance: **5 m** (UTM EPSG:32610). Vertex merge in the app graph uses 12 m today; NHD may need 20–30 m when bundled (see ROADMAP Phase R2).

### 3. Validate connectivity

```bash
python3 validate.py
```

Builds an undirected graph using the same haversine endpoint merge as `RiverLineGraph` (threshold from `merge_vertex_threshold_meters`, default **25 m**). Reports:

- vertex and segment counts
- connected component count (tributaries may produce multiple components)
- dangling endpoints
- **near-miss gaps** — endpoints from different features within `(merge, gap_warning]` meters

Use `--strict` to exit non-zero when near-miss gaps exist.

### 4. Compare against OSM baseline

```bash
python3 compare.py \
  --baseline ../../apps/eddyscout/assets/hydro/columbia_gorge_waterway.geojson \
  --candidate output/columbia_waterway.geojson \
  --system columbia \
  --overlay-out output/columbia_compare_overlay.geojson
```

For Willamette, swap baseline to `willamette_waterway.geojson` and candidate to
`output/willamette_waterway.geojson`.

Reports feature/vertex counts, total length (km), bounding boxes, and approximate Hausdorff distance. Optional overlay GeoJSON tags features with `dataset: baseline|candidate` for QGIS inspection.

## Configuration

Edit [`config.json`](config.json):

| Key | Purpose |
|-----|---------|
| `huc_regions` | HU4 download list and URL suffixes |
| `portland_metro_bbox` | Clip filter (WGS84 degrees) |
| `river_system_rules` | Ordered GNIS name substring → `river_system` |
| `ftype_include` | NHD FType filter (460 Stream/River, 558 Artificial path) |
| `simplify_tolerance_meters` | Douglas-Peucker tolerance in meters |
| `coordinate_precision` | Decimal places for output coordinates (default 7) |
| `min_segment_length_meters` | Drop very short segments after simplify |
| `merge_vertex_threshold_meters` | Validation merge threshold |
| `connectivity_gap_warning_meters` | Report gaps between this and merge threshold |
| `utm_epsg` | UTM zone for metric simplification (32610 = UTM 10N) |

### Adding a river system

1. Add a rule to `river_system_rules` (more specific patterns first).
2. Re-run `./run.sh` or `convert.py` + `validate.py`.
3. In a separate app PR: add reviewed GeoJSON under `assets/hydro/`, update
   `pubspec.yaml`, and append the asset path in `hydroGeoJsonLoaderProvider`.
   Add `RiverSystem` enum values in `packages/core` only when the product needs
   a distinct routing graph key.

## Pipeline layout

```
scripts/nhd/
├── README.md
├── config.json
├── requirements.txt
├── run.sh               # download → convert → validate
├── download.sh          # fetch + unzip NHD HU4 shapefiles
├── convert.py           # shapefile → per-system GeoJSON
├── validate.py          # connectivity checks
├── compare.py           # diff vs OSM baseline
├── _common.py           # shared helpers
├── raw/                 # downloaded shapefiles (gitignored)
└── output/              # generated GeoJSON (gitignored)
```

Shell tests for `kill_emulator.sh` live in `scripts/test/kill_emulator_test.sh`.

## Known limitations

- **Classification** relies on `GNIS_Name`; unnamed NHD reaches are skipped.
- **Slough rule** matches any name containing `slough` (case-insensitive); review output for false positives.
- **NAD83 → WGS84** reprojection is applied; datum shift is ~1 m — negligible for routing snap thresholds.
- **Connectivity validation** mirrors client graph merge but does not auto-merge gaps; fix upstream filters or post-process manually.
- **Compare Hausdorff** is approximate (degree-based distance scaled to meters).

## Re-running

The pipeline is idempotent:

```bash
./run.sh               # or: ./download.sh && python3 convert.py && python3 validate.py
./compare.py ...       # optional
```

To force a fresh download, remove `raw/<huc4>/` or the zip under `raw/`.

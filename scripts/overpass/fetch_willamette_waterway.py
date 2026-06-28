#!/usr/bin/env python3
"""Refresh Willamette main stem from OpenStreetMap Overpass."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _overpass_common import (  # noqa: E402
    build_graph,
    extend_nearest_end_to_anchor,
    extend_toward_anchor,
    fetch_overpass,
    hydro_feature,
    parse_ways,
    path_coords,
    polyline_length_meters,
    validate_coords,
    write_waterway_file,
)

SCRIPT_NAME = "fetch_willamette_waterway.py"

SOUTH_ANCHOR = (-122.6580, 45.4109)
MOUTH_ANCHOR = (-122.7909498, 45.6178872)
WILLAMETTE_PARK = (-122.6703, 45.4492)
SPORTCRAFT_OC = (-122.6100, 45.3525)
BERNERT_LANDING = (-122.649930, 45.340081)


def main() -> None:
    parser = argparse.ArgumentParser(description="Import Willamette waterway from OSM.")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    query = """
    [out:json][timeout:90];
    (
      way["waterway"="river"]["name"~"Willamette",i](45.32,-122.85,45.63,-122.55);
    );
    out geom;
    """
    ways = parse_ways(fetch_overpass(query, script_name=SCRIPT_NAME))
    if not ways:
        raise SystemExit("Overpass returned no Willamette waterway ways.")

    graph = build_graph(ways, ref_latitude=45.5)
    coords = extend_toward_anchor(
        path_coords(
            graph,
            SOUTH_ANCHOR,
            MOUTH_ANCHOR,
            label="Willamette main stem",
        ),
        WILLAMETTE_PARK,
    )
    coords = extend_nearest_end_to_anchor(
        coords,
        SPORTCRAFT_OC,
        max_connector_m=8000.0,
    )
    coords = extend_nearest_end_to_anchor(
        coords,
        BERNERT_LANDING,
        max_connector_m=4000.0,
    )
    validate_coords("willamette_main", coords)

    feature = hydro_feature(
        river_system="willamette",
        reach_id="willamette_main",
        name="Willamette main stem (OSM waterway=river)",
        source=(
            "OpenStreetMap ODbL. Overpass merge of Willamette River ways; "
            "Oregon City pool through Columbia mouth; southern spur to "
            "Bernert Landing when OSM ends short."
        ),
        coordinates=coords,
    )
    print(
        f"Willamette: {len(coords)} points, "
        f"{polyline_length_meters(coords) / 1000:.1f} km"
    )

    if args.dry_run:
        print("Dry run — files not written.")
        return

    write_waterway_file("willamette_waterway.geojson", [feature])
    print("Wrote willamette_waterway.geojson to assets and fixtures.")


if __name__ == "__main__":
    main()

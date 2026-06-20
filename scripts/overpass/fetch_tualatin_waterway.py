#!/usr/bin/env python3
"""Fetch Tualatin River main stem (metro reach) from OpenStreetMap Overpass."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _overpass_common import (  # noqa: E402
    WayRecord,
    fetch_overpass,
    hydro_feature,
    longest_single_way_coords,
    parse_ways,
    polyline_length_meters,
    validate_coords,
    write_waterway_file,
)

SCRIPT_NAME = "fetch_tualatin_waterway.py"


def _tualatin_ways(ways: list[WayRecord]) -> list[WayRecord]:
    return [
        way
        for way in ways
        if "tualatin" in way.name.lower() and way.waterway in {"river", "stream"}
    ]


def main() -> None:
    parser = argparse.ArgumentParser(description="Import Tualatin waterway from OSM.")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    query = """
    [out:json][timeout:90];
    (
      way["waterway"="river"]["name"~"Tualatin",i](45.34,-122.95,45.46,-122.72);
    );
    out geom;
    """
    ways = _tualatin_ways(parse_ways(fetch_overpass(query, script_name=SCRIPT_NAME)))
    if not ways:
        raise SystemExit("Overpass returned no Tualatin waterway ways.")

    coords = longest_single_way_coords(ways)
    validate_coords("tualatin_main", coords)

    feature = hydro_feature(
        river_system="tualatin",
        reach_id="tualatin_main",
        name="Tualatin River main stem (OSM waterway=river)",
        source=(
            "OpenStreetMap ODbL. Longest Tualatin River way in metro bbox "
            "(no catalog launches yet)."
        ),
        coordinates=coords,
    )
    print(
        f"Tualatin: {len(coords)} points, "
        f"{polyline_length_meters(coords) / 1000:.1f} km"
    )

    if args.dry_run:
        print("Dry run — files not written.")
        return

    write_waterway_file("tualatin_waterway.geojson", [feature])
    print("Wrote tualatin_waterway.geojson to assets and fixtures.")


if __name__ == "__main__":
    main()

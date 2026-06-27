#!/usr/bin/env python3
"""Fetch Sandy River tributary geometry from OpenStreetMap Overpass."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

HYDRO_DIR = SCRIPT_DIR.parent / "hydro"
sys.path.insert(0, str(HYDRO_DIR))

from _common import haversine_meters  # noqa: E402
from _overpass_common import (  # noqa: E402
    WayRecord,
    densify_coords,
    fetch_overpass,
    hydro_feature,
    parse_ways,
    round_coords,
    validate_coords,
    write_waterway_file,
)

SCRIPT_NAME = "fetch_sandy_waterway.py"

SANDY_TAIL_WAY_ID = 128946456
COLUMBIA_JUNCTION = (-122.4017553, 45.5691143)
GLEN_OTTO = (-122.3858, 45.5365)


def _sandy_segment(ways: list[WayRecord]) -> list[list[float]]:
    sandy_way = next((way for way in ways if way.way_id == SANDY_TAIL_WAY_ID), None)
    if sandy_way is None:
        sandy_ways = [
            way
            for way in ways
            if "sandy" in way.name.lower() or "sandy" in way.waterway.lower()
        ]
        sandy_way = sandy_ways[0] if sandy_ways else None
    if sandy_way is None:
        raise RuntimeError("Overpass result missing Sandy River ways.")

    coords = sandy_way.coordinates
    start_index = min(
        range(len(coords)),
        key=lambda index: haversine_meters(
            COLUMBIA_JUNCTION[1],
            COLUMBIA_JUNCTION[0],
            coords[index][1],
            coords[index][0],
        ),
    )
    end_index = min(
        range(len(coords)),
        key=lambda index: haversine_meters(
            GLEN_OTTO[1],
            GLEN_OTTO[0],
            coords[index][1],
            coords[index][0],
        ),
    )
    if start_index <= end_index:
        segment = coords[start_index : end_index + 1]
    else:
        segment = list(reversed(coords[end_index : start_index + 1]))
    return round_coords(densify_coords([[lon, lat] for lon, lat in segment]))


def main() -> None:
    parser = argparse.ArgumentParser(description="Import Sandy River waterway from OSM.")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    query = """
    [out:json][timeout:90];
    (
      way["waterway"~"river|stream"]["name"~"Sandy",i](45.50,-122.55,45.60,-122.30);
      way(128946456);
    );
    out geom;
    """
    ways = parse_ways(fetch_overpass(query, script_name=SCRIPT_NAME))
    if not ways:
        raise SystemExit("Overpass returned no Sandy River ways.")

    coords = _sandy_segment(ways)
    validate_coords("sandy_main", coords)

    feature = hydro_feature(
        river_system="columbia",
        reach_id="sandy_main",
        name="Sandy River — Troutdale to Columbia mouth (OSM waterway=river)",
        source=(
            "OpenStreetMap ODbL. Sandy River way 128946456 subline from "
            "Columbia junction to Glenn Otto Park anchor."
        ),
        coordinates=coords,
    )
    print(f"Sandy: {len(coords)} points")

    if args.dry_run:
        print("Dry run — files not written.")
        return

    write_waterway_file("sandy_waterway.geojson", [feature])
    print("Wrote sandy_waterway.geojson to assets and fixtures.")


if __name__ == "__main__":
    main()

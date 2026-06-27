#!/usr/bin/env python3
"""Fetch Portland slough / Multnomah Channel geometry from OpenStreetMap."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _overpass_common import (  # noqa: E402
    WayRecord,
    extend_nearest_end_to_anchor,
    extend_toward_anchor,
    fetch_overpass,
    hydro_feature,
    longest_single_way_coords,
    parse_ways,
    polyline_length_meters,
    validate_coords,
    write_waterway_file,
)

SCRIPT_NAME = "fetch_slough_waterway.py"

KELLEY_POINT = (-122.7580, 45.6463)
COLUMBIA_SLOUGH_LAUNCH = (-122.615007, 45.579700)
SMITH_LAKE_LAUNCH = (-122.714018, 45.613322)


def _filter_slough_ways(ways: list[WayRecord]) -> list[WayRecord]:
    keywords = (
        "slough",
        "multnomah",
        "channel",
        "bybee",
        "peninsula",
    )
    filtered: list[WayRecord] = []
    for way in ways:
        name = way.name.lower()
        if "columbia river" in name and "slough" not in name:
            continue
        if any(keyword in name for keyword in keywords):
            filtered.append(way)
            continue
        if way.waterway in {"canal", "fairway"}:
            filtered.append(way)
    return filtered


def main() -> None:
    parser = argparse.ArgumentParser(description="Import slough waterways from OSM.")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    query = """
    [out:json][timeout:90];
    (
      way["waterway"~"river|canal|stream|fairway"](45.635,-122.78,45.665,-122.72);
    );
    out geom;
    """
    ways = _filter_slough_ways(
        parse_ways(fetch_overpass(query, script_name=SCRIPT_NAME))
    )
    if not ways:
        raise SystemExit("Overpass returned no slough waterway ways.")

    coords = extend_nearest_end_to_anchor(
        longest_single_way_coords(ways),
        KELLEY_POINT,
        max_connector_m=5000.0,
    )
    coords = extend_nearest_end_to_anchor(
        coords,
        COLUMBIA_SLOUGH_LAUNCH,
        max_connector_m=3000.0,
    )
    coords = extend_toward_anchor(
        coords,
        SMITH_LAKE_LAUNCH,
        max_connector_m=2000.0,
    )
    validate_coords("slough_main", coords)

    feature = hydro_feature(
        river_system="slough",
        reach_id="multnomah_slough",
        name="Multnomah Channel / slough network (OSM waterway)",
        source=(
            "OpenStreetMap ODbL. Multnomah Channel / Columbia Slough network; "
            "connectors to catalog pins when OSM ends short."
        ),
        coordinates=coords,
    )
    print(
        f"Slough: {len(coords)} points, "
        f"{polyline_length_meters(coords) / 1000:.1f} km"
    )

    if args.dry_run:
        print("Dry run — files not written.")
        return

    write_waterway_file("slough_waterway.geojson", [feature])
    print("Wrote slough_waterway.geojson to assets and fixtures.")


if __name__ == "__main__":
    main()

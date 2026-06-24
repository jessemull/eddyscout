#!/usr/bin/env python3
"""Fetch Clackamas River main stem from OpenStreetMap Overpass."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _overpass_common import (  # noqa: E402
    WayRecord,
    build_graph,
    extend_nearest_end_to_anchor,
    fetch_overpass,
    hydro_feature,
    longest_endpoint_path,
    parse_ways,
    polyline_length_meters,
    validate_coords,
    write_waterway_file,
)

SCRIPT_NAME = "fetch_clackamas_waterway.py"

CLACKAMETTE_PARK = (-122.6120, 45.3548)


def _clackamas_ways(ways: list[WayRecord]) -> list[WayRecord]:
    filtered = [
        way
        for way in ways
        if "clackamas" in way.name.lower() and way.waterway in {"river", "stream"}
    ]
    return filtered or ways


def main() -> None:
    parser = argparse.ArgumentParser(description="Import Clackamas waterway from OSM.")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    query = """
    [out:json][timeout:90];
    (
      way["waterway"~"river|stream"](45.26,-122.85,45.42,-122.50);
    );
    out geom;
    """
    ways = _clackamas_ways(parse_ways(fetch_overpass(query, script_name=SCRIPT_NAME)))
    if not ways:
        raise SystemExit("Overpass returned no Clackamas waterway ways.")

    graph = build_graph(ways, ref_latitude=45.33)
    coords = extend_nearest_end_to_anchor(
        longest_endpoint_path(graph),
        CLACKAMETTE_PARK,
    )
    validate_coords("clackamas_main", coords)

    feature = hydro_feature(
        river_system="clackamas",
        reach_id="clackamas_main",
        name="Clackamas River main stem (OSM waterway=river)",
        source=(
            "OpenStreetMap ODbL. Overpass merge of Clackamas waterway ways; "
            "main-stem path extended to Clackamette Park when OSM ends short."
        ),
        coordinates=coords,
    )
    print(
        f"Clackamas: {len(coords)} points, "
        f"{polyline_length_meters(coords) / 1000:.1f} km, "
        f"{graph.vertex_count} vertices"
    )

    if args.dry_run:
        print("Dry run — files not written.")
        return

    write_waterway_file("clackamas_waterway.geojson", [feature])
    print("Wrote clackamas_waterway.geojson to assets and fixtures.")


if __name__ == "__main__":
    main()

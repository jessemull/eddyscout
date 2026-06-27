#!/usr/bin/env python3
"""Extend Willamette south and import Columbia Slough centerlines from OSM."""

from __future__ import annotations

import argparse
import json
import math
import sys
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
HYRO_DIR = SCRIPT_DIR.parent / "hydro"
sys.path.insert(0, str(HYRO_DIR))

from _common import (  # noqa: E402
    bundled_hydro_dir,
    haversine_meters,
    hydro_fixture_dir,
    load_feature_collection,
    max_edge_meters,
    polyline_length_meters,
    round_coord,
    write_feature_collection,
)
from merge_index import VertexMergeIndex  # noqa: E402

# Reuse Columbia import helpers.
sys.path.insert(0, str(SCRIPT_DIR))
from fetch_columbia_waterway import (  # noqa: E402
    OsmGraph,
    WayRecord,
    _concat_polylines,
    _densify_coords,
    _fetch_overpass,
    _parse_ways,
    _round_coords,
)

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
MAX_EDGE_M = 2000.0

WILLAMETTE_SOUTH_TIP = (-122.6580634, 45.4109061)
BERNERT_LAUNCH = (-122.649930, 45.340081)
SOUTHERN_WILLAMETTE_ANCHOR = (-122.648838, 45.337402)
SLOUGH_WEST_LAUNCH = (-122.615007, 45.579700)
SLOUGH_EAST_ANCHOR = (-122.7632032, 45.6392293)
SMITH_LAKE_LAUNCH = (-122.714018, 45.613322)
COLUMBIA_SLOUGH_BRIDGE = (-122.771314, 45.6452162)


def _feature(
    *,
    river_system: str,
    reach_id: str,
    name: str,
    source: str,
    coordinates: list[list[float]],
) -> dict[str, Any]:
    return {
        "type": "Feature",
        "properties": {
            "river_system": river_system,
            "reach_id": reach_id,
            "name": name,
            "source": source,
        },
        "geometry": {
            "type": "LineString",
            "coordinates": coordinates,
        },
    }


def _validate_coords(label: str, coords: list[list[float]]) -> None:
    longest = max_edge_meters(coords)
    if longest > MAX_EDGE_M:
        raise RuntimeError(
            f"{label}: longest edge {longest:.1f} m exceeds {MAX_EDGE_M:.0f} m."
        )


def _load_existing_willamette(path: Path) -> list[list[float]]:
    collection = load_feature_collection(path)
    features = collection.get("features") or []
    if not features:
        raise RuntimeError(f"No features in {path}")
    return [point[:] for point in features[0]["geometry"]["coordinates"]]


def _path_coords(
    graph: OsmGraph,
    start_lonlat: tuple[float, float],
    end_lonlat: tuple[float, float],
) -> list[list[float]]:
    start = graph.find_or_add(start_lonlat[0], start_lonlat[1])
    goal = graph.find_or_add(end_lonlat[0], end_lonlat[1])
    path = graph.shortest_path(start, goal)
    if path is None:
        raise RuntimeError(
            f"No OSM path from {start_lonlat} to {end_lonlat}."
        )
    return graph.path_to_coords(path)


def _nearest_waypoint(
    ways: list[WayRecord],
    lonlat: tuple[float, float],
    *,
    max_m: float = 900,
) -> tuple[float, float]:
    best = lonlat
    best_d = float("inf")
    for way in ways:
        for lon, lat in way.coordinates:
            distance = haversine_meters(lonlat[1], lonlat[0], lat, lon)
            if distance < best_d:
                best_d = distance
                best = (lon, lat)
    if best_d > max_m:
        raise RuntimeError(
            f"No way point within {max_m:.0f} m of {lonlat} (nearest {best_d:.0f} m)."
        )
    return best


def _build_willamette_extension(
    ways: list[WayRecord],
    existing_south_tip: tuple[float, float],
) -> list[list[float]]:
    graph = OsmGraph(ref_latitude=45.37)
    for way in ways:
        graph.add_way(way.coordinates)
    south = _nearest_waypoint(ways, SOUTHERN_WILLAMETTE_ANCHOR)
    north = _nearest_waypoint(ways, existing_south_tip)
    if haversine_meters(south[1], south[0], north[1], north[0]) <= 100.0:
        return []
    segment = _path_coords(graph, south, north)
    return _round_coords(_densify_coords(segment))


def _build_slough_coords(ways: list[WayRecord]) -> list[list[float]]:
    graph = OsmGraph(ref_latitude=45.58)
    for way in ways:
        graph.add_way(way.coordinates)
    west = _nearest_waypoint(ways, SLOUGH_WEST_LAUNCH)
    east = _nearest_waypoint(ways, SLOUGH_EAST_ANCHOR)
    smith = _nearest_waypoint(ways, SMITH_LAKE_LAUNCH, max_m=2000)
    main = _path_coords(graph, west, east)
    spur = _path_coords(graph, east, smith)
    segment = _concat_polylines(main, spur)
    rounded = _round_coords(_densify_coords(segment))
    return _append_smith_launch_spur(rounded)


def _append_smith_launch_spur(coords: list[list[float]]) -> list[list[float]]:
    """Append catalog Smith Lake coords when OSM ends short of the ramp."""
    lon, lat = SMITH_LAKE_LAUNCH
    best_d = min(
        haversine_meters(lat, lon, point[1], point[0]) for point in coords
    )
    if best_d <= 900:
        return coords
    end = coords[-1]
    spur = haversine_meters(end[1], end[0], lat, lon)
    if spur > MAX_EDGE_M:
        raise RuntimeError(
            f"Smith Lake spur is {spur:.0f} m; max {MAX_EDGE_M:.0f} m."
        )
    return coords + [[round_coord(lon), round_coord(lat)]]


def _merge_willamette(
    extension: list[list[float]],
    existing: list[list[float]],
) -> list[list[float]]:
    merged = _concat_polylines(extension, existing)
    gap = haversine_meters(
        extension[-1][1],
        extension[-1][0],
        existing[0][1],
        existing[0][0],
    )
    if gap > 100.0:
        raise RuntimeError(
            f"Willamette extension join gap {gap:.1f} m exceeds 100 m."
        )
    return merged


def _write_outputs(
    willamette: list[list[float]],
    slough: list[list[float]],
    asset_dir: Path,
    fixture_dir: Path,
) -> None:
    willamette_feature = _feature(
        river_system="willamette",
        reach_id="willamette_main",
        name="Willamette main stem (OSM waterway=river)",
        source=(
            "OpenStreetMap ODbL. Southern extension (Bernert to Lake Oswego) "
            "merged with existing main stem to St. Johns."
        ),
        coordinates=willamette,
    )
    slough_feature = _feature(
        river_system="slough",
        reach_id="columbia_slough",
        name="Columbia Slough (OSM waterway=stream)",
        source=(
            "OpenStreetMap ODbL. Columbia Slough plus North Portland Harbor spur "
            "to Smith & Bybee canoe ramp."
        ),
        coordinates=slough,
    )
    for directory in (asset_dir, fixture_dir):
        write_feature_collection(
            directory / "willamette_waterway.geojson",
            [willamette_feature],
        )
        write_feature_collection(
            directory / "slough_waterway.geojson",
            [slough_feature],
        )


def _update_confluence_bridges(asset_dir: Path) -> None:
    bridges_path = asset_dir / "confluence_bridges.json"
    with bridges_path.open(encoding="utf-8") as handle:
        bridges = json.load(handle)
    bridges = [
        bridge
        for bridge in bridges
        if bridge.get("id") != "columbia_slough_columbia_pool"
    ]
    bridges.append(
        {
            "id": "columbia_slough_columbia_pool",
            "a": {
                "lat": SLOUGH_EAST_ANCHOR[1],
                "lon": SLOUGH_EAST_ANCHOR[0],
            },
            "b": {
                "lat": COLUMBIA_SLOUGH_BRIDGE[1],
                "lon": COLUMBIA_SLOUGH_BRIDGE[0],
            },
        }
    )
    with bridges_path.open("w", encoding="utf-8") as handle:
        json.dump(bridges, handle, indent=2)
        handle.write("\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Extend Willamette south and import Columbia Slough from OSM.",
    )
    parser.add_argument(
        "--willamette-path",
        type=Path,
        default=bundled_hydro_dir() / "willamette_waterway.geojson",
    )
    parser.add_argument(
        "--asset-dir",
        type=Path,
        default=bundled_hydro_dir(),
    )
    parser.add_argument(
        "--fixture-dir",
        type=Path,
        default=hydro_fixture_dir(),
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Fetch and validate without writing GeoJSON files.",
    )
    args = parser.parse_args()

    existing = _load_existing_willamette(args.willamette_path)
    existing_south = (existing[0][0], existing[0][1])
    print(f"Existing Willamette: {len(existing)} points")

    will_query = """
    [out:json][timeout:90];
    (
      way["waterway"="river"]["name"~"Willamette",i](45.30,-122.80,45.45,-122.55);
    );
    out geom;
    """
    will_ways = _parse_ways(_fetch_overpass(will_query))
    if not will_ways:
        parser.error("Overpass returned no Willamette ways.")

    extension = _build_willamette_extension(will_ways, existing_south)
    if extension:
        willamette = _merge_willamette(extension, existing)
    else:
        willamette = existing
        print("Willamette southern extension already present — skipping merge.")
    _validate_coords("willamette", willamette)
    print(
        f"Willamette: {len(willamette)} points, "
        f"{polyline_length_meters(willamette)/1000:.1f} km "
        f"(+{len(extension)} southern points)"
    )

    slough_query = """
    [out:json][timeout:90];
    (
      way["waterway"~"river|stream|canal|fairway"](45.54,-122.80,45.67,-122.54);
    );
    out geom;
    """
    slough_ways = _parse_ways(_fetch_overpass(slough_query))
    if not slough_ways:
        parser.error("Overpass returned no Columbia Slough ways.")

    slough = _build_slough_coords(slough_ways)
    _validate_coords("slough", slough)
    print(
        f"Slough: {len(slough)} points, "
        f"{polyline_length_meters(slough)/1000:.1f} km"
    )

    if args.dry_run:
        print("Dry run — files not written.")
        return

    _write_outputs(willamette, slough, args.asset_dir, args.fixture_dir)
    _update_confluence_bridges(args.asset_dir)
    print(f"Wrote {args.asset_dir} and {args.fixture_dir}")


if __name__ == "__main__":
    main()

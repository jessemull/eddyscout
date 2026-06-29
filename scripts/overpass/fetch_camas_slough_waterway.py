#!/usr/bin/env python3
"""Fetch Camas Slough spur geometry and merge into columbia_lower bundle."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
HYRO_DIR = SCRIPT_DIR.parent / "hydro"
sys.path.insert(0, str(HYRO_DIR))
sys.path.insert(0, str(SCRIPT_DIR))

from _common import (  # noqa: E402
    assert_launch_snap_within,
    bundled_hydro_dir,
    haversine_meters,
    hydro_fixture_dir,
    launch_anchor_lonlat,
    load_feature_collection,
    nearest_point_on_polyline,
    polyline_length_meters,
    prune_backtrack_loops,
    spur_feature,
    write_feature_collection,
)
from _overpass_common import (  # noqa: E402
    MERGE_VERTEX_M,
    WayRecord,
    build_graph,
    concat_polylines,
    densify_coords,
    extend_toward_anchor,
    fetch_overpass,
    parse_ways,
    round_coords,
    validate_coords,
)

SCRIPT_NAME = "fetch_camas_slough_waterway.py"

CAMAS_SLOUGH_WAY_ID = 130204446
CAMAS_SLOUGH_BBOX = (45.55, -122.46, 45.60, -122.37)
CAMAS_SPLIT = (-122.4300244, 45.5659948)
MARINA_CONNECTOR_MAX_M = 3000.0
SLOUGH_SPUR_REACH_ID = "camas_slough_spur"


def _fetch_local_ways() -> list[WayRecord]:
    south, west, north, east = CAMAS_SLOUGH_BBOX
    query = f"""
    [out:json][timeout:90];
    (
      way({CAMAS_SLOUGH_WAY_ID});
      way["waterway"~"river|canal|fairway|stream"]({south},{west},{north},{east});
    );
    out geom;
    """
    ways = parse_ways(fetch_overpass(query, script_name=SCRIPT_NAME))
    if not ways:
        raise RuntimeError(
            f"Overpass returned no Camas Slough ways (expected {CAMAS_SLOUGH_WAY_ID})."
        )
    return ways


def _select_slough_way(ways: list[WayRecord]) -> WayRecord:
    preferred = next(
        (way for way in ways if way.way_id == CAMAS_SLOUGH_WAY_ID),
        None,
    )
    if preferred is not None:
        return preferred
    named = [way for way in ways if "camas" in way.name.lower()]
    if len(named) == 1:
        return named[0]
    raise RuntimeError(
        f"Camas Slough way {CAMAS_SLOUGH_WAY_ID} missing; "
        f"found {len(ways)} fallback ways."
    )


def _mainstem_coords(collection: dict[str, Any]) -> list[list[float]]:
    features = collection.get("features") or []
    if not features:
        raise RuntimeError("columbia_lower_waterway.geojson has no features.")
    geometry = features[0].get("geometry") or {}
    coords = geometry.get("coordinates") or []
    if len(coords) < 2:
        raise RuntimeError("columbia_lower mainstem must have at least two points.")
    return [[float(lon), float(lat)] for lon, lat in coords]


def _build_spur_coords(
    slough_way: WayRecord,
    ways: list[WayRecord],
    mainstem_coords: list[list[float]],
) -> list[list[float]]:
    graph = build_graph(ways, ref_latitude=45.58)
    slough_coords = [[lon, lat] for lon, lat in slough_way.coordinates]
    slough_end = slough_coords[-1]

    start_vertex = graph.find_or_add(CAMAS_SPLIT[0], CAMAS_SPLIT[1])
    goal_vertex = graph.find_or_add(slough_end[0], slough_end[1])
    path = graph.shortest_path(start_vertex, goal_vertex)
    if path is None:
        raise RuntimeError(
            "No OSM path from Camas split to Camas Slough west end."
        )

    connector = graph.path_to_coords(path)
    junction_gap = haversine_meters(
        CAMAS_SPLIT[1],
        CAMAS_SPLIT[0],
        connector[0][1],
        connector[0][0],
    )
    if junction_gap > MERGE_VERTEX_M:
        raise RuntimeError(
            f"Camas Slough connector start is {junction_gap:.1f} m from "
            f"Columbia mainstem; expected within {MERGE_VERTEX_M:.0f} m."
        )

    _, _, _, _, mainstem_gap = nearest_point_on_polyline(
        connector[0][0],
        connector[0][1],
        mainstem_coords,
    )
    if mainstem_gap > MERGE_VERTEX_M:
        raise RuntimeError(
            f"Camas Slough connector start is {mainstem_gap:.1f} m from bundled "
            f"mainstem geometry; expected within {MERGE_VERTEX_M:.0f} m."
        )

    slough_body = list(reversed(slough_coords))
    merged = prune_backtrack_loops(concat_polylines(connector, slough_body))
    marina = launch_anchor_lonlat("port_of_camas")
    merged = extend_toward_anchor(
        merged,
        marina,
        max_connector_m=MARINA_CONNECTOR_MAX_M,
    )
    assert_launch_snap_within(
        merged,
        "port_of_camas",
        context="Camas Slough spur",
    )
    return merged


def _build_slough_feature(mainstem_coords: list[list[float]]) -> dict[str, Any]:
    ways = _fetch_local_ways()
    slough_way = _select_slough_way(ways)
    connected = _build_spur_coords(slough_way, ways, mainstem_coords)
    rounded = round_coords(densify_coords(connected))
    validate_coords("camas_slough_spur", rounded)

    marina_gap = assert_launch_snap_within(
        rounded,
        "port_of_camas",
        context="Camas Slough spur",
    )

    print(
        f"Camas Slough way {slough_way.way_id} ({slough_way.name or 'unnamed'}): "
        f"{len(rounded)} points, {polyline_length_meters(rounded)/1000:.2f} km, "
        f"marina gap {marina_gap:.1f} m"
    )

    return spur_feature(
        reach_id=SLOUGH_SPUR_REACH_ID,
        name="Camas Slough — Port of Camas marina spur (OSM)",
        source=(
            f"OpenStreetMap ODbL. Way {slough_way.way_id} "
            f"({slough_way.name or 'Camas Slough'}) plus local OSM connector to "
            "columbia_lower mainstem at Camas split; densified extension to "
            "Port of Camas catalog launch anchor."
        ),
        coordinates=rounded,
    )


def _write_lower_with_spur(
    collection: dict[str, Any],
    spur: dict[str, Any],
    asset_dir: Path,
    fixture_dir: Path,
) -> None:
    features = collection.get("features") or []
    if not features:
        raise RuntimeError("columbia_lower_waterway.geojson has no mainstem feature.")
    preserved = [
        feature
        for feature in features
        if (feature.get("properties") or {}).get("reach_id") != SLOUGH_SPUR_REACH_ID
    ]
    merged = [*preserved, spur]
    for directory in (asset_dir, fixture_dir):
        write_feature_collection(
            directory / "columbia_lower_waterway.geojson",
            merged,
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Import Camas Slough spur into columbia_lower bundle.",
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

    lower_path = args.asset_dir / "columbia_lower_waterway.geojson"
    if not lower_path.exists():
        parser.error(
            f"Missing {lower_path}; run fetch_columbia_waterway.py first."
        )

    collection = load_feature_collection(lower_path)
    mainstem_coords = _mainstem_coords(collection)
    spur = _build_slough_feature(mainstem_coords)

    if args.dry_run:
        print("Dry run — files not written.")
        return

    _write_lower_with_spur(collection, spur, args.asset_dir, args.fixture_dir)
    print(f"Wrote Camas Slough spur to {args.asset_dir} and {args.fixture_dir}")


if __name__ == "__main__":
    main()

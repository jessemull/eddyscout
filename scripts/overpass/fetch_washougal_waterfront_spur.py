#!/usr/bin/env python3
"""Fetch Washougal Waterfront spur and merge into columbia_lower bundle."""

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
    polyline_length_meters,
    prune_backtrack_loops,
    spur_feature,
    write_feature_collection,
)
from _overpass_common import (  # noqa: E402
    densify_coords,
    extend_toward_anchor,
    round_coords,
    validate_coords,
)

SCRIPT_NAME = "fetch_washougal_waterfront_spur.py"

CAMAS_SLOUGH_SPUR_REACH_ID = "camas_slough_spur"
MARINA_CONNECTOR_MAX_M = 1500.0
SPUR_REACH_ID = "washougal_waterfront_spur"


def _feature_coords(collection: dict[str, Any], reach_id: str) -> list[list[float]]:
    for feature in collection.get("features") or []:
        props = feature.get("properties") or {}
        if props.get("reach_id") != reach_id:
            continue
        geometry = feature.get("geometry") or {}
        coords = geometry.get("coordinates") or []
        return [[float(lon), float(lat)] for lon, lat in coords]
    raise RuntimeError(
        f"Missing {reach_id} in columbia_lower bundle; run fetch_camas_slough first."
    )


def _nearest_polyline_point(
    coords: list[list[float]],
    anchor: tuple[float, float],
) -> tuple[list[float], float]:
    best_point = coords[0][:2]
    best_gap = float("inf")
    for point in coords:
        gap = haversine_meters(
            anchor[1],
            anchor[0],
            point[1],
            point[0],
        )
        if gap < best_gap:
            best_gap = gap
            best_point = point[:2]
    return best_point, best_gap


def _build_spur_coords(slough_coords: list[list[float]]) -> list[list[float]]:
    anchor = launch_anchor_lonlat("washougal_waterfront")
    branch, branch_gap = _nearest_polyline_point(slough_coords, anchor)
    if branch_gap > MARINA_CONNECTOR_MAX_M:
        raise RuntimeError(
            f"Nearest Camas Slough spur point is {branch_gap:.1f} m from "
            f"Washougal Waterfront; expected within {MARINA_CONNECTOR_MAX_M:.0f} m."
        )

    merged = prune_backtrack_loops(
        densify_coords(
            [
                [branch[0], branch[1]],
                [anchor[0], anchor[1]],
            ],
        ),
    )
    merged = extend_toward_anchor(
        merged,
        anchor,
        max_connector_m=MARINA_CONNECTOR_MAX_M,
    )
    assert_launch_snap_within(
        merged,
        "washougal_waterfront",
        context="Washougal Waterfront spur",
    )
    return merged


def _build_spur_feature(collection: dict[str, Any]) -> dict[str, Any]:
    slough_coords = _feature_coords(collection, CAMAS_SLOUGH_SPUR_REACH_ID)
    connected = _build_spur_coords(slough_coords)
    rounded = round_coords(densify_coords(connected))
    validate_coords("washougal_waterfront_spur", rounded)

    gap = assert_launch_snap_within(
        rounded,
        "washougal_waterfront",
        context="Washougal Waterfront spur",
    )

    print(
        f"Washougal Waterfront spur from {CAMAS_SLOUGH_SPUR_REACH_ID}: "
        f"{len(rounded)} points, {polyline_length_meters(rounded)/1000:.2f} km, "
        f"launch gap {gap:.1f} m"
    )

    return spur_feature(
        reach_id=SPUR_REACH_ID,
        name="Washougal River — Waterfront Park spur",
        source=(
            "Side spur branching from camas_slough_spur toward Washougal "
            "Waterfront catalog launch anchor; not inlined into Columbia mainstem."
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
        if (feature.get("properties") or {}).get("reach_id") != SPUR_REACH_ID
    ]
    merged = [*preserved, spur]
    for directory in (asset_dir, fixture_dir):
        write_feature_collection(
            directory / "columbia_lower_waterway.geojson",
            merged,
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Import Washougal Waterfront spur into columbia_lower bundle.",
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
    spur = _build_spur_feature(collection)

    if args.dry_run:
        print("Dry run — files not written.")
        return

    _write_lower_with_spur(collection, spur, args.asset_dir, args.fixture_dir)
    print(
        f"Wrote Washougal Waterfront spur to {args.asset_dir} and {args.fixture_dir}"
    )


if __name__ == "__main__":
    main()

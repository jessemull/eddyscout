#!/usr/bin/env python3
"""Extend bundled hydro spurs for catalog launch snap gaps (no Overpass)."""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
OVERPASS_DIR = SCRIPT_DIR.parent / "overpass"
sys.path.insert(0, str(SCRIPT_DIR))
sys.path.insert(0, str(OVERPASS_DIR))

from _common import (  # noqa: E402
    bundled_hydro_dir,
    haversine_meters,
    hydro_fixture_dir,
    load_feature_collection,
    spur_feature,
    write_feature_collection,
)
from _overpass_common import (  # noqa: E402
    densify_coords,
    extend_toward_anchor,
    round_coords,
    validate_coords,
)

CATALOG_SNAP_MAX_M = 200.0

PORT_OF_CAMAS = (-122.380485, 45.578770)
SCAPPOOSE_MARINA = (-122.839828, 45.828824)
WASHOUGAL_WATERFRONT = (-122.377814, 45.578087)

SLOUGH_SPUR_REACH_ID = "camas_slough_spur"
SCAPPOOSE_MARINA_SPUR_ID = "scappoose_marina_spur"
WASHOUGAL_SPUR_ID = "washougal_waterfront_spur"


def _feature_by_reach(
    features: list[dict[str, Any]],
    reach_id: str,
) -> dict[str, Any] | None:
    for feature in features:
        props = feature.get("properties") or {}
        if props.get("reach_id") == reach_id:
            return feature
    return None


def _coords(feature: dict[str, Any]) -> list[list[float]]:
    geometry = feature.get("geometry") or {}
    return [[float(lon), float(lat)] for lon, lat in geometry.get("coordinates") or []]


def _set_coords(feature: dict[str, Any], coords: list[list[float]]) -> None:
    feature["geometry"] = {"type": "LineString", "coordinates": coords}


def _min_gap_to_anchor(
    coords: list[list[float]],
    anchor: tuple[float, float],
) -> float:
    return min(
        haversine_meters(anchor[1], anchor[0], lat, lon) for lon, lat in coords
    )


def _extend_feature_toward(
    feature: dict[str, Any],
    anchor: tuple[float, float],
    *,
    max_connector_m: float,
    label: str,
) -> None:
    coords = _coords(feature)
    extended = round_coords(
        extend_toward_anchor(
            coords,
            anchor,
            max_connector_m=max_connector_m,
        ),
    )
    validate_coords(label, extended)
    gap = _min_gap_to_anchor(extended, anchor)
    if gap > CATALOG_SNAP_MAX_M:
        raise RuntimeError(
            f"{label} is still {gap:.1f} m from anchor after extension "
            f"(max {CATALOG_SNAP_MAX_M:.0f} m)."
        )
    _set_coords(feature, extended)
    print(f"{label}: marina gap {gap:.1f} m ({len(extended)} points)")


def _nearest_point_on_polyline(
    coords: list[list[float]],
    anchor: tuple[float, float],
) -> tuple[list[float], float]:
    best_point = coords[0]
    best_gap = float("inf")
    for lon, lat in coords:
        gap = haversine_meters(anchor[1], anchor[0], lat, lon)
        if gap < best_gap:
            best_gap = gap
            best_point = [lon, lat]
    return best_point, best_gap


def _build_side_spur(
    base_coords: list[list[float]],
    anchor: tuple[float, float],
    *,
    max_connector_m: float,
    label: str,
) -> list[list[float]]:
    join, join_gap = _nearest_point_on_polyline(base_coords, anchor)
    if join_gap > max_connector_m:
        raise RuntimeError(
            f"{label}: nearest base point is {join_gap:.1f} m from anchor "
            f"(max connector {max_connector_m:.0f} m)."
        )
    spur = round_coords(
        densify_coords(
            [
                [join[0], join[1]],
                [anchor[0], anchor[1]],
            ],
        ),
    )
    validate_coords(label, spur)
    gap = _min_gap_to_anchor(spur, anchor)
    if gap > CATALOG_SNAP_MAX_M:
        raise RuntimeError(
            f"{label} spur gap {gap:.1f} m exceeds {CATALOG_SNAP_MAX_M:.0f} m."
        )
    print(f"{label}: marina gap {gap:.1f} m ({len(spur)} points)")
    return spur


def patch_lower(asset_dir: Path) -> None:
    path = asset_dir / "columbia_lower_waterway.geojson"
    collection = load_feature_collection(path)
    features: list[dict[str, Any]] = list(collection.get("features") or [])

    slough = _feature_by_reach(features, SLOUGH_SPUR_REACH_ID)
    if slough is None:
        raise RuntimeError(f"Missing {SLOUGH_SPUR_REACH_ID} in {path}")
    _extend_feature_toward(
        slough,
        PORT_OF_CAMAS,
        max_connector_m=2500.0,
        label=SLOUGH_SPUR_REACH_ID,
    )

    features = [
        feature
        for feature in features
        if (feature.get("properties") or {}).get("reach_id")
        != SCAPPOOSE_MARINA_SPUR_ID
    ]
    north_pool = _feature_by_reach(features, "columbia_lower_pool_north")
    multnomah = _feature_by_reach(features, "multnomah_channel_scappoose")
    if north_pool is None or multnomah is None:
        raise RuntimeError("Missing north pool or Multnomah channel feature.")
    scappoose_base = _coords(north_pool) + _coords(multnomah)
    scappoose_spur = spur_feature(
        reach_id=SCAPPOOSE_MARINA_SPUR_ID,
        name="Scappoose Bay Marina launch spur",
        source=(
            "Curated connector from columbia_lower_pool_north geometry to "
            "Scappoose Bay Marina catalog water-entry anchor."
        ),
        coordinates=_build_side_spur(
            scappoose_base,
            SCAPPOOSE_MARINA,
            max_connector_m=12000.0,
            label=SCAPPOOSE_MARINA_SPUR_ID,
        ),
    )
    features.append(scappoose_spur)

    for directory in (asset_dir, hydro_fixture_dir()):
        write_feature_collection(directory / path.name, features)


def patch_gorge(asset_dir: Path) -> None:
    path = asset_dir / "columbia_gorge_waterway.geojson"
    collection = load_feature_collection(path)
    features: list[dict[str, Any]] = list(collection.get("features") or [])

    features = [
        feature
        for feature in features
        if (feature.get("properties") or {}).get("reach_id") != WASHOUGAL_SPUR_ID
    ]
    gorge = _feature_by_reach(features, "columbia_gorge")
    if gorge is None:
        raise RuntimeError("Missing columbia_gorge feature.")
    washougal_spur = spur_feature(
        reach_id=WASHOUGAL_SPUR_ID,
        name="Washougal Waterfront Park launch spur",
        source=(
            "Curated connector from Columbia gorge mainstem to Washougal "
            "Waterfront Park catalog water-entry anchor."
        ),
        coordinates=_build_side_spur(
            _coords(gorge),
            WASHOUGAL_WATERFRONT,
            max_connector_m=2500.0,
            label=WASHOUGAL_SPUR_ID,
        ),
    )
    features.append(washougal_spur)

    for directory in (asset_dir, hydro_fixture_dir()):
        write_feature_collection(directory / path.name, features)


def main() -> None:
    asset_dir = bundled_hydro_dir()
    patch_lower(asset_dir)
    patch_gorge(asset_dir)
    print(f"Patched launch spurs in {asset_dir} and fixtures.")


if __name__ == "__main__":
    main()

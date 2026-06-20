"""Shared helpers for bundled hydro asset tooling."""

from __future__ import annotations

import json
import math
from collections.abc import Iterable, Mapping, Sequence
from pathlib import Path
from typing import Any

EARTH_RADIUS_M = 6371000.0


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def bundled_hydro_dir() -> Path:
    return repo_root() / "apps/eddyscout/assets/hydro"


def hydro_fixture_dir() -> Path:
    return repo_root() / "packages/features/hydro_routing/test/fixtures"


def haversine_meters(
    lat1_deg: float,
    lon1_deg: float,
    lat2_deg: float,
    lon2_deg: float,
) -> float:
    lat1 = math.radians(lat1_deg)
    lat2 = math.radians(lat2_deg)
    d_lat = math.radians(lat2_deg - lat1_deg)
    d_lon = math.radians(lon2_deg - lon1_deg)
    a = (
        math.sin(d_lat / 2) ** 2
        + math.cos(lat1) * math.cos(lat2) * math.sin(d_lon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return EARTH_RADIUS_M * c


def round_coord(value: float, precision: int = 7) -> float:
    return round(value, precision)


def load_feature_collection(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as handle:
        root = json.load(handle)
    if root.get("type") != "FeatureCollection":
        raise ValueError(f"Expected FeatureCollection in {path}")
    return root


def write_feature_collection(path: Path, features: Iterable[dict[str, Any]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {"type": "FeatureCollection", "features": list(features)}
    with path.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)
        handle.write("\n")


def iter_linestrings(geometry: Mapping[str, Any]) -> Iterable[list[list[float]]]:
    geom_type = geometry.get("type")
    coords = geometry.get("coordinates")
    if geom_type == "LineString" and isinstance(coords, list) and len(coords) >= 2:
        yield coords
        return
    if geom_type == "MultiLineString" and isinstance(coords, list):
        for part in coords:
            if isinstance(part, list) and len(part) >= 2:
                yield part


def polyline_length_meters(coords: Sequence[Sequence[float]]) -> float:
    total = 0.0
    for index in range(len(coords) - 1):
        lon1, lat1 = coords[index][:2]
        lon2, lat2 = coords[index + 1][:2]
        total += haversine_meters(lat1, lon1, lat2, lon2)
    return total


def max_edge_meters(coords: Sequence[Sequence[float]]) -> float:
    if len(coords) < 2:
        return 0.0
    return max(
        haversine_meters(
            coords[index][1],
            coords[index][0],
            coords[index + 1][1],
            coords[index + 1][0],
        )
        for index in range(len(coords) - 1)
    )


def line_endpoints(
    collection: Mapping[str, Any],
) -> tuple[tuple[float, float], tuple[float, float]] | None:
    features = collection.get("features") or []
    if not features:
        return None
    geometry = features[0].get("geometry") or {}
    lines = list(iter_linestrings(geometry))
    if not lines:
        return None
    ring = lines[0]
    start = (float(ring[0][0]), float(ring[0][1]))
    end = (float(ring[-1][0]), float(ring[-1][1]))
    return start, end

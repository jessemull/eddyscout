"""Shared helpers for the NHD conversion pipeline."""

from __future__ import annotations

import json
import math
from collections.abc import Iterable, Iterator, Mapping, Sequence
from pathlib import Path
from typing import Any

EARTH_RADIUS_M = 6371000.0


def load_config(config_path: Path) -> dict[str, Any]:
    with config_path.open(encoding="utf-8") as handle:
        return json.load(handle)


def script_dir() -> Path:
    return Path(__file__).resolve().parent


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


def round_coord(value: float, precision: int) -> float:
    return round(value, precision)


def property_lookup(props: Mapping[str, Any], *names: str) -> Any | None:
    lowered = {str(key).lower(): value for key, value in props.items()}
    for name in names:
        if name.lower() in lowered:
            return lowered[name.lower()]
    return None


def classify_river_system(
    gnis_name: str | None,
    rules: Sequence[Mapping[str, Any]],
) -> str | None:
    if not gnis_name:
        return None
    for rule in rules:
        pattern = str(rule["pattern"])
        case_insensitive = bool(rule.get("case_insensitive", True))
        haystack = gnis_name if not case_insensitive else gnis_name.lower()
        needle = pattern if not case_insensitive else pattern.lower()
        if needle in haystack:
            return str(rule["system"])
    return None


def iter_linestrings(geometry: Mapping[str, Any]) -> Iterator[list[list[float]]]:
    geom_type = geometry.get("type")
    coords = geometry.get("coordinates")
    if geom_type == "LineString" and isinstance(coords, list):
        if len(coords) >= 2:
            yield coords
        return
    if geom_type == "MultiLineString" and isinstance(coords, list):
        for part in coords:
            if isinstance(part, list) and len(part) >= 2:
                yield part


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


def polyline_length_meters(coords: Sequence[Sequence[float]]) -> float:
    total = 0.0
    for index in range(len(coords) - 1):
        lon1, lat1 = coords[index][:2]
        lon2, lat2 = coords[index + 1][:2]
        total += haversine_meters(lat1, lon1, lat2, lon2)
    return total


def bbox_from_coords(all_coords: Iterable[Sequence[float]]) -> tuple[float, float, float, float]:
    min_lon = min_lat = float("inf")
    max_lon = max_lat = float("-inf")
    for lon, lat in all_coords:
        min_lon = min(min_lon, lon)
        min_lat = min(min_lat, lat)
        max_lon = max(max_lon, lon)
        max_lat = max(max_lat, lat)
    return min_lon, min_lat, max_lon, max_lat


def find_nhd_flowline_shapefiles(raw_dir: Path) -> list[Path]:
    return sorted(raw_dir.glob("**/NHDFlowline.shp"))

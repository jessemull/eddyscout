"""Shared helpers for bundled hydro asset tooling."""

from __future__ import annotations

import json
import math
from collections.abc import Iterable, Mapping, Sequence
from pathlib import Path
from typing import Any

EARTH_RADIUS_M = 6371000.0

ROUTE_SNAP_MAX_M = 900.0

_LAUNCH_ANCHORS_PATH = Path(__file__).resolve().parent / "launch_anchors.json"


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


DEFAULT_MERGE_M = 12.0


def _coords_within_meters(
    left: Sequence[float],
    right: Sequence[float],
    merge_meters: float,
) -> bool:
    return (
        haversine_meters(left[1], left[0], right[1], right[0]) <= merge_meters
    )


def prune_backtrack_loops(
    coords: Sequence[Sequence[float]],
    merge_meters: float = DEFAULT_MERGE_M,
) -> list[list[float]]:
    """Remove duplicate vertices and simple backtrack detours along a polyline."""
    if len(coords) < 2:
        return [list(point[:2]) for point in coords]

    out: list[list[float]] = [list(coords[0][:2])]
    for point_raw in coords[1:]:
        point = list(point_raw[:2])
        if _coords_within_meters(out[-1], point, merge_meters):
            continue

        loop_start: int | None = None
        for index in range(len(out) - 1):
            if _coords_within_meters(out[index], point, merge_meters):
                loop_start = index
                break

        if loop_start is not None:
            out = out[: loop_start + 1]
            if not _coords_within_meters(out[-1], point, merge_meters):
                out.append(point)
            continue

        out.append(point)
    return out


def nearest_point_on_polyline(
    lon: float,
    lat: float,
    coords: Sequence[Sequence[float]],
) -> tuple[int, float, float, float, float]:
    """Return segment index, along-segment fraction, lon, lat, and distance in meters."""
    if len(coords) < 2:
        raise ValueError("Polyline must have at least two coordinates.")

    best_index = 0
    best_fraction = 0.0
    best_lon = float(coords[0][0])
    best_lat = float(coords[0][1])
    best_distance = haversine_meters(lat, lon, best_lat, best_lon)

    for index in range(len(coords) - 1):
        lon1, lat1 = float(coords[index][0]), float(coords[index][1])
        lon2, lat2 = float(coords[index + 1][0]), float(coords[index + 1][1])
        segment_m = haversine_meters(lat1, lon1, lat2, lon2)
        if segment_m <= 0.0:
            continue

        # Project query point onto segment in local equirectangular space.
        mean_lat = math.radians((lat1 + lat2) / 2.0)
        x1 = math.radians(lon1) * math.cos(mean_lat)
        y1 = math.radians(lat1)
        x2 = math.radians(lon2) * math.cos(mean_lat)
        y2 = math.radians(lat2)
        xq = math.radians(lon) * math.cos(mean_lat)
        yq = math.radians(lat)

        dx = x2 - x1
        dy = y2 - y1
        denom = dx * dx + dy * dy
        fraction = 0.0 if denom <= 0.0 else (xq - x1) * dx / denom + (yq - y1) * dy / denom
        fraction = min(1.0, max(0.0, fraction))

        proj_lon = math.degrees(
            (x1 + fraction * dx) / math.cos(mean_lat),
        )
        proj_lat = math.degrees(y1 + fraction * dy)
        distance = haversine_meters(lat, lon, proj_lat, proj_lon)
        if distance < best_distance:
            best_index = index
            best_fraction = fraction
            best_lon = proj_lon
            best_lat = proj_lat
            best_distance = distance

    return best_index, best_fraction, best_lon, best_lat, best_distance


def spur_feature(
    *,
    reach_id: str,
    name: str,
    source: str,
    coordinates: list[list[float]],
    river_system: str = "columbia",
) -> dict[str, Any]:
    """Build a GeoJSON LineString feature for a launch-side spur."""
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


def detect_backtrack_errors(
    path: Path,
    *,
    merge_meters: float = DEFAULT_MERGE_M,
) -> list[str]:
    """Return errors when a LineString revisits a prior vertex within [merge_meters]."""
    collection = load_feature_collection(path)
    errors: list[str] = []
    for feature_index, feature in enumerate(collection.get("features") or []):
        geometry = feature.get("geometry") or {}
        reach_id = (feature.get("properties") or {}).get("reach_id", feature_index)
        for ring_index, ring in enumerate(iter_linestrings(geometry)):
            seen: list[list[float]] = []
            for point in ring:
                current = [float(point[0]), float(point[1])]
                for prior_index, prior in enumerate(seen[:-1]):
                    if _coords_within_meters(prior, current, merge_meters):
                        errors.append(
                            f"{path.name} feature {reach_id} ring {ring_index}: "
                            f"backtrack revisit near index {prior_index} "
                            f"(within {merge_meters:.0f} m)"
                        )
                        break
                if seen and _coords_within_meters(seen[-1], current, merge_meters):
                    continue
                seen.append(current)
    return errors


def load_launch_anchors() -> dict[str, dict[str, Any]]:
    with _LAUNCH_ANCHORS_PATH.open(encoding="utf-8") as handle:
        payload = json.load(handle)
    if not isinstance(payload, dict):
        raise ValueError(f"Expected object in {_LAUNCH_ANCHORS_PATH}")
    return payload


def launch_anchor_lonlat(launch_id: str) -> tuple[float, float]:
    anchors = load_launch_anchors()
    if launch_id not in anchors:
        raise KeyError(f"Unknown launch anchor id: {launch_id}")
    entry = anchors[launch_id]
    return (float(entry["lon"]), float(entry["lat"]))


def min_snap_distance_meters(
    coords: Sequence[Sequence[float]],
    anchor_lonlat: tuple[float, float],
) -> float:
    if not coords:
        return float("inf")
    anchor_lon, anchor_lat = anchor_lonlat
    return min(
        haversine_meters(anchor_lat, anchor_lon, point[1], point[0])
        for point in coords
    )


def assert_launch_snap_within(
    coords: Sequence[Sequence[float]],
    launch_id: str,
    *,
    max_m: float = ROUTE_SNAP_MAX_M,
    context: str = "",
) -> float:
    anchor = launch_anchor_lonlat(launch_id)
    gap = min_snap_distance_meters(coords, anchor)
    if gap > max_m:
        label = f"{context} " if context else ""
        raise RuntimeError(
            f"{label}{launch_id} is {gap:.1f} m from spur geometry; "
            f"expected within {max_m:.0f} m."
        )
    return gap


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

"""Graph connectivity audit helpers shared by validate.py and compare.py."""

from __future__ import annotations

from typing import Any

from _common import haversine_meters, iter_linestrings


class _UnionFind:
    def __init__(self) -> None:
        self.parent: dict[int, int] = {}

    def add(self, node: int) -> None:
        if node not in self.parent:
            self.parent[node] = node

    def find(self, node: int) -> int:
        parent = self.parent[node]
        if parent != node:
            self.parent[node] = self.find(parent)
        return self.parent[node]

    def union(self, left: int, right: int) -> None:
        self.add(left)
        self.add(right)
        root_left = self.find(left)
        root_right = self.find(right)
        if root_left != root_right:
            self.parent[root_right] = root_left

    @property
    def component_count(self) -> int:
        return len({self.find(node) for node in self.parent})


def analyze_system(
    features: list[dict[str, Any]],
    merge_threshold_m: float,
    gap_warning_m: float,
) -> dict[str, Any]:
    """Build an undirected graph mirroring RiverLineGraph vertex merge."""
    lat: list[float] = []
    lon: list[float] = []
    adj: list[set[int]] = []

    def find_or_add(la: float, lo: float) -> int:
        for index in range(len(lat)):
            if haversine_meters(lat[index], lon[index], la, lo) <= merge_threshold_m:
                return index
        lat.append(la)
        lon.append(lo)
        adj.append(set())
        return len(lat) - 1

    segment_count = 0
    endpoints: list[tuple[int, float, float, int]] = []

    for feature_index, feature in enumerate(features):
        geometry = feature.get("geometry") or {}
        for ring in iter_linestrings(geometry):
            segment_count += 1
            for index in range(len(ring) - 1):
                lon1, lat1 = ring[index][:2]
                lon2, lat2 = ring[index + 1][:2]
                start = find_or_add(lat1, lon1)
                end = find_or_add(lat2, lon2)
                if start != end:
                    adj[start].add(end)
                    adj[end].add(start)
            start_vertex = find_or_add(ring[0][1], ring[0][0])
            end_vertex = find_or_add(ring[-1][1], ring[-1][0])
            endpoints.append((start_vertex, ring[0][1], ring[0][0], feature_index))
            endpoints.append((end_vertex, ring[-1][1], ring[-1][0], feature_index))

    union_find = _UnionFind()
    for index in range(len(lat)):
        union_find.add(index)
        for neighbor in adj[index]:
            union_find.union(index, neighbor)

    degree = [len(neighbors) for neighbors in adj]
    dangling = sum(1 for value in degree if value == 1)

    near_misses: list[dict[str, Any]] = []
    for left_index in range(len(endpoints)):
        vertex_left, lat_left, lon_left, feature_left = endpoints[left_index]
        for right_index in range(left_index + 1, len(endpoints)):
            vertex_right, lat_right, lon_right, feature_right = endpoints[right_index]
            if feature_left == feature_right:
                continue
            if union_find.find(vertex_left) == union_find.find(vertex_right):
                continue
            distance = haversine_meters(lat_left, lon_left, lat_right, lon_right)
            if merge_threshold_m < distance <= gap_warning_m:
                near_misses.append(
                    {
                        "distance_m": round(distance, 2),
                        "feature_a": feature_left,
                        "feature_b": feature_right,
                    }
                )

    near_misses.sort(key=lambda item: item["distance_m"])
    return {
        "vertex_count": len(lat),
        "segment_count": segment_count,
        "edge_count": sum(len(neighbors) for neighbors in adj) // 2,
        "component_count": union_find.component_count,
        "dangling_endpoints": dangling,
        "near_miss_gaps": near_misses[:20],
        "near_miss_gap_count": len(near_misses),
        "lat": lat,
        "lon": lon,
        "union_find": union_find,
    }


def nearest_vertex_distance_m(
    lat: list[float],
    lon: list[float],
    target_lat: float,
    target_lon: float,
) -> float | None:
    if not lat:
        return None
    return min(
        haversine_meters(lat[index], lon[index], target_lat, target_lon)
        for index in range(len(lat))
    )


def endpoint_gap_m(
    upstream_end: tuple[float, float],
    downstream_start: tuple[float, float],
) -> float:
    """Haversine gap between upstream line end and downstream line start (lon, lat)."""
    return haversine_meters(
        upstream_end[1],
        upstream_end[0],
        downstream_start[1],
        downstream_start[0],
    )


def line_endpoints_from_features(
    features: list[dict[str, Any]],
) -> tuple[tuple[float, float], tuple[float, float]] | None:
    """First feature's first line start and end as (lon, lat) pairs."""
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


def merge_feature_collections(
    collections: list[dict[str, Any]],
) -> dict[str, Any]:
    merged_features: list[dict[str, Any]] = []
    for collection in collections:
        merged_features.extend(collection.get("features") or [])
    return {"type": "FeatureCollection", "features": merged_features}


def geometry_stats(features: list[dict[str, Any]]) -> dict[str, Any]:
    """Count features, segments, vertices, and total length for GeoJSON features."""
    from _common import bbox_from_coords, iter_linestrings, polyline_length_meters

    vertex_count = 0
    feature_count = 0
    segment_count = 0
    total_length_m = 0.0
    all_coords: list[tuple[float, float]] = []

    for feature in features:
        geometry = feature.get("geometry") or {}
        for ring in iter_linestrings(geometry):
            feature_count += 1
            segment_count += 1
            vertex_count += len(ring)
            total_length_m += polyline_length_meters(ring)
            for lon, lat in ring:
                all_coords.append((lon, lat))

    bounds = bbox_from_coords(all_coords) if all_coords else (0.0, 0.0, 0.0, 0.0)
    return {
        "feature_count": feature_count,
        "segment_count": segment_count,
        "vertex_count": vertex_count,
        "length_km": total_length_m / 1000.0,
        "bounds": bounds,
    }

#!/usr/bin/env python3
"""Validate connectivity of generated hydro GeoJSON files."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import click

from _common import (
    haversine_meters,
    iter_linestrings,
    load_config,
    load_feature_collection,
    script_dir,
)


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


def _analyze_system(
    features: list[dict[str, Any]],
    merge_threshold_m: float,
    gap_warning_m: float,
) -> dict[str, Any]:
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
    }


@click.command()
@click.option(
    "--config",
    "config_path",
    type=click.Path(path_type=Path, exists=True),
    default=lambda: script_dir() / "config.json",
    show_default=True,
)
@click.option(
    "--input-dir",
    type=click.Path(path_type=Path, file_okay=False),
    default=lambda: script_dir() / "output",
    show_default=True,
)
@click.option(
    "--merge-threshold",
    type=float,
    default=None,
    help="Override merge threshold in meters (defaults to config).",
)
@click.option(
    "--strict",
    is_flag=True,
    help="Exit non-zero when near-miss gaps are found.",
)
def main(
    config_path: Path,
    input_dir: Path,
    merge_threshold: float | None,
    strict: bool,
) -> None:
    """Run connectivity checks similar to RiverLineGraph vertex merging."""
    config = load_config(config_path)
    threshold = (
        merge_threshold
        if merge_threshold is not None
        else float(config["merge_vertex_threshold_meters"])
    )
    gap_warning = float(config["connectivity_gap_warning_meters"])

    geojson_files = sorted(input_dir.glob("*_waterway.geojson"))
    if not geojson_files:
        raise click.ClickException(f"No GeoJSON files found in {input_dir}")

    exit_code = 0
    for path in geojson_files:
        collection = load_feature_collection(path)
        features = collection.get("features") or []
        if not features:
            click.echo(f"WARN {path.name}: empty FeatureCollection")
            exit_code = 1
            continue

        system = path.name.removesuffix("_waterway.geojson")
        report = _analyze_system(features, threshold, gap_warning)
        click.echo(
            f"{system}: vertices={report['vertex_count']} segments={report['segment_count']} "
            f"components={report['component_count']} dangling={report['dangling_endpoints']} "
            f"near_miss_gaps={report['near_miss_gap_count']}"
        )
        for gap in report["near_miss_gaps"][:5]:
            click.echo(
                f"  gap {gap['distance_m']}m between features "
                f"{gap['feature_a']} and {gap['feature_b']}"
            )
        if report["near_miss_gap_count"] > 0 and strict:
            exit_code = 1

    raise SystemExit(exit_code)


if __name__ == "__main__":
    main()

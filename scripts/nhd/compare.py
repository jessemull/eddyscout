#!/usr/bin/env python3
"""Compare NHD output GeoJSON against existing bundled OSM geometry."""

from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Any

import click
from shapely.geometry import LineString, shape
from shapely.ops import unary_union

from _common import (
    bbox_from_coords,
    iter_linestrings,
    load_feature_collection,
    polyline_length_meters,
    script_dir,
    write_feature_collection,
)


def _features_for_system(
    collection: dict[str, Any],
    river_system: str | None,
) -> list[dict[str, Any]]:
    features = collection.get("features") or []
    if river_system is None:
        return features
    filtered: list[dict[str, Any]] = []
    for feature in features:
        props = feature.get("properties") or {}
        if props.get("river_system") == river_system:
            filtered.append(feature)
    return filtered


def _geometry_stats(features: list[dict[str, Any]]) -> dict[str, Any]:
    vertex_count = 0
    feature_count = 0
    total_length_m = 0.0
    all_coords: list[tuple[float, float]] = []
    lines: list[LineString] = []

    for feature in features:
        geometry = feature.get("geometry") or {}
        for ring in iter_linestrings(geometry):
            feature_count += 1
            vertex_count += len(ring)
            total_length_m += polyline_length_meters(ring)
            for lon, lat in ring:
                all_coords.append((lon, lat))
            lines.append(LineString(ring))

    bounds = bbox_from_coords(all_coords) if all_coords else (0.0, 0.0, 0.0, 0.0)
    merged = unary_union(lines) if lines else None
    return {
        "feature_count": feature_count,
        "vertex_count": vertex_count,
        "length_km": total_length_m / 1000.0,
        "bounds": bounds,
        "merged_geometry": merged,
    }


def _hausdorff_meters(
    left: Any | None,
    right: Any | None,
) -> float | None:
    if left is None or right is None or left.is_empty or right.is_empty:
        return None
    # Shapely hausdorff_distance is in CRS units (degrees here); approximate meters.
    center_lat = (left.bounds[1] + left.bounds[3]) / 2.0
    meters_per_degree = 111_320 * math.cos(math.radians(center_lat))
    return left.hausdorff_distance(right) * meters_per_degree


@click.command()
@click.option(
    "--baseline",
    type=click.Path(path_type=Path, exists=True),
    required=True,
    help="Existing bundled GeoJSON (e.g. OSM/Overpass output).",
)
@click.option(
    "--candidate",
    type=click.Path(path_type=Path, exists=True),
    required=True,
    help="NHD-generated GeoJSON to compare.",
)
@click.option(
    "--system",
    default=None,
    help="Optional river_system filter applied to both inputs.",
)
@click.option(
    "--overlay-out",
    type=click.Path(path_type=Path),
    default=None,
    help="Optional path to write a two-layer overlay FeatureCollection.",
)
def main(
    baseline: Path,
    candidate: Path,
    system: str | None,
    overlay_out: Path | None,
) -> None:
    """Report geometric differences between baseline and candidate hydro data."""
    baseline_features = _features_for_system(load_feature_collection(baseline), system)
    candidate_features = _features_for_system(load_feature_collection(candidate), system)

    baseline_stats = _geometry_stats(baseline_features)
    candidate_stats = _geometry_stats(candidate_features)

    hausdorff = _hausdorff_meters(
        baseline_stats["merged_geometry"],
        candidate_stats["merged_geometry"],
    )

    click.echo("baseline:")
    click.echo(
        f"  features={baseline_stats['feature_count']} "
        f"vertices={baseline_stats['vertex_count']} "
        f"length_km={baseline_stats['length_km']:.2f}"
    )
    click.echo(f"  bounds={baseline_stats['bounds']}")

    click.echo("candidate:")
    click.echo(
        f"  features={candidate_stats['feature_count']} "
        f"vertices={candidate_stats['vertex_count']} "
        f"length_km={candidate_stats['length_km']:.2f}"
    )
    click.echo(f"  bounds={candidate_stats['bounds']}")

    vertex_delta = candidate_stats["vertex_count"] - baseline_stats["vertex_count"]
    length_delta = candidate_stats["length_km"] - baseline_stats["length_km"]
    click.echo(f"delta vertices={vertex_delta:+d} length_km={length_delta:+.2f}")
    if hausdorff is not None:
        click.echo(f"approx hausdorff_m={hausdorff:.1f}")

    if overlay_out is not None:
        overlay_features: list[dict[str, Any]] = []
        for feature in baseline_features:
            overlay_features.append(
                {
                    "type": "Feature",
                    "properties": {
                        **(feature.get("properties") or {}),
                        "dataset": "baseline",
                    },
                    "geometry": json.loads(
                        json.dumps(shape(feature["geometry"]).__geo_interface__)
                    ),
                }
            )
        for feature in candidate_features:
            overlay_features.append(
                {
                    "type": "Feature",
                    "properties": {
                        **(feature.get("properties") or {}),
                        "dataset": "candidate",
                    },
                    "geometry": json.loads(
                        json.dumps(shape(feature["geometry"]).__geo_interface__)
                    ),
                }
            )
        write_feature_collection(overlay_out, overlay_features)
        click.echo(f"wrote overlay: {overlay_out}")


if __name__ == "__main__":
    main()

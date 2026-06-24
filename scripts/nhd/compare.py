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

import sys

from _common import (
    iter_linestrings,
    load_config,
    load_feature_collection,
    script_dir,
    write_feature_collection,
)

_hydro_scripts = script_dir().parent / "hydro"
if str(_hydro_scripts) not in sys.path:
    sys.path.insert(0, str(_hydro_scripts))
from confluence_audit import load_confluence_audit_compare_entries  # noqa: E402

from graph_audit import (
    analyze_system,
    confluence_audit_rows,
    geometry_stats,
    merge_feature_collections,
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
    stats = geometry_stats(features)
    lines: list[LineString] = []
    for feature in features:
        geometry = feature.get("geometry") or {}
        for ring in iter_linestrings(geometry):
            lines.append(LineString(ring))
    merged = unary_union(lines) if lines else None
    return {**stats, "merged_geometry": merged}


def _hausdorff_meters(
    left: Any | None,
    right: Any | None,
) -> float | None:
    if left is None or right is None or left.is_empty or right.is_empty:
        return None
    center_lat = (left.bounds[1] + left.bounds[3]) / 2.0
    meters_per_degree = 111_320 * math.cos(math.radians(center_lat))
    return left.hausdorff_distance(right) * meters_per_degree


def _load_baselines(baseline_paths: tuple[Path, ...]) -> dict[str, Any]:
    collections = [load_feature_collection(path) for path in baseline_paths]
    return merge_feature_collections(collections)


def _format_comparison_markdown(
    label: str,
    baseline_stats: dict[str, Any],
    candidate_stats: dict[str, Any],
    hausdorff: float | None,
    baseline_graph: dict[str, Any],
    candidate_graph: dict[str, Any],
    confluence_rows: list[dict[str, Any]],
) -> str:
    vertex_delta = candidate_stats["vertex_count"] - baseline_stats["vertex_count"]
    length_delta = candidate_stats["length_km"] - baseline_stats["length_km"]
    lines = [
        f"## {label}",
        "",
        "| Metric | Baseline (OSM) | Candidate (NHD) | Delta |",
        "|--------|----------------|-----------------|-------|",
        f"| Features | {baseline_stats['feature_count']} | "
        f"{candidate_stats['feature_count']} | "
        f"{candidate_stats['feature_count'] - baseline_stats['feature_count']:+d} |",
        f"| Segments | {baseline_stats['segment_count']} | "
        f"{candidate_stats['segment_count']} | "
        f"{candidate_stats['segment_count'] - baseline_stats['segment_count']:+d} |",
        f"| Vertices | {baseline_stats['vertex_count']} | "
        f"{candidate_stats['vertex_count']} | {vertex_delta:+d} |",
        f"| Length (km) | {baseline_stats['length_km']:.2f} | "
        f"{candidate_stats['length_km']:.2f} | {length_delta:+.2f} |",
        "",
        f"- Baseline bounds: `{baseline_stats['bounds']}`",
        f"- Candidate bounds: `{candidate_stats['bounds']}`",
    ]
    if hausdorff is not None:
        lines.append(f"- Approx Hausdorff: **{hausdorff:.1f} m**")
    lines.extend(
        [
            "",
            "### Graph connectivity",
            "",
            "| Dataset | Vertices | Components | Dangling | Near-miss gaps |",
            "|---------|----------|------------|----------|----------------|",
            f"| Baseline | {baseline_graph['vertex_count']} | "
            f"{baseline_graph['component_count']} | "
            f"{baseline_graph['dangling_endpoints']} | "
            f"{baseline_graph['near_miss_gap_count']} |",
            f"| Candidate | {candidate_graph['vertex_count']} | "
            f"{candidate_graph['component_count']} | "
            f"{candidate_graph['dangling_endpoints']} | "
            f"{candidate_graph['near_miss_gap_count']} |",
        ]
    )
    if confluence_rows:
        lines.extend(
            [
                "",
                "### Confluence snap distances",
                "",
                "| ID | Required | Endpoint gap (m) | Baseline snap (m) | "
                "Candidate snap (m) |",
                "|----|----------|------------------|-------------------|"
                "--------------------|",
            ]
        )
        for row in confluence_rows:
            req = "yes" if row["required"] else ("info" if row["informational"] else "no")
            lines.append(
                f"| {row['id']} | {req} | {row['endpoint_gap_m']} | "
                f"{row['baseline_snap_m']} | {row['candidate_snap_m']} |"
            )
    lines.append("")
    return "\n".join(lines)


def run_comparison(
    *,
    baseline_paths: tuple[Path, ...],
    candidate_path: Path,
    label: str,
    system: str | None,
    merge_threshold_m: float,
    gap_warning_m: float,
    confluence_audit: list[dict[str, Any]],
    overlay_out: Path | None = None,
) -> str:
    """Compare baseline GeoJSON file(s) to a candidate and return Markdown."""
    baseline_collection = _load_baselines(baseline_paths)
    candidate_collection = load_feature_collection(candidate_path)

    baseline_features = _features_for_system(baseline_collection, system)
    candidate_features = _features_for_system(candidate_collection, system)

    baseline_stats = _geometry_stats(baseline_features)
    candidate_stats = _geometry_stats(candidate_features)
    hausdorff = _hausdorff_meters(
        baseline_stats["merged_geometry"],
        candidate_stats["merged_geometry"],
    )

    baseline_graph = analyze_system(baseline_features, merge_threshold_m, gap_warning_m)
    candidate_graph = analyze_system(candidate_features, merge_threshold_m, gap_warning_m)
    confluence_rows = confluence_audit_rows(
        baseline_features,
        candidate_features,
        confluence_audit,
        merge_threshold_m,
        gap_warning_m,
    )

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

    click.echo(f"=== {label} ===")
    click.echo(
        f"baseline: features={baseline_stats['feature_count']} "
        f"vertices={baseline_stats['vertex_count']} "
        f"length_km={baseline_stats['length_km']:.2f}"
    )
    click.echo(
        f"candidate: features={candidate_stats['feature_count']} "
        f"vertices={candidate_stats['vertex_count']} "
        f"length_km={candidate_stats['length_km']:.2f}"
    )
    if hausdorff is not None:
        click.echo(f"approx hausdorff_m={hausdorff:.1f}")

    return _format_comparison_markdown(
        label,
        baseline_stats,
        candidate_stats,
        hausdorff,
        baseline_graph,
        candidate_graph,
        confluence_rows,
    )


@click.command()
@click.option(
    "--baseline",
    "baseline_paths",
    type=click.Path(path_type=Path, exists=True),
    multiple=True,
    required=True,
    help="Existing bundled GeoJSON (repeat for merged baselines).",
)
@click.option(
    "--candidate",
    type=click.Path(path_type=Path, exists=True),
    required=True,
    help="NHD-generated GeoJSON to compare.",
)
@click.option("--label", default="Comparison", show_default=True)
@click.option(
    "--system",
    default=None,
    help="Optional river_system filter applied to both inputs.",
)
@click.option(
    "--config",
    "config_path",
    type=click.Path(path_type=Path, exists=True),
    default=lambda: script_dir() / "config.json",
    show_default=True,
)
@click.option(
    "--report-out",
    type=click.Path(path_type=Path),
    default=None,
    help="Append Markdown report section to this file.",
)
@click.option(
    "--overlay-out",
    type=click.Path(path_type=Path),
    default=None,
    help="Optional path to write a two-layer overlay FeatureCollection.",
)
def main(
    baseline_paths: tuple[Path, ...],
    candidate: Path,
    label: str,
    system: str | None,
    config_path: Path,
    report_out: Path | None,
    overlay_out: Path | None,
) -> None:
    """Report geometric differences between baseline and candidate hydro data."""
    config = load_config(config_path)
    merge_threshold_m = float(config["merge_vertex_threshold_meters"])
    gap_warning_m = float(config["connectivity_gap_warning_meters"])
    confluence_audit = load_confluence_audit_compare_entries()

    markdown = run_comparison(
        baseline_paths=baseline_paths,
        candidate_path=candidate,
        label=label,
        system=system,
        merge_threshold_m=merge_threshold_m,
        gap_warning_m=gap_warning_m,
        confluence_audit=confluence_audit,
        overlay_out=overlay_out,
    )

    if report_out is not None:
        report_out.parent.mkdir(parents=True, exist_ok=True)
        if report_out.exists() and report_out.stat().st_size > 0:
            with report_out.open("a", encoding="utf-8") as handle:
                handle.write("\n")
                handle.write(markdown)
        else:
            header = (
                "# NHD vs bundled OSM hydro comparison\n\n"
                "Generated by `scripts/nhd/compare.py` / `make hydro-nhd-compare`.\n"
            )
            report_out.write_text(f"{header}\n{markdown}", encoding="utf-8")
        click.echo(f"wrote report section: {report_out}")


if __name__ == "__main__":
    main()

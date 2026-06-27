#!/usr/bin/env python3
"""Validate connectivity of generated hydro GeoJSON files."""

from __future__ import annotations

from pathlib import Path

import click

from _common import load_config, load_feature_collection, script_dir
from graph_audit import analyze_system


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
        report = analyze_system(features, threshold, gap_warning)
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

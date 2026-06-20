#!/usr/bin/env python3
"""Validate bundled hydro GeoJSON for land-chord and confluence regressions."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _common import (  # noqa: E402
    bundled_hydro_dir,
    haversine_meters,
    iter_linestrings,
    line_endpoints,
    load_feature_collection,
    max_edge_meters,
)

DEFAULT_MAX_EDGE_M = 2000.0
DEFAULT_CONFLUENCE_GAP_M = 12.0

CONFLUENCE_PAIRS = (
    ("willamette_waterway.geojson", "columbia_lower_waterway.geojson"),
    ("columbia_lower_waterway.geojson", "columbia_gorge_waterway.geojson"),
)


def _check_edges(path: Path, max_edge_m: float) -> list[str]:
    collection = load_feature_collection(path)
    errors: list[str] = []
    for feature_index, feature in enumerate(collection.get("features") or []):
        geometry = feature.get("geometry") or {}
        for ring_index, ring in enumerate(iter_linestrings(geometry)):
            longest = max_edge_meters(ring)
            if longest > max_edge_m:
                errors.append(
                    f"{path.name} feature {feature_index} ring {ring_index}: "
                    f"longest edge {longest:.1f} m exceeds {max_edge_m:.0f} m"
                )
    return errors


def _check_confluence_gaps(
    hydro_dir: Path,
    max_gap_m: float,
) -> list[str]:
    errors: list[str] = []
    for upstream_name, downstream_name in CONFLUENCE_PAIRS:
        upstream = load_feature_collection(hydro_dir / upstream_name)
        downstream = load_feature_collection(hydro_dir / downstream_name)
        upstream_endpoints = line_endpoints(upstream)
        downstream_endpoints = line_endpoints(downstream)
        if upstream_endpoints is None or downstream_endpoints is None:
            errors.append(
                f"Missing line geometry for confluence check "
                f"{upstream_name} -> {downstream_name}"
            )
            continue
        _, upstream_end = upstream_endpoints
        downstream_start, _ = downstream_endpoints
        gap = haversine_meters(
            upstream_end[1],
            upstream_end[0],
            downstream_start[1],
            downstream_start[0],
        )
        if gap > max_gap_m:
            errors.append(
                f"Confluence gap {upstream_name} end -> {downstream_name} start: "
                f"{gap:.2f} m exceeds {max_gap_m:.0f} m"
            )
    return errors


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Run geometry checks on bundled hydro assets.",
    )
    parser.add_argument(
        "--hydro-dir",
        type=Path,
        default=bundled_hydro_dir(),
        help="Directory containing *_waterway.geojson files.",
    )
    parser.add_argument(
        "--max-edge-m",
        type=float,
        default=DEFAULT_MAX_EDGE_M,
        help="Fail when any consecutive coordinate pair exceeds this distance.",
    )
    parser.add_argument(
        "--confluence-gap-m",
        type=float,
        default=DEFAULT_CONFLUENCE_GAP_M,
        help="Fail when paired reach endpoints exceed this gap.",
    )
    args = parser.parse_args()
    hydro_dir: Path = args.hydro_dir
    max_edge_m: float = args.max_edge_m
    confluence_gap_m: float = args.confluence_gap_m

    geojson_files = sorted(hydro_dir.glob("*_waterway.geojson"))
    if not geojson_files:
        parser.error(f"No *_waterway.geojson files in {hydro_dir}")

    errors: list[str] = []
    for path in geojson_files:
        errors.extend(_check_edges(path, max_edge_m))

    errors.extend(_check_confluence_gaps(hydro_dir, confluence_gap_m))

    if errors:
        print("=== Hydro geometry check FAILED ===", file=sys.stderr)
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)

    print(
        f"Hydro geometry OK ({len(geojson_files)} files, "
        f"max edge {max_edge_m:.0f} m, confluence gap {confluence_gap_m:.0f} m)"
    )


if __name__ == "__main__":
    main()

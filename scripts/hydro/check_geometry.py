#!/usr/bin/env python3
"""Validate bundled hydro GeoJSON for land-chord and confluence regressions."""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from _common import (  # noqa: E402
    bundled_hydro_dir,
    detect_backtrack_errors,
    haversine_meters,
    iter_linestrings,
    line_endpoints,
    load_feature_collection,
    max_edge_meters,
)
from confluence_audit import load_confluence_audit_pairs  # noqa: E402

DEFAULT_MAX_EDGE_M = 2000.0
DEFAULT_CONFLUENCE_GAP_M = 12.0


def _required_confluence_pairs() -> tuple[tuple[str, str], ...]:
    return tuple(
        (pair["upstream_file"], pair["downstream_file"])
        for pair in load_confluence_audit_pairs()
        if pair.get("required")
    )


def _informational_confluence_pairs() -> tuple[tuple[str, str, str, str], ...]:
    return tuple(
        (
            pair["upstream_file"],
            pair["downstream_file"],
            pair["upstream_point"],
            pair["downstream_point"],
        )
        for pair in load_confluence_audit_pairs()
        if pair.get("informational")
    )


@dataclass(frozen=True)
class ConfluenceAuditResult:
    """Structured result for one confluence pair audit."""

    pair_id: str
    upstream_file: str
    downstream_file: str
    gap_m: float
    connected: bool
    required: bool
    informational: bool


def _pair_id(upstream_name: str, downstream_name: str) -> str:
    upstream = upstream_name.removesuffix("_waterway.geojson")
    downstream = downstream_name.removesuffix("_waterway.geojson")
    return f"{upstream}_{downstream}"


def _endpoint_gap_for_pair(
    hydro_dir: Path,
    upstream_name: str,
    downstream_name: str,
    *,
    upstream_point: str = "end",
    downstream_point: str = "start",
) -> float | None:
    upstream_path = hydro_dir / upstream_name
    downstream_path = hydro_dir / downstream_name
    if not upstream_path.is_file() or not downstream_path.is_file():
        return None

    upstream = load_feature_collection(upstream_path)
    downstream = load_feature_collection(downstream_path)
    upstream_endpoints = line_endpoints(upstream)
    downstream_endpoints = line_endpoints(downstream)
    if upstream_endpoints is None or downstream_endpoints is None:
        return None

    upstream_start, upstream_end = upstream_endpoints
    downstream_start, downstream_end = downstream_endpoints
    upstream_coord = upstream_end if upstream_point == "end" else upstream_start
    downstream_coord = (
        downstream_end if downstream_point == "end" else downstream_start
    )
    return haversine_meters(
        upstream_coord[1],
        upstream_coord[0],
        downstream_coord[1],
        downstream_coord[0],
    )


def audit_confluence_connectivity(
    hydro_dir: Path,
    *,
    confluence_gap_m: float = DEFAULT_CONFLUENCE_GAP_M,
) -> list[ConfluenceAuditResult]:
    """Return structured confluence audit rows for bundled hydro assets."""
    results: list[ConfluenceAuditResult] = []

    for upstream_name, downstream_name in _required_confluence_pairs():
        gap = _endpoint_gap_for_pair(hydro_dir, upstream_name, downstream_name)
        if gap is None:
            results.append(
                ConfluenceAuditResult(
                    pair_id=_pair_id(upstream_name, downstream_name),
                    upstream_file=upstream_name,
                    downstream_file=downstream_name,
                    gap_m=float("inf"),
                    connected=False,
                    required=True,
                    informational=False,
                )
            )
            continue
        results.append(
            ConfluenceAuditResult(
                pair_id=_pair_id(upstream_name, downstream_name),
                upstream_file=upstream_name,
                downstream_file=downstream_name,
                gap_m=gap,
                connected=gap <= confluence_gap_m,
                required=True,
                informational=False,
            )
        )

    for entry in _informational_confluence_pairs():
        upstream_name, downstream_name, upstream_point, downstream_point = entry
        gap = _endpoint_gap_for_pair(
            hydro_dir,
            upstream_name,
            downstream_name,
            upstream_point=upstream_point,
            downstream_point=downstream_point,
        )
        if gap is None:
            continue
        results.append(
            ConfluenceAuditResult(
                pair_id=_pair_id(upstream_name, downstream_name),
                upstream_file=upstream_name,
                downstream_file=downstream_name,
                gap_m=gap,
                connected=gap <= confluence_gap_m,
                required=False,
                informational=True,
            )
        )

    return results


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


def _check_required_confluence_gaps(
    hydro_dir: Path,
    max_gap_m: float,
) -> list[str]:
    errors: list[str] = []
    for upstream_name, downstream_name in _required_confluence_pairs():
        gap = _endpoint_gap_for_pair(hydro_dir, upstream_name, downstream_name)
        if gap is None:
            errors.append(
                f"Missing line geometry for confluence check "
                f"{upstream_name} -> {downstream_name}"
            )
            continue
        if gap > max_gap_m:
            errors.append(
                f"Confluence gap {upstream_name} end -> {downstream_name} start: "
                f"{gap:.2f} m exceeds {max_gap_m:.0f} m"
            )
    return errors


def collect_geometry_errors(
    hydro_dir: Path,
    *,
    max_edge_m: float = DEFAULT_MAX_EDGE_M,
    confluence_gap_m: float = DEFAULT_CONFLUENCE_GAP_M,
) -> list[str]:
    """Return validation errors for bundled hydro GeoJSON in [hydro_dir]."""
    geojson_files = sorted(hydro_dir.glob("*_waterway.geojson"))
    if not geojson_files:
        return [f"No *_waterway.geojson files in {hydro_dir}"]

    errors: list[str] = []
    for path in geojson_files:
        errors.extend(_check_edges(path, max_edge_m))
        errors.extend(detect_backtrack_errors(path, merge_meters=confluence_gap_m))

    errors.extend(_check_required_confluence_gaps(hydro_dir, confluence_gap_m))
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
    parser.add_argument(
        "--audit-json",
        type=Path,
        default=None,
        help="Optional path to write structured confluence audit JSON.",
    )
    args = parser.parse_args()
    hydro_dir: Path = args.hydro_dir
    max_edge_m: float = args.max_edge_m
    confluence_gap_m: float = args.confluence_gap_m

    audit = audit_confluence_connectivity(hydro_dir, confluence_gap_m=confluence_gap_m)
    for row in audit:
        if row.informational:
            status = "connected" if row.connected else "gap"
            print(
                f"INFO confluence {row.pair_id}: {status} "
                f"({row.gap_m:.1f} m, informational only)"
            )

    if args.audit_json is not None:
        payload: list[dict[str, Any]] = [
            {
                "pair_id": row.pair_id,
                "upstream_file": row.upstream_file,
                "downstream_file": row.downstream_file,
                "gap_m": round(row.gap_m, 2),
                "connected": row.connected,
                "required": row.required,
                "informational": row.informational,
            }
            for row in audit
        ]
        args.audit_json.parent.mkdir(parents=True, exist_ok=True)
        args.audit_json.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    errors = collect_geometry_errors(
        hydro_dir,
        max_edge_m=max_edge_m,
        confluence_gap_m=confluence_gap_m,
    )

    if errors:
        print("=== Hydro geometry check FAILED ===", file=sys.stderr)
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)

    geojson_files = sorted(hydro_dir.glob("*_waterway.geojson"))
    print(
        f"Hydro geometry OK ({len(geojson_files)} files, "
        f"max edge {max_edge_m:.0f} m, confluence gap {confluence_gap_m:.0f} m)"
    )


if __name__ == "__main__":
    main()

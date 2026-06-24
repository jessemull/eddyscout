#!/usr/bin/env python3
"""Unit tests for bundled hydro geometry validation."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from check_geometry import audit_confluence_connectivity, collect_geometry_errors
from _common import bundled_hydro_dir


def _write_feature_collection(path: Path, coordinates: list[list[float]]) -> None:
    payload = {
        "type": "FeatureCollection",
        "features": [
            {
                "type": "Feature",
                "properties": {"river_system": "test"},
                "geometry": {
                    "type": "LineString",
                    "coordinates": coordinates,
                },
            }
        ],
    }
    path.write_text(json.dumps(payload), encoding="utf-8")


class CheckGeometryTest(unittest.TestCase):
    def test_passes_for_short_edges_and_closed_confluence(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            hydro_dir = Path(tmp)
            _write_feature_collection(
                hydro_dir / "willamette_waterway.geojson",
                [[-122.0, 45.0], [-122.001, 45.0]],
            )
            _write_feature_collection(
                hydro_dir / "columbia_lower_waterway.geojson",
                [[-122.001, 45.0], [-122.002, 45.0]],
            )
            _write_feature_collection(
                hydro_dir / "columbia_gorge_waterway.geojson",
                [[-122.002, 45.0], [-122.003, 45.0]],
            )

            errors = collect_geometry_errors(hydro_dir)
            self.assertEqual(errors, [])

    def test_fails_when_any_edge_exceeds_max_length(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            hydro_dir = Path(tmp)
            _write_feature_collection(
                hydro_dir / "willamette_waterway.geojson",
                [[-122.0, 45.0], [-122.0, 45.03]],
            )
            _write_feature_collection(
                hydro_dir / "columbia_lower_waterway.geojson",
                [[-122.0, 45.03], [-122.001, 45.03]],
            )
            _write_feature_collection(
                hydro_dir / "columbia_gorge_waterway.geojson",
                [[-122.001, 45.03], [-122.002, 45.03]],
            )

            errors = collect_geometry_errors(hydro_dir, max_edge_m=2000.0)
            self.assertTrue(any("longest edge" in error for error in errors))

    def test_fails_when_confluence_gap_exceeds_threshold(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            hydro_dir = Path(tmp)
            _write_feature_collection(
                hydro_dir / "willamette_waterway.geojson",
                [[-122.0, 45.0], [-122.001, 45.0]],
            )
            _write_feature_collection(
                hydro_dir / "columbia_lower_waterway.geojson",
                [[-122.1, 45.0], [-122.101, 45.0]],
            )
            _write_feature_collection(
                hydro_dir / "columbia_gorge_waterway.geojson",
                [[-122.101, 45.0], [-122.102, 45.0]],
            )

            errors = collect_geometry_errors(hydro_dir, confluence_gap_m=12.0)
            self.assertTrue(
                any(
                    "willamette_waterway.geojson end -> columbia_lower_waterway.geojson start"
                    in error
                    for error in errors
                )
            )


    def test_informational_confluence_audit_does_not_fail_geometry_gate(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            hydro_dir = Path(tmp)
            _write_feature_collection(
                hydro_dir / "willamette_waterway.geojson",
                [[-122.0, 45.0], [-122.001, 45.0]],
            )
            _write_feature_collection(
                hydro_dir / "columbia_lower_waterway.geojson",
                [[-122.001, 45.0], [-122.002, 45.0]],
            )
            _write_feature_collection(
                hydro_dir / "columbia_gorge_waterway.geojson",
                [[-122.002, 45.0], [-122.003, 45.0]],
            )
            _write_feature_collection(
                hydro_dir / "clackamas_waterway.geojson",
                [[-122.004, 45.0], [-122.005, 45.003]],
            )

            errors = collect_geometry_errors(hydro_dir, confluence_gap_m=12.0)
            self.assertEqual(errors, [])

            audit = audit_confluence_connectivity(hydro_dir, confluence_gap_m=12.0)
            clackamas = next(
                row for row in audit if row.pair_id == "clackamas_willamette"
            )
            self.assertTrue(clackamas.informational)
            self.assertFalse(clackamas.connected)

    def test_sandy_informational_audit_connected_on_bundled_assets(self) -> None:
        audit = audit_confluence_connectivity(
            bundled_hydro_dir(),
            confluence_gap_m=12.0,
        )
        sandy = next(row for row in audit if row.pair_id == "sandy_columbia_gorge")
        self.assertTrue(sandy.informational)
        self.assertTrue(sandy.connected)


if __name__ == "__main__":
    unittest.main()

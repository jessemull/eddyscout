#!/usr/bin/env python3
"""Unit tests for shared hydro geometry helpers."""

from __future__ import annotations

import unittest

from _common import (
    DEFAULT_MERGE_M,
    detect_backtrack_errors,
    nearest_point_on_polyline,
    prune_backtrack_loops,
    spur_feature,
)


class CommonGeometryTest(unittest.TestCase):
    def test_prune_backtrack_loops_removes_duplicate_and_detour(self) -> None:
        coords = [
            [0.0, 0.0],
            [0.0, 0.01],
            [0.0, 0.02],
            [0.0, 0.01],
            [0.0, 0.03],
        ]
        pruned = prune_backtrack_loops(coords, merge_meters=DEFAULT_MERGE_M)
        self.assertEqual(len(pruned), 3)
        self.assertEqual(pruned[0], [0.0, 0.0])
        self.assertEqual(pruned[1], [0.0, 0.01])
        self.assertEqual(pruned[2], [0.0, 0.03])

    def test_nearest_point_on_polyline_returns_midpoint(self) -> None:
        coords = [[0.0, 0.0], [0.0, 0.02]]
        index, fraction, lon, lat, distance = nearest_point_on_polyline(
            0.0,
            0.01,
            coords,
        )
        self.assertEqual(index, 0)
        self.assertAlmostEqual(fraction, 0.5, places=2)
        self.assertAlmostEqual(lon, 0.0, places=5)
        self.assertAlmostEqual(lat, 0.01, places=4)
        self.assertLess(distance, 1.0)

    def test_spur_feature_includes_reach_metadata(self) -> None:
        feature = spur_feature(
            reach_id="camas_slough_spur",
            name="Camas Slough spur",
            source="test",
            coordinates=[[0.0, 0.0], [0.0, 0.01]],
        )
        self.assertEqual(
            feature["properties"]["reach_id"],
            "camas_slough_spur",
        )
        self.assertEqual(feature["geometry"]["type"], "LineString")

    def test_detect_backtrack_errors_flags_revisit(self) -> None:
        import json
        import tempfile
        from pathlib import Path

        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "loop_waterway.geojson"
            payload = {
                "type": "FeatureCollection",
                "features": [
                    {
                        "type": "Feature",
                        "properties": {"river_system": "test", "reach_id": "loop"},
                        "geometry": {
                            "type": "LineString",
                            "coordinates": [
                                [0.0, 0.0],
                                [0.0, 0.01],
                                [0.0, 0.02],
                                [0.0, 0.01],
                                [0.0, 0.03],
                            ],
                        },
                    }
                ],
            }
            path.write_text(json.dumps(payload), encoding="utf-8")
            errors = detect_backtrack_errors(path, merge_meters=DEFAULT_MERGE_M)
            self.assertTrue(errors)


if __name__ == "__main__":
    unittest.main()

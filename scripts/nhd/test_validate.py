#!/usr/bin/env python3
"""Unit tests for NHD graph connectivity validation."""

from __future__ import annotations

import unittest

from graph_audit import analyze_system


def _feature(coords: list[list[float]], river_system: str = "test") -> dict:
    return {
        "type": "Feature",
        "properties": {"river_system": river_system},
        "geometry": {"type": "LineString", "coordinates": coords},
    }


class AnalyzeSystemTest(unittest.TestCase):
    def test_connected_chain_has_single_component(self) -> None:
        features = [
            _feature([[0.0, 0.0], [0.0, 0.01], [0.0, 0.02]]),
        ]
        report = analyze_system(features, merge_threshold_m=50000, gap_warning_m=100000)
        self.assertEqual(report["component_count"], 1)
        self.assertEqual(report["near_miss_gap_count"], 0)

    def test_reports_near_miss_gap_between_features(self) -> None:
        features = [
            _feature([[0.0, 0.0], [0.0, 0.01]]),
            _feature([[0.0, 0.015], [0.0, 0.02]]),
        ]
        report = analyze_system(features, merge_threshold_m=25, gap_warning_m=2000)
        self.assertGreater(report["component_count"], 1)
        self.assertGreater(report["near_miss_gap_count"], 0)


if __name__ == "__main__":
    unittest.main()

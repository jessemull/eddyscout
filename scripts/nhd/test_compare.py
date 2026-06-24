#!/usr/bin/env python3
"""Unit tests for NHD compare tooling (stdlib + graph_audit only)."""

from __future__ import annotations

import unittest

from graph_audit import confluence_audit_rows, geometry_stats, merge_feature_collections


class CompareLibTest(unittest.TestCase):
    def test_geometry_stats_counts_vertices_and_segments(self) -> None:
        features = [
            {
                "type": "Feature",
                "properties": {"river_system": "willamette"},
                "geometry": {
                    "type": "LineString",
                    "coordinates": [[0.0, 0.0], [0.0, 0.01], [0.0, 0.02]],
                },
            }
        ]
        stats = geometry_stats(features)
        self.assertEqual(stats["feature_count"], 1)
        self.assertEqual(stats["segment_count"], 1)
        self.assertEqual(stats["vertex_count"], 3)
        self.assertGreater(stats["length_km"], 0)

    def test_merge_feature_collections_combines_features(self) -> None:
        left = {"type": "FeatureCollection", "features": [{"type": "Feature"}]}
        right = {"type": "FeatureCollection", "features": [{"type": "Feature"}]}
        merged = merge_feature_collections([left, right])
        self.assertEqual(len(merged["features"]), 2)

    def test_confluence_audit_rows_reports_gap_and_snaps(self) -> None:
        baseline_features = [
            {
                "type": "Feature",
                "properties": {"river_system": "upstream"},
                "geometry": {
                    "type": "LineString",
                    "coordinates": [[0.0, 0.0], [0.0, 0.01]],
                },
            }
        ]
        candidate_features = [
            {
                "type": "Feature",
                "properties": {"river_system": "downstream"},
                "geometry": {
                    "type": "LineString",
                    "coordinates": [[0.0, 0.015], [0.0, 0.02]],
                },
            }
        ]
        audit_entries = [
            {
                "id": "test_gap",
                "required": False,
                "informational": True,
                "upstream_end": [0.0, 0.01],
                "downstream_start": [0.0, 0.015],
            }
        ]
        rows = confluence_audit_rows(
            baseline_features,
            candidate_features,
            audit_entries,
            merge_threshold_m=25,
            gap_warning_m=2000,
        )
        self.assertEqual(len(rows), 1)
        row = rows[0]
        self.assertEqual(row["id"], "test_gap")
        self.assertGreater(row["endpoint_gap_m"], 0)
        self.assertIsNotNone(row["baseline_snap_m"])
        self.assertIsNotNone(row["candidate_snap_m"])


if __name__ == "__main__":
    unittest.main()

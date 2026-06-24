#!/usr/bin/env python3
"""Unit tests for NHD compare tooling (stdlib + graph_audit only)."""

from __future__ import annotations

import unittest

from graph_audit import geometry_stats, merge_feature_collections


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


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""Fetch Camas Slough spur geometry and merge into columbia_lower bundle."""

from __future__ import annotations

import argparse
import heapq
import json
import math
import sys
import urllib.error
import urllib.request
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
HYRO_DIR = SCRIPT_DIR.parent / "hydro"
sys.path.insert(0, str(HYRO_DIR))

from _common import (  # noqa: E402
    bundled_hydro_dir,
    haversine_meters,
    hydro_fixture_dir,
    load_feature_collection,
    max_edge_meters,
    nearest_point_on_polyline,
    polyline_length_meters,
    prune_backtrack_loops,
    round_coord,
    spur_feature,
    write_feature_collection,
)
from merge_index import VertexMergeIndex  # noqa: E402

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
USER_AGENT = "EddyScout-hydro-import/1.0 (scripts/overpass/fetch_slough_waterway.py)"

CAMAS_SLOUGH_WAY_ID = 130204446
CAMAS_SLOUGH_BBOX = (45.55, -122.46, 45.60, -122.38)
CAMAS_SPLIT = (-122.4300244, 45.5659948)
PORT_OF_CAMAS = (-122.4244, 45.5856)
MAX_EDGE_M = 2000.0
DENSIFY_STEP_M = 400.0
MERGE_M = 12.0
SLOUGH_SPUR_REACH_ID = "camas_slough_spur"


@dataclass(frozen=True)
class WayRecord:
    way_id: int
    name: str
    coordinates: list[tuple[float, float]]


class OsmGraph:
    def __init__(self, merge_meters: float = MERGE_M, ref_latitude: float = 45.58) -> None:
        self._merge = VertexMergeIndex(merge_meters, ref_latitude)
        self._edge_chains: dict[tuple[int, int], list[list[float]]] = {}
        self._adj: dict[int, list[tuple[int, float]]] = defaultdict(list)

    def add_way(self, coordinates: list[tuple[float, float]]) -> None:
        if len(coordinates) < 2:
            return
        verts = [self._merge.find_or_add(lat, lon) for lon, lat in coordinates]
        run = [list(coordinates[0])]
        previous = verts[0]
        for index in range(1, len(coordinates)):
            run.append(list(coordinates[index]))
            current = verts[index]
            if current != previous:
                self._store_edge(previous, current, run)
                previous = current
                run = [list(coordinates[index])]

    def _store_edge(
        self,
        left: int,
        right: int,
        chain: list[list[float]],
    ) -> None:
        if left == right or len(chain) < 2:
            return
        key = (min(left, right), max(left, right))
        if key in self._edge_chains:
            return
        stored = [point[:] for point in chain]
        self._edge_chains[key] = stored
        weight = polyline_length_meters(stored)
        self._adj[left].append((right, weight))
        self._adj[right].append((left, weight))

    def find_or_add(self, lon: float, lat: float) -> int:
        return self._merge.find_or_add(lat, lon)

    def shortest_path(self, start: int, goal: int) -> list[int] | None:
        distances = {start: 0.0}
        previous: dict[int, int | None] = {start: None}
        queue: list[tuple[float, int]] = [(0.0, start)]
        while queue:
            distance, vertex = heapq.heappop(queue)
            if distance > distances.get(vertex, math.inf):
                continue
            if vertex == goal:
                break
            for neighbor, weight in self._adj[vertex]:
                next_distance = distance + weight
                if next_distance < distances.get(neighbor, math.inf):
                    distances[neighbor] = next_distance
                    previous[neighbor] = vertex
                    heapq.heappush(queue, (next_distance, neighbor))
        if goal not in previous:
            return None
        path = [goal]
        while path[-1] != start:
            path.append(previous[path[-1]])  # type: ignore[arg-type]
        path.reverse()
        return path

    def path_to_coords(self, path: list[int]) -> list[list[float]]:
        coords: list[list[float]] = []
        for index in range(len(path) - 1):
            left, right = path[index], path[index + 1]
            key = (min(left, right), max(left, right))
            chain = self._edge_chains[key]
            segment = chain if left < right else list(reversed(chain))
            if not coords:
                coords.extend(point[:] for point in segment)
            else:
                coords.extend(point[:] for point in segment[1:])
        return coords


def _fetch_overpass(query: str) -> dict[str, Any]:
    request = urllib.request.Request(
        OVERPASS_URL,
        data=query.encode("utf-8"),
        headers={"User-Agent": USER_AGENT},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            return json.loads(response.read())
    except urllib.error.URLError as error:
        raise RuntimeError(f"Overpass request failed: {error}") from error


def _parse_ways(payload: dict[str, Any]) -> list[WayRecord]:
    ways: list[WayRecord] = []
    for element in payload.get("elements", []):
        if element.get("type") != "way":
            continue
        geometry = element.get("geometry") or []
        if len(geometry) < 2:
            continue
        tags = element.get("tags") or {}
        coords = [(float(point["lon"]), float(point["lat"])) for point in geometry]
        ways.append(
            WayRecord(
                way_id=int(element["id"]),
                name=str(tags.get("name", "")),
                coordinates=coords,
            )
        )
    return ways


def _fetch_local_ways() -> list[WayRecord]:
    south, west, north, east = CAMAS_SLOUGH_BBOX
    query = f"""
    [out:json][timeout:90];
    (
      way({CAMAS_SLOUGH_WAY_ID});
      way["waterway"~"river|canal|fairway|stream"]({south},{west},{north},{east});
    );
    out geom;
    """
    ways = _parse_ways(_fetch_overpass(query))
    if not ways:
        raise RuntimeError(
            f"Overpass returned no Camas Slough ways (expected {CAMAS_SLOUGH_WAY_ID})."
        )
    return ways


def _select_slough_way(ways: list[WayRecord]) -> WayRecord:
    preferred = next(
        (way for way in ways if way.way_id == CAMAS_SLOUGH_WAY_ID),
        None,
    )
    if preferred is not None:
        return preferred
    named = [way for way in ways if "camas" in way.name.lower()]
    if len(named) == 1:
        return named[0]
    raise RuntimeError(
        f"Camas Slough way {CAMAS_SLOUGH_WAY_ID} missing; "
        f"found {len(ways)} fallback ways."
    )


def _densify_coords(coords: list[list[float]]) -> list[list[float]]:
    if len(coords) < 2:
        return coords
    out: list[list[float]] = [coords[0][:]]
    for index in range(len(coords) - 1):
        lon1, lat1 = coords[index][:2]
        lon2, lat2 = coords[index + 1][:2]
        span = haversine_meters(lat1, lon1, lat2, lon2)
        if span <= MAX_EDGE_M:
            out.append([lon2, lat2])
            continue
        steps = max(int(math.ceil(span / DENSIFY_STEP_M)), 2)
        for step in range(1, steps + 1):
            fraction = step / steps
            out.append(
                [
                    lon1 + (lon2 - lon1) * fraction,
                    lat1 + (lat2 - lat1) * fraction,
                ]
            )
    return out


def _round_coords(coords: list[list[float]]) -> list[list[float]]:
    return [[round_coord(lon), round_coord(lat)] for lon, lat in coords]


def _concat_polylines(
    first: list[list[float]],
    second: list[list[float]],
) -> list[list[float]]:
    if not first:
        return second
    if not second:
        return first
    if (
        haversine_meters(
            first[-1][1],
            first[-1][0],
            second[0][1],
            second[0][0],
        )
        <= MERGE_M
    ):
        return first + second[1:]
    return first + second


def _mainstem_coords(collection: dict[str, Any]) -> list[list[float]]:
    features = collection.get("features") or []
    if not features:
        raise RuntimeError("columbia_lower_waterway.geojson has no features.")
    geometry = features[0].get("geometry") or {}
    coords = geometry.get("coordinates") or []
    if len(coords) < 2:
        raise RuntimeError("columbia_lower mainstem must have at least two points.")
    return [[float(lon), float(lat)] for lon, lat in coords]


def _build_spur_coords(
    slough_way: WayRecord,
    ways: list[WayRecord],
    mainstem_coords: list[list[float]],
) -> list[list[float]]:
    graph = OsmGraph()
    for way in ways:
        graph.add_way(way.coordinates)

    slough_coords = [[lon, lat] for lon, lat in slough_way.coordinates]
    slough_end = tuple(slough_coords[-1])

    start_vertex = graph.find_or_add(CAMAS_SPLIT[0], CAMAS_SPLIT[1])
    goal_vertex = graph.find_or_add(slough_end[0], slough_end[1])
    path = graph.shortest_path(start_vertex, goal_vertex)
    if path is None:
        raise RuntimeError(
            "No OSM path from Camas split to Camas Slough west end."
        )

    connector = graph.path_to_coords(path)
    junction_gap = haversine_meters(
        CAMAS_SPLIT[1],
        CAMAS_SPLIT[0],
        connector[0][1],
        connector[0][0],
    )
    if junction_gap > MERGE_M:
        raise RuntimeError(
            f"Camas Slough connector start is {junction_gap:.1f} m from "
            f"Columbia mainstem; expected within {MERGE_M:.0f} m."
        )

    _, _, _, _, mainstem_gap = nearest_point_on_polyline(
        connector[0][0],
        connector[0][1],
        mainstem_coords,
    )
    if mainstem_gap > MERGE_M:
        raise RuntimeError(
            f"Camas Slough connector start is {mainstem_gap:.1f} m from bundled "
            f"mainstem geometry; expected within {MERGE_M:.0f} m."
        )

    slough_body = list(reversed(slough_coords))
    merged = prune_backtrack_loops(_concat_polylines(connector, slough_body))
    marina_gap = min(
        haversine_meters(PORT_OF_CAMAS[1], PORT_OF_CAMAS[0], point[1], point[0])
        for point in merged
    )
    if marina_gap > 900.0:
        raise RuntimeError(
            f"Port of Camas marina is {marina_gap:.1f} m from Camas Slough spur; "
            "expected within 900 m route snap threshold."
        )
    return merged


def _build_slough_feature(mainstem_coords: list[list[float]]) -> dict[str, Any]:
    ways = _fetch_local_ways()
    slough_way = _select_slough_way(ways)
    connected = _build_spur_coords(slough_way, ways, mainstem_coords)
    rounded = _round_coords(_densify_coords(connected))
    longest = max_edge_meters(rounded)
    if longest > MAX_EDGE_M:
        raise RuntimeError(
            f"Camas Slough spur longest edge {longest:.1f} m exceeds {MAX_EDGE_M:.0f} m."
        )

    marina_gap = min(
        haversine_meters(
            PORT_OF_CAMAS[1],
            PORT_OF_CAMAS[0],
            point[1],
            point[0],
        )
        for point in rounded
    )
    print(
        f"Camas Slough way {slough_way.way_id} ({slough_way.name or 'unnamed'}): "
        f"{len(rounded)} points, {polyline_length_meters(rounded)/1000:.2f} km, "
        f"marina gap {marina_gap:.1f} m"
    )

    return spur_feature(
        reach_id=SLOUGH_SPUR_REACH_ID,
        name="Camas Slough — Port of Camas marina spur (OSM)",
        source=(
            f"OpenStreetMap ODbL. Way {slough_way.way_id} "
            f"({slough_way.name or 'Camas Slough'}) plus local OSM connector to "
            "columbia_lower mainstem at Camas split."
        ),
        coordinates=rounded,
    )


def _write_lower_with_spur(
    collection: dict[str, Any],
    spur: dict[str, Any],
    asset_dir: Path,
    fixture_dir: Path,
) -> None:
    features = collection.get("features") or []
    if not features:
        raise RuntimeError("columbia_lower_waterway.geojson has no mainstem feature.")
    mainstem = features[0]
    merged = [mainstem, spur]
    for directory in (asset_dir, fixture_dir):
        write_feature_collection(
            directory / "columbia_lower_waterway.geojson",
            merged,
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Import Camas Slough spur into columbia_lower bundle.",
    )
    parser.add_argument(
        "--asset-dir",
        type=Path,
        default=bundled_hydro_dir(),
    )
    parser.add_argument(
        "--fixture-dir",
        type=Path,
        default=hydro_fixture_dir(),
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Fetch and validate without writing GeoJSON files.",
    )
    args = parser.parse_args()

    lower_path = args.asset_dir / "columbia_lower_waterway.geojson"
    if not lower_path.exists():
        parser.error(
            f"Missing {lower_path}; run fetch_columbia_waterway.py first."
        )

    collection = load_feature_collection(lower_path)
    mainstem_coords = _mainstem_coords(collection)
    spur = _build_slough_feature(mainstem_coords)

    if args.dry_run:
        print("Dry run — files not written.")
        return

    _write_lower_with_spur(collection, spur, args.asset_dir, args.fixture_dir)
    print(f"Wrote Camas Slough spur to {args.asset_dir} and {args.fixture_dir}")


if __name__ == "__main__":
    main()

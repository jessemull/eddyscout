"""Shared Overpass fetch, OSM graph, and GeoJSON write helpers."""

from __future__ import annotations

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

HYDRO_DIR = Path(__file__).resolve().parent.parent / "hydro"
sys.path.insert(0, str(HYDRO_DIR))

from _common import (  # noqa: E402
    bundled_hydro_dir,
    haversine_meters,
    hydro_fixture_dir,
    max_edge_meters,
    polyline_length_meters,
    round_coord,
    write_feature_collection,
)
from merge_index import VertexMergeIndex  # noqa: E402

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
MAX_EDGE_M = 2000.0
DENSIFY_STEP_M = 400.0
MERGE_VERTEX_M = 12.0


@dataclass(frozen=True)
class WayRecord:
    way_id: int
    name: str
    waterway: str
    coordinates: list[tuple[float, float]]


def user_agent(script_name: str) -> str:
    return f"EddyScout-hydro-import/1.0 (scripts/overpass/{script_name})"


def fetch_overpass(query: str, *, script_name: str) -> dict[str, Any]:
    request = urllib.request.Request(
        OVERPASS_URL,
        data=query.encode("utf-8"),
        headers={"User-Agent": user_agent(script_name)},
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            return json.loads(response.read())
    except urllib.error.URLError as error:
        raise RuntimeError(f"Overpass request failed: {error}") from error


def parse_ways(payload: dict[str, Any]) -> list[WayRecord]:
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
                waterway=str(tags.get("waterway", "")),
                coordinates=coords,
            )
        )
    return ways


def densify_coords(
    coords: list[list[float]],
    max_segment_m: float = DENSIFY_STEP_M,
) -> list[list[float]]:
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
        steps = max(int(math.ceil(span / max_segment_m)), 2)
        for step in range(1, steps + 1):
            fraction = step / steps
            out.append(
                [
                    lon1 + (lon2 - lon1) * fraction,
                    lat1 + (lat2 - lat1) * fraction,
                ]
            )
    return out


def round_coords(coords: list[list[float]]) -> list[list[float]]:
    return [[round_coord(lon), round_coord(lat)] for lon, lat in coords]


def concat_polylines(
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
        <= MERGE_VERTEX_M
    ):
        return first + second[1:]
    return first + second


class OsmGraph:
    def __init__(
        self,
        merge_meters: float = MERGE_VERTEX_M,
        ref_latitude: float = 45.6,
    ) -> None:
        self._merge = VertexMergeIndex(merge_meters, ref_latitude)
        self._edge_chains: dict[tuple[int, int], list[list[float]]] = {}
        self._adj: dict[int, list[tuple[int, float, list[list[float]]]]] = (
            defaultdict(list)
        )

    @property
    def vertex_count(self) -> int:
        return len(self._merge.lat)

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
        self._adj[left].append((right, weight, stored))
        self._adj[right].append((left, weight, list(reversed(stored))))

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
            for neighbor, weight, _ in self._adj[vertex]:
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


def build_graph(ways: list[WayRecord], ref_latitude: float = 45.6) -> OsmGraph:
    graph = OsmGraph(ref_latitude=ref_latitude)
    for way in ways:
        graph.add_way(way.coordinates)
    return graph


def path_coords(
    graph: OsmGraph,
    start_lonlat: tuple[float, float],
    end_lonlat: tuple[float, float],
    *,
    label: str,
) -> list[list[float]]:
    start = graph.find_or_add(start_lonlat[0], start_lonlat[1])
    goal = graph.find_or_add(end_lonlat[0], end_lonlat[1])
    path = graph.shortest_path(start, goal)
    if path is None:
        raise RuntimeError(
            f"No OSM path for {label} — check Overpass bbox or waterway coverage."
        )
    coords = graph.path_to_coords(path)
    return round_coords(densify_coords(coords))


def longest_endpoint_path(graph: OsmGraph) -> list[list[float]]:
    """Returns the longest shortest-path between low-degree vertices."""
    if graph.vertex_count < 2:
        raise RuntimeError("Graph has fewer than two vertices.")

    degrees: dict[int, int] = defaultdict(int)
    for left, right in graph._edge_chains:  # noqa: SLF001
        degrees[left] += 1
        degrees[right] += 1

    candidates = [vertex for vertex, degree in degrees.items() if degree <= 2]
    if len(candidates) < 2:
        candidates = list(degrees.keys())

    best_coords: list[list[float]] | None = None
    best_length = -1.0
    for start in candidates:
        for goal in candidates:
            if start >= goal:
                continue
            path = graph.shortest_path(start, goal)
            if path is None:
                continue
            coords = graph.path_to_coords(path)
            length = polyline_length_meters(coords)
            if length > best_length:
                best_length = length
                best_coords = coords

    if best_coords is None:
        raise RuntimeError("Could not derive a main-stem path from OSM graph.")

    return round_coords(densify_coords(best_coords))


def hydro_feature(
    *,
    river_system: str,
    reach_id: str,
    name: str,
    source: str,
    coordinates: list[list[float]],
) -> dict[str, Any]:
    return {
        "type": "Feature",
        "properties": {
            "river_system": river_system,
            "reach_id": reach_id,
            "name": name,
            "source": source,
        },
        "geometry": {
            "type": "LineString",
            "coordinates": coordinates,
        },
    }


def validate_coords(label: str, coords: list[list[float]]) -> None:
    longest = max_edge_meters(coords)
    if longest > MAX_EDGE_M:
        raise RuntimeError(
            f"{label}: longest edge {longest:.1f} m exceeds {MAX_EDGE_M:.0f} m "
            "after densify — review OSM geometry or import parameters."
        )


def write_waterway_file(
    file_name: str,
    features: list[dict[str, Any]],
    *,
    asset_dir: Path | None = None,
    fixture_dir: Path | None = None,
) -> None:
    assets = asset_dir or bundled_hydro_dir()
    fixtures = fixture_dir or hydro_fixture_dir()
    for directory in (assets, fixtures):
        write_feature_collection(directory / file_name, features)


def extend_toward_anchor(
    coords: list[list[float]],
    anchor_lonlat: tuple[float, float],
    *,
    max_connector_m: float = 2000.0,
) -> list[list[float]]:
    """Inserts a densified connector from the nearest polyline point to [anchor]."""
    if not coords:
        return coords
    best_index = 0
    best_gap = float("inf")
    for index, (lon, lat) in enumerate(coords):
        gap = haversine_meters(lat, lon, anchor_lonlat[1], anchor_lonlat[0])
        if gap < best_gap:
            best_gap = gap
            best_index = index
    if best_gap <= MERGE_VERTEX_M:
        return round_coords(coords)
    if best_gap > max_connector_m:
        return round_coords(coords)
    nearest = coords[best_index]
    connector = densify_coords(
        [
            [nearest[0], nearest[1]],
            [anchor_lonlat[0], anchor_lonlat[1]],
        ]
    )
    if len(connector) < 2:
        return round_coords(coords)
    tail = coords[best_index + 1 :]
    merged = concat_polylines(
        coords[: best_index + 1],
        concat_polylines(connector, tail),
    )
    return round_coords(merged)


def extend_nearest_end_to_anchor(
    coords: list[list[float]],
    anchor_lonlat: tuple[float, float],
    *,
    max_connector_m: float = 2000.0,
) -> list[list[float]]:
    if not coords:
        return coords
    start_lon, start_lat = coords[0][:2]
    end_lon, end_lat = coords[-1][:2]
    start_gap = haversine_meters(
        start_lat,
        start_lon,
        anchor_lonlat[1],
        anchor_lonlat[0],
    )
    end_gap = haversine_meters(
        end_lat,
        end_lon,
        anchor_lonlat[1],
        anchor_lonlat[0],
    )
    if end_gap <= start_gap:
        return extend_polyline_to_anchor(
            coords,
            anchor_lonlat,
            max_connector_m=max_connector_m,
        )
    if start_gap <= MERGE_VERTEX_M:
        return round_coords(coords)
    if start_gap > max_connector_m:
        return round_coords(coords)
    connector = round_coords(
        densify_coords(
            [
                [anchor_lonlat[0], anchor_lonlat[1]],
                [start_lon, start_lat],
            ]
        )
    )
    return round_coords(concat_polylines(connector, coords))


def extend_polyline_to_anchor(
    coords: list[list[float]],
    anchor_lonlat: tuple[float, float],
    *,
    max_connector_m: float = 2000.0,
) -> list[list[float]]:
    """Appends a densified segment when the anchor is near but off the polyline end."""
    if not coords:
        return coords
    end_lon, end_lat = coords[-1][:2]
    gap = haversine_meters(end_lat, end_lon, anchor_lonlat[1], anchor_lonlat[0])
    if gap <= MERGE_VERTEX_M:
        return round_coords(coords)
    if gap > max_connector_m:
        return round_coords(coords)
    connector = round_coords(
        densify_coords(
            [
                [end_lon, end_lat],
                [anchor_lonlat[0], anchor_lonlat[1]],
            ]
        )
    )
    return round_coords(concat_polylines(coords, connector))


def longest_single_way_coords(ways: list[WayRecord]) -> list[list[float]]:
    """Uses the longest individual OSM way when the graph is fragmented."""
    if not ways:
        raise RuntimeError("No ways provided.")
    best = max(
        ways,
        key=lambda way: polyline_length_meters(
            [[lon, lat] for lon, lat in way.coordinates]
        ),
    )
    raw = [[lon, lat] for lon, lat in best.coordinates]
    return round_coords(densify_coords(raw))

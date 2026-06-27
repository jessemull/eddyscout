#!/usr/bin/env python3
"""Fetch and merge Columbia waterway centerlines from OpenStreetMap Overpass."""

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
    polyline_length_meters,
    round_coord,
    write_feature_collection,
)
from merge_index import VertexMergeIndex  # noqa: E402

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
USER_AGENT = "EddyScout-hydro-import/1.0 (scripts/overpass/fetch_columbia_waterway.py)"

CAMAS_SPLIT = (-122.4300244, 45.5659948)
GORGE_END = (-122.3858, 45.5365)
COLUMBIA_MAIN_WAY_ID = 163917830
SANDY_TAIL_WAY_ID = 128946456
SANDY_JUNCTION = (-122.4017553, 45.5691143)
WASHOUGAL_LAUNCH = (-122.377814, 45.578087)
ST_HELEN_LAUNCH = (-122.798392, 45.867213)
FRENCHMANS_LAUNCH = (-122.762164, 45.684178)
SAUVIE_LAUNCH = (-122.838703, 45.653674)
SCAPPOOSE_LAUNCH = (-122.839828, 45.828824)
MULTNOMAH_WAYPOINTS = (
    SAUVIE_LAUNCH,
    FRENCHMANS_LAUNCH,
    SCAPPOOSE_LAUNCH,
)
MAX_EDGE_M = 2000.0
DENSIFY_STEP_M = 400.0


@dataclass(frozen=True)
class WayRecord:
    way_id: int
    name: str
    waterway: str
    coordinates: list[tuple[float, float]]


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
                waterway=str(tags.get("waterway", "")),
                coordinates=coords,
            )
        )
    return ways


def _willamette_mouth(willamette_path: Path) -> tuple[float, float]:
    collection = load_feature_collection(willamette_path)
    features = collection.get("features") or []
    if not features:
        raise RuntimeError(f"No features in {willamette_path}")
    coords = features[0]["geometry"]["coordinates"]
    end = coords[-1]
    return float(end[0]), float(end[1])


def _densify_coords(
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
        <= 12.0
    ):
        return first + second[1:]
    return first + second


class OsmGraph:
    def __init__(self, merge_meters: float = 12.0, ref_latitude: float = 45.6) -> None:
        self._merge = VertexMergeIndex(merge_meters, ref_latitude)
        self._edge_chains: dict[tuple[int, int], list[list[float]]] = {}
        self._adj: dict[int, list[tuple[int, float, list[list[float]]]]] = defaultdict(list)

    @property
    def vertex_count(self) -> int:
        return len(self._merge.lat)

    def add_way(self, coordinates: list[tuple[float, float]]) -> None:
        if len(coordinates) < 2:
            return
        verts = [
            self._merge.find_or_add(lat, lon) for lon, lat in coordinates
        ]
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


def _build_graph(ways: list[WayRecord]) -> OsmGraph:
    graph = OsmGraph()
    for way in ways:
        graph.add_way(way.coordinates)
    return graph


def _way_subline(
    way: WayRecord,
    start_lonlat: tuple[float, float],
    end_lonlat: tuple[float, float],
) -> list[list[float]]:
    coords = way.coordinates
    start_index = min(
        range(len(coords)),
        key=lambda index: haversine_meters(
            start_lonlat[1],
            start_lonlat[0],
            coords[index][1],
            coords[index][0],
        ),
    )
    end_index = min(
        range(len(coords)),
        key=lambda index: haversine_meters(
            end_lonlat[1],
            end_lonlat[0],
            coords[index][1],
            coords[index][0],
        ),
    )
    if start_index <= end_index:
        segment = coords[start_index : end_index + 1]
    else:
        segment = list(reversed(coords[end_index : start_index + 1]))
    return [[lon, lat] for lon, lat in segment]


def _build_lower_coords(
    graph: OsmGraph,
    mouth: tuple[float, float],
    camas: tuple[float, float],
) -> list[list[float]]:
    start = graph.find_or_add(mouth[0], mouth[1])
    goal = graph.find_or_add(camas[0], camas[1])
    path = graph.shortest_path(start, goal)
    if path is None:
        raise RuntimeError(
            "No OSM path from Willamette mouth to Camas split — "
            "check Overpass bbox or waterway coverage."
        )
    coords = graph.path_to_coords(path)
    mouth_gap = haversine_meters(mouth[1], mouth[0], coords[0][1], coords[0][0])
    if mouth_gap > 12.0:
        raise RuntimeError(
            f"Lower Columbia start is {mouth_gap:.1f} m from Willamette mouth; "
            "expected shared OSM/NHD vertex within 12 m."
        )
    return _round_coords(_densify_coords(coords))


def _build_gorge_coords(
    ways: list[WayRecord],
    camas: tuple[float, float],
    gorge_end: tuple[float, float],
) -> list[list[float]]:
    main_way = next((way for way in ways if way.way_id == COLUMBIA_MAIN_WAY_ID), None)
    sandy_way = next((way for way in ways if way.way_id == SANDY_TAIL_WAY_ID), None)
    if main_way is None:
        raise RuntimeError(
            f"Overpass result missing Columbia main way {COLUMBIA_MAIN_WAY_ID}."
        )
    if sandy_way is None:
        raise RuntimeError(
            f"Overpass result missing Sandy River tail way {SANDY_TAIL_WAY_ID}."
        )

    columbia_coords = main_way.coordinates
    washougal_nearest = min(
        columbia_coords,
        key=lambda point: haversine_meters(
            WASHOUGAL_LAUNCH[1],
            WASHOUGAL_LAUNCH[0],
            point[1],
            point[0],
        ),
    )
    mainstem_head = _way_subline(main_way, camas, washougal_nearest)
    mainstem_mid = _way_subline(main_way, washougal_nearest, SANDY_JUNCTION)
    sandy_coords = sandy_way.coordinates
    sandy_start = min(
        range(len(sandy_coords)),
        key=lambda index: haversine_meters(
            SANDY_JUNCTION[1],
            SANDY_JUNCTION[0],
            sandy_coords[index][1],
            sandy_coords[index][0],
        ),
    )
    sandy_end = min(
        range(len(sandy_coords)),
        key=lambda index: haversine_meters(
            gorge_end[1],
            gorge_end[0],
            sandy_coords[index][1],
            sandy_coords[index][0],
        ),
    )
    if sandy_start <= sandy_end:
        sandy_segment = sandy_coords[sandy_start : sandy_end + 1]
    else:
        sandy_segment = list(reversed(sandy_coords[sandy_end : sandy_start + 1]))
    sandy_tail = [[lon, lat] for lon, lat in sandy_segment]

    junction_gap = haversine_meters(
        mainstem_head[-1][1],
        mainstem_head[-1][0],
        mainstem_mid[0][1],
        mainstem_mid[0][0],
    )
    if junction_gap > 12.0:
        raise RuntimeError(
            f"Columbia mainstem junction gap {junction_gap:.1f} m exceeds 12 m."
        )

    sandy_junction_gap = haversine_meters(
        mainstem_mid[-1][1],
        mainstem_mid[-1][0],
        sandy_tail[0][1],
        sandy_tail[0][0],
    )
    if sandy_junction_gap > 12.0:
        raise RuntimeError(
            f"Columbia/Sandy junction gap {sandy_junction_gap:.1f} m exceeds 12 m — "
            "expected shared OSM vertex at Sandy River mouth."
        )

    merged = _concat_polylines(
        _concat_polylines(mainstem_head, mainstem_mid),
        sandy_tail,
    )
    merged_coords = _round_coords(_densify_coords(merged))
    return _append_launch_spur(merged_coords, WASHOUGAL_LAUNCH)


def _nearest_on_ways(
    ways: list[WayRecord],
    lonlat: tuple[float, float],
    *,
    max_m: float = 900,
) -> tuple[float, float]:
    best = lonlat
    best_d = float("inf")
    for way in ways:
        for lon, lat in way.coordinates:
            distance = haversine_meters(lonlat[1], lonlat[0], lat, lon)
            if distance < best_d:
                best_d = distance
                best = (lon, lat)
    if best_d > max_m:
        raise RuntimeError(
            f"No way point within {max_m:.0f} m of {lonlat} (nearest {best_d:.0f} m)."
        )
    return best


def _append_launch_spur(
    coords: list[list[float]],
    launch: tuple[float, float],
) -> list[list[float]]:
    """Append a marina coordinate when the line passes within routing snap range."""
    lon, lat = launch
    best_d = min(
        haversine_meters(lat, lon, point[1], point[0]) for point in coords
    )
    if best_d <= 900:
        return coords
    end = coords[-1]
    spur = haversine_meters(end[1], end[0], lat, lon)
    if spur > MAX_EDGE_M:
        raise RuntimeError(
            f"Launch spur from line end to {launch} is {spur:.0f} m; "
            f"max {MAX_EDGE_M:.0f} m."
        )
    return coords + [[round_coord(lon), round_coord(lat)]]


def _launch_spur_segment(
    coords: list[list[float]],
    launch: tuple[float, float],
) -> list[list[float]] | None:
    """Return a two-point spur when [launch] is beyond snap range of [coords]."""
    lon, lat = launch
    nearest = min(
        coords,
        key=lambda point: haversine_meters(lat, lon, point[1], point[0]),
    )
    best_d = haversine_meters(lat, lon, nearest[1], nearest[0])
    if best_d <= 900:
        return None
    spur = haversine_meters(nearest[1], nearest[0], lat, lon)
    if spur > MAX_EDGE_M:
        print(
            f"Warning: skip launch spur to {launch} — {spur:.0f} m from nearest "
            f"line point (max {MAX_EDGE_M:.0f} m)."
        )
        return None
    return [
        [round_coord(nearest[0]), round_coord(nearest[1])],
        [round_coord(lon), round_coord(lat)],
    ]


def _build_path_through(
    graph: OsmGraph,
    ways: list[WayRecord],
    points: list[tuple[float, float]],
    *,
    snap_max_m: float = 2000,
) -> list[list[float]]:
    """Concatenate shortest OSM paths between ordered lon/lat anchors."""
    if len(points) < 2:
        raise ValueError("Need at least two path anchors.")

    merged: list[list[float]] = []
    for start_lonlat, goal_lonlat in zip(points, points[1:]):
        start_pt = _nearest_on_ways(ways, start_lonlat, max_m=snap_max_m)
        goal_pt = _nearest_on_ways(ways, goal_lonlat, max_m=snap_max_m)
        start = graph.find_or_add(start_pt[0], start_pt[1])
        goal = graph.find_or_add(goal_pt[0], goal_pt[1])
        path = graph.shortest_path(start, goal)
        if path is None:
            raise RuntimeError(
                f"No OSM path from {start_lonlat} to {goal_lonlat}."
            )
        segment = graph.path_to_coords(path)
        merged = _concat_polylines(merged, segment) if merged else segment

    return merged


def _build_multnomah_coords(
    graph: OsmGraph,
    ways: list[WayRecord],
    mouth: tuple[float, float],
    north_launch: tuple[float, float],
) -> list[list[float]]:
    mouth_pt = _nearest_on_ways(ways, mouth, max_m=100)
    anchors = [mouth_pt, *MULTNOMAH_WAYPOINTS, north_launch]
    coords = _build_path_through(graph, ways, anchors)
    mouth_gap = haversine_meters(
        mouth[1],
        mouth[0],
        coords[0][1],
        coords[0][0],
    )
    if mouth_gap > 12.0:
        raise RuntimeError(
            f"Multnomah start is {mouth_gap:.1f} m from Willamette mouth; "
            "expected shared OSM vertex within 12 m."
        )
    coords = _append_launch_spur(coords, north_launch)
    return _round_coords(_densify_coords(coords))


def _feature(
    *,
    reach_id: str,
    name: str,
    source: str,
    coordinates: list[list[float]],
) -> dict[str, Any]:
    return {
        "type": "Feature",
        "properties": {
            "river_system": "columbia",
            "reach_id": reach_id,
            "name": name,
            "source": source,
        },
        "geometry": {
            "type": "LineString",
            "coordinates": coordinates,
        },
    }


def _validate_coords(label: str, coords: list[list[float]]) -> None:
    longest = max_edge_meters(coords)
    if longest > MAX_EDGE_M:
        raise RuntimeError(
            f"{label}: longest edge {longest:.1f} m exceeds {MAX_EDGE_M:.0f} m "
            "after densify — review OSM geometry or import parameters."
        )


def _write_outputs(
    lower: list[list[float]],
    gorge: list[list[float]],
    multnomah: list[list[float]],
    multnomah_spurs: list[list[list[float]]],
    asset_dir: Path,
    fixture_dir: Path,
) -> None:
    lower_feature = _feature(
        reach_id="columbia_lower",
        name="Columbia mainstem — Willamette mouth to Camas (OSM merged)",
        source=(
            "OpenStreetMap ODbL. Overpass merge of connected waterway=river|canal|fairway "
            "ways; shortest path from Willamette mouth to Camas split."
        ),
        coordinates=lower,
    )
    gorge_feature = _feature(
        reach_id="columbia_gorge",
        name="Columbia mainstem — Camas to Glenn Otto (OSM merged)",
        source=(
            "OpenStreetMap ODbL. Way 163917830 mainstem subline plus connected "
            "Sandy River / side-channel ways to Glenn Otto Park anchor."
        ),
        coordinates=gorge,
    )
    multnomah_feature = _feature(
        reach_id="columbia_multnomah",
        name="Multnomah Channel — Willamette mouth to St. Helens pool (OSM merged)",
        source=(
            "OpenStreetMap ODbL. Shortest path on connected waterway graph from "
            "Willamette mouth through Multnomah Channel to St. Helens marina anchor."
        ),
        coordinates=multnomah,
    )
    multnomah_features = [multnomah_feature]
    for index, spur in enumerate(multnomah_spurs):
        multnomah_features.append(
            _feature(
                reach_id=f"columbia_multnomah_spur_{index}",
                name="Columbia / Multnomah marina spur (OSM + catalog anchor)",
                source=(
                    "OpenStreetMap ODbL centerline anchor with catalog launch "
                    "coordinate appended for routing snap."
                ),
                coordinates=spur,
            )
        )
    for directory in (asset_dir, fixture_dir):
        write_feature_collection(directory / "columbia_lower_waterway.geojson", [lower_feature])
        write_feature_collection(directory / "columbia_gorge_waterway.geojson", [gorge_feature])
        write_feature_collection(
            directory / "columbia_multnomah_waterway.geojson",
            multnomah_features,
        )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Import Columbia lower + gorge reaches from OSM.",
    )
    parser.add_argument(
        "--willamette-path",
        type=Path,
        default=bundled_hydro_dir() / "willamette_waterway.geojson",
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

    mouth = _willamette_mouth(args.willamette_path)
    print(f"Willamette mouth anchor: {mouth[0]:.7f}, {mouth[1]:.7f}")

    query = """
    [out:json][timeout:90];
    (
      way["waterway"~"river|canal|fairway"](45.45,-123.00,45.80,-122.20);
    );
    out geom;
    """
    payload = _fetch_overpass(query)
    ways = _parse_ways(payload)
    if not ways:
        parser.error("Overpass returned no waterway ways.")

    graph = _build_graph(ways)
    print(f"OSM graph: {len(ways)} ways, {graph.vertex_count} merged vertices")

    north_query = """
    [out:json][timeout:90];
    (
      way["waterway"~"river|canal|fairway"](45.60,-122.95,45.90,-122.55);
    );
    out geom;
    """
    north_ways = _parse_ways(_fetch_overpass(north_query))
    if not north_ways:
        parser.error("Overpass returned no north Columbia / Multnomah ways.")
    north_graph = _build_graph(north_ways)
    print(
        f"North OSM graph: {len(north_ways)} ways, "
        f"{north_graph.vertex_count} merged vertices"
    )
    combined_graph = _build_graph(ways + north_ways)
    print(
        f"Combined OSM graph: {len(ways) + len(north_ways)} ways, "
        f"{combined_graph.vertex_count} merged vertices"
    )

    lower = _build_lower_coords(graph, mouth, CAMAS_SPLIT)
    gorge = _build_gorge_coords(ways, CAMAS_SPLIT, GORGE_END)
    multnomah = _build_multnomah_coords(
        combined_graph,
        ways + north_ways,
        mouth,
        ST_HELEN_LAUNCH,
    )
    multnomah_spurs = []
    for launch in (FRENCHMANS_LAUNCH, SCAPPOOSE_LAUNCH):
        spur = _launch_spur_segment(multnomah, launch)
        if spur is not None:
            multnomah_spurs.append(spur)
    _validate_coords("columbia_lower", lower)
    _validate_coords("columbia_gorge", gorge)
    _validate_coords("columbia_multnomah", multnomah)

    for index, spur in enumerate(multnomah_spurs):
        _validate_coords(f"columbia_multnomah_spur_{index}", spur)

    lower_gap = haversine_meters(
        mouth[1],
        mouth[0],
        lower[0][1],
        lower[0][0],
    )
    split_gap = haversine_meters(
        lower[-1][1],
        lower[-1][0],
        gorge[0][1],
        gorge[0][0],
    )
    print(
        f"Lower: {len(lower)} points, {polyline_length_meters(lower)/1000:.1f} km, "
        f"mouth gap {lower_gap:.2f} m"
    )
    print(
        f"Gorge: {len(gorge)} points, {polyline_length_meters(gorge)/1000:.1f} km, "
        f"split gap {split_gap:.2f} m"
    )
    print(
        f"Multnomah: {len(multnomah)} points, "
        f"{polyline_length_meters(multnomah)/1000:.1f} km"
    )

    if args.dry_run:
        print("Dry run — files not written.")
        return

    _write_outputs(
        lower,
        gorge,
        multnomah,
        multnomah_spurs,
        args.asset_dir,
        args.fixture_dir,
    )
    print(f"Wrote {args.asset_dir} and {args.fixture_dir}")


if __name__ == "__main__":
    main()

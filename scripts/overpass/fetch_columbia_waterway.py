#!/usr/bin/env python3
"""Fetch and merge Columbia waterway centerlines from OpenStreetMap Overpass."""

from __future__ import annotations

import argparse
import heapq
import json
import math
import sys
from collections import defaultdict
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
    polyline_length_meters,
    write_feature_collection,
)
from merge_index import VertexMergeIndex  # noqa: E402

sys.path.insert(0, str(SCRIPT_DIR))
from _overpass_common import (  # noqa: E402
    WayRecord,
    densify_coords,
    extend_toward_anchor,
    fetch_overpass,
    parse_ways,
    round_coords,
    validate_coords,
)

SCRIPT_NAME = "fetch_columbia_waterway.py"

CAMAS_SPLIT = (-122.4300244, 45.5659948)
PORT_OF_CAMAS = (-122.4244, 45.5856)
GORGE_END = (-122.3858, 45.5365)
COLUMBIA_MAIN_WAY_ID = 163917830
SANDY_TAIL_WAY_ID = 128946456
SANDY_JUNCTION = (-122.4017553, 45.5691143)
WASHOUGAL_LAUNCH = (-122.3870, 45.5791)
MAINSTEM_JOIN = (-122.7633908, 45.659415)
VANCOUVER_WINTLER = (-122.6558, 45.6275)
SCAPPOOSE_BAY = (-122.8495, 45.7580)
ST_HELENS_MARINA = (-122.7974, 45.8642)
FRENCHMANS_BAR = (-122.6332, 45.8317)
MULTNOMAH_CHANNEL_WAY_ID = 420655001
MAX_EDGE_M = 2000.0
DENSIFY_STEP_M = 400.0
MERGE_VERTEX_M = 12.0


def _willamette_mouth(willamette_path: Path) -> tuple[float, float]:
    collection = load_feature_collection(willamette_path)
    features = collection.get("features") or []
    if not features:
        raise RuntimeError(f"No features in {willamette_path}")
    coords = features[0]["geometry"]["coordinates"]
    end = coords[-1]
    return float(end[0]), float(end[1])


def _finalize_coords(coords: list[list[float]]) -> list[list[float]]:
    return round_coords(densify_coords(round_coords(densify_coords(coords))))


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


def _nearest_index(
    coords: list[list[float]],
    anchor: tuple[float, float],
) -> int:
    return min(
        range(len(coords)),
        key=lambda index: haversine_meters(
            anchor[1],
            anchor[0],
            coords[index][1],
            coords[index][0],
        ),
    )


def _slice_polyline(
    coords: list[list[float]],
    start_index: int,
    end_index: int,
) -> list[list[float]]:
    if start_index <= end_index:
        return [point[:] for point in coords[start_index : end_index + 1]]
    return [point[:] for point in reversed(coords[end_index : start_index + 1])]


def _connect_spur_to_mainstem(
    spur: list[list[float]],
    *,
    join: tuple[float, float] = MAINSTEM_JOIN,
) -> list[list[float]]:
    connector = _finalize_coords(
        densify_coords([[join[0], join[1]], spur[0]]),
    )
    if (
        haversine_meters(
            connector[-1][1],
            connector[-1][0],
            spur[0][1],
            spur[0][0],
        )
        <= MERGE_VERTEX_M
    ):
        merged = connector[:-1] + spur
    else:
        merged = connector + spur[1:]
    return _finalize_coords(merged)


def _multnomah_channel_way(ways: list[WayRecord]) -> WayRecord:
    match = next((way for way in ways if way.way_id == MULTNOMAH_CHANNEL_WAY_ID), None)
    if match is not None:
        return match
    payload = fetch_overpass(
        f"[out:json][timeout:90];way(id:{MULTNOMAH_CHANNEL_WAY_ID});out geom;",
        script_name=SCRIPT_NAME,
    )
    parsed = parse_ways(payload)
    if not parsed:
        raise RuntimeError(
            f"Overpass returned no geometry for Multnomah Channel way "
            f"{MULTNOMAH_CHANNEL_WAY_ID}."
        )
    return parsed[0]


def _build_vancouver_wintler_spur(mainstem: list[list[float]]) -> list[list[float]]:
    """Side branch for Wintler launch — must not be inlined into the mainstem."""
    join_index = _nearest_index(mainstem, VANCOUVER_WINTLER)
    join = mainstem[join_index]
    return _finalize_coords(
        densify_coords(
            [
                [join[0], join[1]],
                [VANCOUVER_WINTLER[0], VANCOUVER_WINTLER[1]],
            ],
        ),
    )


def _build_multnomah_scappoose_spur(ways: list[WayRecord]) -> list[list[float]]:
    channel = _multnomah_channel_way(ways)
    coords = [[lon, lat] for lon, lat in channel.coordinates]
    main_index = _nearest_index(coords, MAINSTEM_JOIN)
    scappoose_index = _nearest_index(coords, SCAPPOOSE_BAY)
    segment = _slice_polyline(coords, main_index, scappoose_index)
    spur = _finalize_coords(
        extend_toward_anchor(
            round_coords(densify_coords(segment)),
            SCAPPOOSE_BAY,
            max_connector_m=2000.0,
        ),
    )
    return _connect_spur_to_mainstem(spur)


def _build_north_pool_spur() -> list[list[float]]:
    pool_query = """
    [out:json][timeout:90];
    way["waterway"="river"]["name"~"Columbia",i](45.60,-122.85,45.90,-122.55);
    out geom;
    """
    pool_ways = parse_ways(
        fetch_overpass(pool_query, script_name=SCRIPT_NAME),
    )
    if not pool_ways:
        raise RuntimeError("No Columbia River ways for lower-pool spur.")
    main_way = max(
        pool_ways,
        key=lambda way: polyline_length_meters(
            [[lon, lat] for lon, lat in way.coordinates],
        ),
    )
    coords = [[lon, lat] for lon, lat in main_way.coordinates]
    join_index = _nearest_index(coords, MAINSTEM_JOIN)
    st_helens_index = _nearest_index(coords, ST_HELENS_MARINA)
    segment = _slice_polyline(coords, join_index, st_helens_index)
    spur = _finalize_coords(
        extend_toward_anchor(
            round_coords(densify_coords(segment)),
            ST_HELENS_MARINA,
            max_connector_m=2500.0,
        ),
    )
    spur = _finalize_coords(
        extend_toward_anchor(spur, FRENCHMANS_BAR, max_connector_m=12000.0),
    )
    return _connect_spur_to_mainstem(spur)


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
    return round_coords(densify_coords(coords))


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
    mainstem_head = _way_subline(main_way, PORT_OF_CAMAS, washougal_nearest)
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
    rounded = round_coords(densify_coords(merged))
    return round_coords(
        densify_coords(extend_toward_anchor(rounded, PORT_OF_CAMAS, max_connector_m=2300.0))
    )


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


def _build_lower_features(
    lower: list[list[float]],
    ways: list[WayRecord],
) -> list[dict[str, Any]]:
    mainstem = _finalize_coords(lower)
    vancouver_spur = _build_vancouver_wintler_spur(mainstem)
    multnomah = _build_multnomah_scappoose_spur(ways)
    north_pool = _build_north_pool_spur()
    validate_coords("columbia_lower", mainstem)
    validate_coords("vancouver_wintler_spur", vancouver_spur)
    validate_coords("multnomah_channel_scappoose", multnomah)
    validate_coords("columbia_lower_pool_north", north_pool)
    return [
        _feature(
            reach_id="columbia_lower",
            name="Columbia mainstem — Willamette mouth to Camas (OSM merged)",
            source=(
                "OpenStreetMap ODbL. Overpass merge of connected "
                "waterway=river|canal|fairway ways; shortest path from "
                "Willamette mouth to Camas split."
            ),
            coordinates=mainstem,
        ),
        _feature(
            reach_id="vancouver_wintler_spur",
            name="Columbia — Wintler Community Park launch spur",
            source=(
                "OpenStreetMap ODbL. Connector from Columbia mainstem to "
                "Wintler Community Park catalog launch anchor."
            ),
            coordinates=vancouver_spur,
        ),
        _feature(
            reach_id="multnomah_channel_scappoose",
            name="Multnomah Channel — Scappoose Bay spur (OSM way 420655001)",
            source=(
                "OpenStreetMap ODbL. Subline of Multnomah Channel way 420655001 "
                "with connector to Columbia lower mainstem."
            ),
            coordinates=multnomah,
        ),
        _feature(
            reach_id="columbia_lower_pool_north",
            name="Columbia lower pool — St Helens to Frenchman's Bar (OSM Columbia River)",
            source=(
                "OpenStreetMap ODbL. Subline of Columbia River ways with "
                "connectors to lower mainstem and catalog launch anchors."
            ),
            coordinates=north_pool,
        ),
    ]


def _write_outputs(
    lower_features: list[dict[str, Any]],
    gorge: list[list[float]],
    asset_dir: Path,
    fixture_dir: Path,
) -> None:
    gorge_feature = _feature(
        reach_id="columbia_gorge",
        name="Columbia mainstem — Camas to Glenn Otto (OSM merged)",
        source=(
            "OpenStreetMap ODbL. Way 163917830 mainstem subline plus connected "
            "Sandy River / side-channel ways to Glenn Otto Park anchor."
        ),
        coordinates=gorge,
    )
    for directory in (asset_dir, fixture_dir):
        write_feature_collection(
            directory / "columbia_lower_waterway.geojson",
            lower_features,
        )
        write_feature_collection(
            directory / "columbia_gorge_waterway.geojson",
            [gorge_feature],
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
    payload = fetch_overpass(query, script_name=SCRIPT_NAME)
    ways = parse_ways(payload)
    if not ways:
        parser.error("Overpass returned no waterway ways.")

    graph = _build_graph(ways)
    print(f"OSM graph: {len(ways)} ways, {graph.vertex_count} merged vertices")

    lower = _build_lower_coords(graph, mouth, CAMAS_SPLIT)
    gorge = _build_gorge_coords(ways, CAMAS_SPLIT, GORGE_END)
    lower_features = _build_lower_features(lower, ways)
    validate_coords("columbia_gorge", gorge)

    mainstem = lower_features[0]["geometry"]["coordinates"]
    lower_gap = haversine_meters(
        mouth[1],
        mouth[0],
        mainstem[0][1],
        mainstem[0][0],
    )
    split_gap = haversine_meters(
        mainstem[-1][1],
        mainstem[-1][0],
        gorge[0][1],
        gorge[0][0],
    )
    print(
        f"Lower: {len(mainstem)} points, "
        f"{polyline_length_meters(mainstem)/1000:.1f} km, "
        f"mouth gap {lower_gap:.2f} m "
        f"(+ {len(lower_features) - 1} launch spurs)"
    )
    print(
        f"Gorge: {len(gorge)} points, {polyline_length_meters(gorge)/1000:.1f} km, "
        f"split gap {split_gap:.2f} m"
    )

    if args.dry_run:
        print("Dry run — files not written.")
        return

    _write_outputs(lower_features, gorge, args.asset_dir, args.fixture_dir)
    print(f"Wrote {args.asset_dir} and {args.fixture_dir}")


if __name__ == "__main__":
    main()

"""Fast vertex merge index matching RiverLineGraph 12 m threshold."""

from __future__ import annotations

from collections import defaultdict

from _common import haversine_meters


class VertexMergeIndex:
    def __init__(self, merge_meters: float = 12.0, ref_latitude: float = 45.0) -> None:
        self._merge_meters = merge_meters
        meters_per_degree_lat = 111_320.0
        meters_per_degree_lon = max(
            meters_per_degree_lat * abs(__import__("math").cos(__import__("math").radians(ref_latitude))),
            1.0,
        )
        self._cell_lat = merge_meters / meters_per_degree_lat
        self._cell_lon = merge_meters / meters_per_degree_lon
        self.lat: list[float] = []
        self.lon: list[float] = []
        self._grid: dict[tuple[int, int], list[int]] = defaultdict(list)

    def _cell_key(self, lat_deg: float, lon_deg: float) -> tuple[int, int]:
        return (int(lat_deg / self._cell_lat), int(lon_deg / self._cell_lon))

    def find_or_add(self, lat_deg: float, lon_deg: float) -> int:
        cell = self._cell_key(lat_deg, lon_deg)
        for row_offset in (-1, 0, 1):
            for col_offset in (-1, 0, 1):
                for index in self._grid.get(
                    (cell[0] + row_offset, cell[1] + col_offset),
                    [],
                ):
                    if (
                        haversine_meters(
                            self.lat[index],
                            self.lon[index],
                            lat_deg,
                            lon_deg,
                        )
                        <= self._merge_meters
                    ):
                        return index
        index = len(self.lat)
        self.lat.append(lat_deg)
        self.lon.append(lon_deg)
        self._grid[cell].append(index)
        return index

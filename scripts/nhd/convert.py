#!/usr/bin/env python3
"""Convert NHD NHDFlowline shapefiles to EddyScout hydro GeoJSON."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import click
import fiona
from pyproj import Transformer
from shapely.geometry import LineString, shape
from shapely.ops import transform

from _common import (
    classify_river_system,
    find_nhd_flowline_shapefiles,
    load_config,
    polyline_length_meters,
    property_lookup,
    round_coord,
    script_dir,
    write_feature_collection,
)


def _within_bbox(
    line: LineString,
    bbox: dict[str, float],
) -> bool:
    min_lon = bbox["min_lon"]
    min_lat = bbox["min_lat"]
    max_lon = bbox["max_lon"]
    max_lat = bbox["max_lat"]
    west, south, east, north = line.bounds
    if east < min_lon or west > max_lon:
        return False
    if north < min_lat or south > max_lat:
        return False
    return True


def _to_wgs84(
    geometry: Any,
    source_crs: str | None,
) -> LineString:
    if source_crs is None:
        return geometry
    transformer = Transformer.from_crs(source_crs, "EPSG:4326", always_xy=True)
    return transform(transformer.transform, geometry)


def _simplify_meters(
    geometry: LineString,
    tolerance_meters: float,
    utm_epsg: int,
) -> LineString:
    to_utm = Transformer.from_crs("EPSG:4326", f"EPSG:{utm_epsg}", always_xy=True)
    to_wgs = Transformer.from_crs(f"EPSG:{utm_epsg}", "EPSG:4326", always_xy=True)
    utm_geom = transform(to_utm.transform, geometry)
    simplified = utm_geom.simplify(tolerance_meters, preserve_topology=True)
    return transform(to_wgs.transform, simplified)


def _linestring_coords(
    geometry: LineString,
    precision: int,
) -> list[list[float]]:
    coords: list[list[float]] = []
    for lon, lat in geometry.coords:
        coords.append(
            [
                round_coord(float(lon), precision),
                round_coord(float(lat), precision),
            ]
        )
    return coords


def _build_feature(
    geometry: LineString,
    gnis_name: str | None,
    reach_code: str | None,
    river_system: str,
    precision: int,
) -> dict[str, Any] | None:
    coords = _linestring_coords(geometry, precision)
    if len(coords) < 2:
        return None

    display_name = gnis_name or river_system.title()
    reach_suffix = reach_code or "unknown"
    return {
        "type": "Feature",
        "properties": {
            "river_system": river_system,
            "reach_id": reach_suffix,
            "name": f"{display_name} (NHD flowline)",
            "source": (
                "USGS National Hydrography Dataset (NHD) High Resolution. "
                f"NHDFlowline ReachCode {reach_suffix}."
            ),
        },
        "geometry": {
            "type": "LineString",
            "coordinates": coords,
        },
    }


def convert_shapefile(
    shapefile: Path,
    config: dict[str, Any],
    *,
    simplify: bool,
    only_system: str | None,
) -> tuple[dict[str, list[dict[str, Any]]], dict[str, int]]:
    bbox = config["portland_metro_bbox"]
    rules = config["river_system_rules"]
    ftype_include = {int(value) for value in config["ftype_include"]}
    precision = int(config["coordinate_precision"])
    min_length = float(config["min_segment_length_meters"])
    tolerance = float(config["simplify_tolerance_meters"])
    utm_epsg = int(config["utm_epsg"])

    grouped: dict[str, list[dict[str, Any]]] = {}
    stats = {
        "features_read": 0,
        "features_kept": 0,
        "vertices_before": 0,
        "vertices_after": 0,
    }

    with fiona.open(shapefile) as source:
        source_crs = source.crs.to_string() if source.crs else None
        for feature in source:
            stats["features_read"] += 1
            props = feature.get("properties") or {}
            ftype = property_lookup(props, "FType", "ftype")
            if ftype is None or int(ftype) not in ftype_include:
                continue

            gnis_name = property_lookup(props, "GNIS_Name", "gnis_name")
            reach_code = property_lookup(props, "ReachCode", "reachcode", "NHDPlusID", "nhdplusid")
            river_system = classify_river_system(
                str(gnis_name) if gnis_name is not None else None,
                rules,
            )
            if river_system is None:
                continue
            if only_system is not None and river_system != only_system:
                continue

            geom = shape(feature["geometry"])
            if geom.is_empty or geom.geom_type not in {"LineString", "MultiLineString"}:
                continue

            parts = [geom] if geom.geom_type == "LineString" else list(geom.geoms)
            for part in parts:
                if not isinstance(part, LineString):
                    continue
                wgs84 = _to_wgs84(part, source_crs)
                if not _within_bbox(wgs84, bbox):
                    continue

                stats["vertices_before"] += len(wgs84.coords)
                working = wgs84
                if simplify and tolerance > 0:
                    working = _simplify_meters(wgs84, tolerance, utm_epsg)
                if polyline_length_meters(list(working.coords)) < min_length:
                    continue

                built = _build_feature(
                    working,
                    str(gnis_name) if gnis_name is not None else None,
                    str(reach_code) if reach_code is not None else None,
                    river_system,
                    precision,
                )
                if built is None:
                    continue

                stats["vertices_after"] += len(built["geometry"]["coordinates"])
                grouped.setdefault(river_system, []).append(built)
                stats["features_kept"] += 1

    return grouped, stats


@click.command()
@click.option(
    "--config",
    "config_path",
    type=click.Path(path_type=Path, exists=True),
    default=lambda: script_dir() / "config.json",
    show_default=True,
)
@click.option(
    "--raw-dir",
    type=click.Path(path_type=Path, file_okay=False),
    default=lambda: script_dir() / "raw",
    show_default=True,
)
@click.option(
    "--output-dir",
    type=click.Path(path_type=Path, file_okay=False),
    default=lambda: script_dir() / "output",
    show_default=True,
)
@click.option("--system", "only_system", default=None, help="Convert one river_system only.")
@click.option("--no-simplify", is_flag=True, help="Skip Douglas-Peucker simplification.")
def main(
    config_path: Path,
    raw_dir: Path,
    output_dir: Path,
    only_system: str | None,
    no_simplify: bool,
) -> None:
    """Convert downloaded NHD shapefiles into per-system GeoJSON files."""
    config = load_config(config_path)
    shapefiles = find_nhd_flowline_shapefiles(raw_dir)
    if not shapefiles:
        raise click.ClickException(
            f"No NHDFlowline.shp files found under {raw_dir}. Run ./download.sh first."
        )

    aggregate: dict[str, list[dict[str, Any]]] = {}
    total_stats = {
        "features_read": 0,
        "features_kept": 0,
        "vertices_before": 0,
        "vertices_after": 0,
    }

    for shapefile in shapefiles:
        click.echo(f"convert: {shapefile}")
        grouped, stats = convert_shapefile(
            shapefile,
            config,
            simplify=not no_simplify,
            only_system=only_system,
        )
        for key, value in stats.items():
            total_stats[key] += int(value)
        for system, features in grouped.items():
            aggregate.setdefault(system, []).extend(features)

    if not aggregate:
        raise click.ClickException("No features matched Portland metro filters.")

    for system, features in sorted(aggregate.items()):
        output_path = output_dir / f"{system}_waterway.geojson"
        write_feature_collection(output_path, features)
        click.echo(f"wrote {output_path} ({len(features)} features)")

    ratio = (
        total_stats["vertices_after"] / total_stats["vertices_before"]
        if total_stats["vertices_before"]
        else 0.0
    )
    click.echo(
        "summary: "
        f"read={total_stats['features_read']} kept={total_stats['features_kept']} "
        f"vertices={total_stats['vertices_before']}->{total_stats['vertices_after']} "
        f"({ratio:.1%})"
    )


if __name__ == "__main__":
    main()

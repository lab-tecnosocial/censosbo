# /// script
# requires-python = ">=3.11"
# dependencies = ["pyarrow", "shapely"]
# ///
"""Convierte las geometrías descargadas a Parquet con WKB, listo para el release.

El GeoJSON crudo de ``geometrias.parquet`` se pasa a WKB binario, que es lo que
``sf::st_as_sfc()`` lee sin dependencias extra en R y ocupa bastante menos.

Los manzanos se parten por departamento (son ~250.000 polígonos y el archivo
único rondaría los 45 MB); así ``get_geo_manzanos(departamento = "01")`` baja
solo lo que necesita, igual que ``persona_dep*.parquet``. Las comunidades caben
holgadamente en un solo archivo.

Salida (en ``release/``):
  geo_manzano_dep01.parquet ... geo_manzano_dep09.parquet
  geo_comunidad.parquet

Uso:  uv run data-raw/fichas/construir_geometrias.py
"""

from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path

import pyarrow as pa
import pyarrow.parquet as pq
from shapely import to_wkb
from shapely.geometry import shape

AQUI = Path(__file__).parent
RELEASE = AQUI / "release"

ESQUEMA = pa.schema(
    [
        ("codigo", pa.string()),
        ("nombre", pa.string()),
        ("idep", pa.string()),
        ("iprov", pa.string()),
        ("imun", pa.string()),
        ("geometria", pa.binary()),  # WKB, EPSG:4326
    ]
)


def escribir(filas: list[dict], destino: Path) -> None:
    pq.write_table(
        pa.Table.from_pylist(filas, schema=ESQUEMA),
        destino,
        compression="zstd",
        compression_level=6,
    )
    mb = destino.stat().st_size / 1e6
    print(f"  {destino.name:28} {len(filas):>8,} filas  {mb:>6.1f} MB")


def main() -> None:
    RELEASE.mkdir(exist_ok=True)

    unidades = pq.read_table(
        AQUI / "unidades.parquet", columns=["codigo", "nombre", "area", "idep", "iprov", "imun"]
    ).to_pylist()
    meta = {u["codigo"]: u for u in unidades}

    geos = pq.read_table(AQUI / "geometrias.parquet").to_pylist()

    manzanos: dict[str, list[dict]] = defaultdict(list)
    comunidades: list[dict] = []
    sin_geo = 0
    invalidas = 0

    for g in geos:
        u = meta.get(g["codigo"])
        if u is None or not g["geojson"]:
            sin_geo += 1
            continue
        try:
            wkb = to_wkb(shape(json.loads(g["geojson"])))
        except Exception:  # noqa: BLE001 - geometría corrupta: se cuenta y se sigue
            invalidas += 1
            continue
        fila = {
            "codigo": u["codigo"],
            "nombre": u["nombre"],
            "idep": u["idep"],
            "iprov": u["iprov"],
            "imun": u["imun"],
            "geometria": wkb,
        }
        if u["area"] == "urbano":
            manzanos[u["idep"]].append(fila)
        else:
            comunidades.append(fila)

    print("Escribiendo geometrías en release/:")
    for idep in sorted(manzanos):
        escribir(manzanos[idep], RELEASE / f"geo_manzano_dep{idep}.parquet")
    escribir(comunidades, RELEASE / "geo_comunidad.parquet")

    total = sum(len(v) for v in manzanos.values()) + len(comunidades)
    print(f"\ntotal: {total:,} geometrías  (sin geojson: {sin_geo:,}, ilegibles: {invalidas:,})")


if __name__ == "__main__":
    main()

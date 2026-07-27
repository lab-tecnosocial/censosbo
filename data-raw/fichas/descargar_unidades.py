# /// script
# requires-python = ">=3.11"
# dependencies = ["requests", "pyarrow"]
# ///
"""Descarga el universo de unidades censales del CPV-2024 y sus geometrías.

Itera los 343 municipios de ``municipios.csv`` (derivado de ``geo_bolivia`` del
paquete) y pide, para cada uno, los manzanos urbanos (polígonos) y las
comunidades rurales (puntos). Son ~686 peticiones: minutos, no horas.

A diferencia del script de referencia, **guarda el municipio por el que se
consultó**, así cada unidad queda ligada a ``idep``/``iprov``/``imun`` sin tener
que reconstruir esa relación después con un cruce frágil.

Salida:
  crudo/unidades/{id_municipio}_{area}.json.gz   respuesta cruda, para reanudar
  unidades.parquet                               codigo, area, geografía, nombre
  geometrias.parquet                             codigo, area, geojson (texto)

Uso:
  uv run data-raw/fichas/descargar_unidades.py
  uv run data-raw/fichas/descargar_unidades.py --workers 8 --rehacer
"""

from __future__ import annotations

import argparse
import csv
import gzip
import json
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import pyarrow as pa
import pyarrow.parquet as pq

from ine_api import ClienteINE, ErrorAPI

AQUI = Path(__file__).parent
CRUDO = AQUI / "crudo" / "unidades"
AREAS = ("urbano", "rural")


def municipios() -> list[dict]:
    with open(AQUI / "municipios.csv", encoding="utf-8") as fh:
        return list(csv.DictReader(fh))


def ruta_crudo(id_mun: str, area: str) -> Path:
    return CRUDO / f"{id_mun}_{area}.json.gz"


def bajar(cli: ClienteINE, mun: dict, area: str, rehacer: bool) -> tuple[str, str, int, str | None]:
    """Descarga un (municipio, área) y lo deja en disco. Devuelve un resumen."""
    id_mun = mun["id_municipio"]
    destino = ruta_crudo(id_mun, area)
    if destino.exists() and not rehacer:
        with gzip.open(destino, "rt", encoding="utf-8") as fh:
            return id_mun, area, len(json.load(fh)), None
    try:
        unidades = cli.unidades(id_mun, area)
    except ErrorAPI as e:
        return id_mun, area, 0, str(e)[:160]

    filas = [
        {
            "codigo": u.codigo,
            "nombre": u.nombre,
            "area": u.area,
            "idep": u.idep,
            "iprov": u.iprov,
            "imun": u.imun,
            "geojson": json.dumps(u.geojson, ensure_ascii=False) if u.geojson else None,
        }
        for u in unidades
    ]
    tmp = destino.with_suffix(".tmp")
    with gzip.open(tmp, "wt", encoding="utf-8") as fh:
        json.dump(filas, fh, ensure_ascii=False)
    tmp.replace(destino)  # escritura atómica: nunca queda un .gz a medias
    return id_mun, area, len(filas), None


def consolidar() -> None:
    """Junta los crudos en unidades.parquet y geometrias.parquet."""
    unidades, geometrias = [], []
    vistos: set[tuple[str, str]] = set()

    for f in sorted(CRUDO.glob("*.json.gz")):
        with gzip.open(f, "rt", encoding="utf-8") as fh:
            for fila in json.load(fh):
                clave = (fila["codigo"], fila["area"])
                if clave in vistos:
                    continue  # el mismo código no se repite dentro de un área
                vistos.add(clave)
                geo = fila.pop("geojson")
                unidades.append(fila)
                geometrias.append(
                    {"codigo": fila["codigo"], "area": fila["area"], "geojson": geo}
                )

    if not unidades:
        sys.exit("No hay nada que consolidar: ejecuta la descarga primero.")

    pq.write_table(
        pa.Table.from_pylist(unidades),
        AQUI / "unidades.parquet",
        compression="zstd",
        compression_level=6,
    )
    pq.write_table(
        pa.Table.from_pylist(geometrias),
        AQUI / "geometrias.parquet",
        compression="zstd",
        compression_level=6,
    )

    urb = sum(1 for u in unidades if u["area"] == "urbano")
    rur = len(unidades) - urb
    # Un mismo código puede aparecer como urbano y como rural: el INE solapa
    # ambos universos en áreas amanzanadas rurales. Se resuelve al construir.
    solapados = len({u["codigo"] for u in unidades})
    print(f"\nunidades.parquet   : {len(unidades):,} filas ({urb:,} urbanas, {rur:,} rurales)")
    print(f"códigos únicos     : {solapados:,} ({len(unidades) - solapados:,} en ambas áreas)")
    print(f"geometrias.parquet : {len(geometrias):,} filas")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--workers", type=int, default=6, help="peticiones en paralelo (defecto 6)")
    ap.add_argument("--pausa", type=float, default=0.1, help="segundos entre peticiones por hilo")
    ap.add_argument("--rehacer", action="store_true", help="ignora lo ya descargado")
    ap.add_argument("--solo-consolidar", action="store_true")
    args = ap.parse_args()

    CRUDO.mkdir(parents=True, exist_ok=True)
    if args.solo_consolidar:
        consolidar()
        return

    muns = municipios()
    tareas = [(m, a) for m in muns for a in AREAS]
    print(f"{len(muns)} municipios x {len(AREAS)} áreas = {len(tareas)} peticiones")

    cli = ClienteINE(pausa=args.pausa)
    cli.token()

    total, errores, hechas = 0, [], 0
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futuros = {pool.submit(bajar, cli, m, a, args.rehacer): (m, a) for m, a in tareas}
        for fut in as_completed(futuros):
            id_mun, area, n, err = fut.result()
            hechas += 1
            if err:
                errores.append((id_mun, area, err))
            else:
                total += n
            if hechas % 25 == 0 or hechas == len(tareas):
                print(f"  {hechas}/{len(tareas)} — {total:,} unidades, {len(errores)} errores")

    if errores:
        print(f"\n{len(errores)} fallos (vuelve a ejecutar para reintentarlos):")
        for id_mun, area, err in errores[:15]:
            print(f"  {id_mun} {area}: {err}")

    consolidar()


if __name__ == "__main__":
    main()

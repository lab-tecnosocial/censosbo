# /// script
# requires-python = ">=3.11"
# dependencies = ["requests", "openpyxl"]
# ///
"""Sondeo del contrato del API antes de lanzar la descarga larga.

Comprueba, sobre un municipio y un manzano de ejemplo:
  1. que ``depMunSeleccionadoPoligono`` devuelve manzanos con polígono,
  2. que ``depMunSeleccionadoPunto`` devuelve comunidades con punto,
  3. que ``generar-excel`` acepta el flag ``vivienda``.

Guarda los dos XLSX en ``muestras/`` para calibrar el parser de celdas.

Uso:  uv run data-raw/fichas/sondeo.py [id_municipio] [codigo_unidad]
"""

import sys
from collections import Counter
from pathlib import Path

from ine_api import ClienteINE

MUNICIPIO = sys.argv[1] if len(sys.argv) > 1 else "010101"  # Sucre
CODIGO = sys.argv[2] if len(sys.argv) > 2 else "00417298575-A"
DEST = Path(__file__).parent / "muestras"


def main() -> None:
    DEST.mkdir(exist_ok=True)
    cli = ClienteINE()
    print(f"token: {len(cli.token())} chars\n")

    for area in ("urbano", "rural"):
        us = cli.unidades(MUNICIPIO, area)
        geoms = Counter(u.geojson.get("type") if u.geojson else None for u in us)
        sufijos = Counter(u.codigo[-1] for u in us)
        print(f"[{area}] municipio {MUNICIPIO}: {len(us)} unidades")
        print(f"  geometrías: {dict(geoms)}")
        print(f"  sufijos:    {dict(sufijos)}")
        if us:
            u = us[0]
            print(f"  ejemplo:    {u.codigo} | {u.nombre} | {u.idep}-{u.iprov}-{u.imun}")
        print()

    print(f"validar {CODIGO}: {cli.validar(CODIGO)}\n")

    for viv in (False, True):
        etiqueta = "vivienda" if viv else "base"
        try:
            b = cli.ficha_xlsx(CODIGO, vivienda=viv)
        except Exception as e:  # noqa: BLE001 - el sondeo debe reportar, no romper
            print(f"ficha {etiqueta}: FALLÓ -> {e}")
            continue
        f = DEST / f"{CODIGO}_{etiqueta}.xlsx"
        f.write_bytes(b)
        print(f"ficha {etiqueta}: {len(b):,} bytes -> {f.name}")


if __name__ == "__main__":
    main()

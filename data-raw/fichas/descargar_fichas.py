# /// script
# requires-python = ">=3.11"
# dependencies = ["requests", "pyarrow"]
# ///
"""Descarga las fichas resumen del CPV-2024 para cada unidad censal.

Por cada unidad de ``unidades.parquet``:

  1. ``verificar-validar`` -> personas, viviendas y si el INE libera la ficha.
     Se pide para **todas** las unidades: aunque no haya ficha, los conteos
     totales son públicos y valen la pena.
  2. Si la libera, ``generar-excel`` -> se parsea con el parser verificado
     (``ficha_parser``) y se contrasta contra los conteos del paso 1.

El INE oculta la ficha de unidades con poca población por privacidad; eso afecta
a cerca de la mitad de los manzanos pero solo a ~10 % de la población. No se
intenta rodear ese límite.

El progreso vive en ``fichas.sqlite``: el proceso se puede cortar y reanudar
cuantas veces haga falta. Son ~420.000 peticiones; conviene dejarlo correr de
noche y no subir mucho ``--workers`` (es un servidor público).

Uso:
  uv run data-raw/fichas/descargar_fichas.py                 # todo
  uv run data-raw/fichas/descargar_fichas.py --limite 200    # prueba corta
  uv run data-raw/fichas/descargar_fichas.py --departamento 01
  uv run data-raw/fichas/descargar_fichas.py --solo-exportar
"""

from __future__ import annotations

import argparse
import sqlite3
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import pyarrow as pa
import pyarrow.parquet as pq

from ficha_parser import CAMPOS, FichaInvalida, coherencia, parsear
from ine_api import ClienteINE, ErrorAPI

AQUI = Path(__file__).parent
BD = AQUI / "fichas.sqlite"
VARIABLES = [c.variable for c in CAMPOS]

_local = threading.local()


# --- almacenamiento ------------------------------------------------------


def conexion() -> sqlite3.Connection:
    """Una conexión por hilo; SQLite no las comparte bien."""
    con = getattr(_local, "con", None)
    if con is None:
        con = sqlite3.connect(BD, timeout=60)
        con.execute("PRAGMA journal_mode=WAL")
        con.execute("PRAGMA synchronous=NORMAL")
        con.execute("PRAGMA busy_timeout=30000")
        _local.con = con
    return con


def crear_esquema() -> None:
    con = conexion()
    con.execute(
        """
        CREATE TABLE IF NOT EXISTS progreso (
            codigo    TEXT PRIMARY KEY,
            area      TEXT, idep TEXT, iprov TEXT, imun TEXT,
            validado  INTEGER,
            personas  INTEGER,
            viviendas INTEGER,
            mensaje   TEXT,
            ficha     TEXT NOT NULL DEFAULT 'pendiente',
            error     TEXT,
            intentos  INTEGER NOT NULL DEFAULT 0
        )
        """
    )
    con.execute("CREATE INDEX IF NOT EXISTS ix_pendientes ON progreso(validado, ficha)")
    cols = ", ".join(f'"{v}" REAL' for v in VARIABLES)
    con.execute(f"CREATE TABLE IF NOT EXISTS fichas (codigo TEXT PRIMARY KEY, {cols})")
    con.execute("CREATE TABLE IF NOT EXISTS avisos (codigo TEXT, aviso TEXT)")
    con.commit()

    # Si campos.csv creció desde la última corrida, añadimos las columnas nuevas.
    existentes = {r[1] for r in con.execute("PRAGMA table_info(fichas)")}
    for v in VARIABLES:
        if v not in existentes:
            con.execute(f'ALTER TABLE fichas ADD COLUMN "{v}" REAL')
    con.commit()


def sembrar() -> int:
    """Carga el universo de unidades en la tabla de progreso (idempotente)."""
    ruta = AQUI / "unidades.parquet"
    if not ruta.exists():
        sys.exit("Falta unidades.parquet: ejecuta antes descargar_unidades.py")
    t = pq.read_table(ruta, columns=["codigo", "area", "idep", "iprov", "imun"])
    filas = list(zip(*[t.column(c).to_pylist() for c in t.column_names]))
    con = conexion()
    con.executemany(
        "INSERT OR IGNORE INTO progreso (codigo, area, idep, iprov, imun) VALUES (?,?,?,?,?)",
        filas,
    )
    con.commit()
    return len(filas)


def revalidar_sin_ficha(departamento: str | None) -> int:
    """Marca para reconsultar las unidades que el INE no liberaba.

    Una unidad con ``validado = 0`` no se vuelve a pedir nunca, que es lo correcto
    mientras se completa una descarga. Pero si más adelante el INE libera fichas
    que antes reservaba, quedarían fuera para siempre. Esto las devuelve a la cola.

    (Comprobado en julio de 2026: entre dos capturas independientes separadas por
    seis semanas no cambió ninguna. Aun así, la puerta tiene que existir.)
    """
    sql = "UPDATE progreso SET validado = NULL, ficha = 'pendiente' WHERE validado = 0"
    args: list = []
    if departamento:
        sql += " AND idep = ?"
        args.append(departamento)
    con = conexion()
    n = con.execute(sql, args).rowcount
    con.commit()
    return n


def pendientes(departamento: str | None, limite: int | None) -> list[tuple[str, int | None]]:
    """Unidades que aún necesitan una petición: sin validar, o validadas sin ficha."""
    sql = """
        SELECT codigo, validado FROM progreso
        WHERE validado IS NULL OR (validado = 1 AND ficha NOT IN ('ok', 'invalida'))
    """
    args: list = []
    if departamento:
        sql += " AND idep = ?"
        args.append(departamento)
    sql += " ORDER BY codigo"
    if limite:
        sql += f" LIMIT {int(limite)}"
    return list(conexion().execute(sql, args))


# --- trabajo por unidad --------------------------------------------------


def procesar(cli: ClienteINE, codigo: str, validado: int | None) -> str:
    """Devuelve un código de resultado corto para el contador de progreso."""
    con = conexion()

    if validado is None:
        try:
            v = cli.validar(codigo)
        except ErrorAPI as e:
            con.execute(
                "UPDATE progreso SET error=?, intentos=intentos+1 WHERE codigo=?",
                (str(e)[:300], codigo),
            )
            con.commit()
            return "error"
        con.execute(
            """UPDATE progreso
               SET validado=?, personas=?, viviendas=?, mensaje=?, error=NULL,
                   ficha=CASE WHEN ? THEN 'pendiente' ELSE 'sin_ficha' END
               WHERE codigo=?""",
            (
                int(v["validado"]), v["personas"], v["viviendas"], v["mensaje"],
                int(v["validado"]), codigo,
            ),
        )
        con.commit()
        if not v["validado"]:
            return "sin_ficha"
        validado = 1

    if not validado:
        return "sin_ficha"

    try:
        xlsx = cli.ficha_xlsx(codigo)
    except ErrorAPI as e:
        con.execute(
            "UPDATE progreso SET error=?, intentos=intentos+1 WHERE codigo=?",
            (str(e)[:300], codigo),
        )
        con.commit()
        return "error"

    try:
        valores = parsear(xlsx, codigo=codigo)
    except FichaInvalida as e:
        # El layout cambió: no seguimos adivinando, marcamos y avisamos fuerte.
        con.execute(
            "UPDATE progreso SET ficha='invalida', error=? WHERE codigo=?",
            (str(e)[:500], codigo),
        )
        con.commit()
        return "layout"

    cols = ", ".join(f'"{v}"' for v in VARIABLES)
    marcas = ", ".join("?" * (len(VARIABLES) + 1))
    con.execute(
        f"INSERT OR REPLACE INTO fichas (codigo, {cols}) VALUES ({marcas})",
        [codigo] + [valores.get(v) for v in VARIABLES],
    )

    fila = con.execute(
        "SELECT personas, viviendas FROM progreso WHERE codigo=?", (codigo,)
    ).fetchone()
    for aviso in coherencia(valores, fila[0], fila[1]):
        con.execute("INSERT INTO avisos (codigo, aviso) VALUES (?,?)", (codigo, aviso))

    con.execute("UPDATE progreso SET ficha='ok', error=NULL WHERE codigo=?", (codigo,))
    con.commit()
    return "ok"


# --- exportación ---------------------------------------------------------


def exportar() -> None:
    con = conexion()

    cols = ", ".join(f'p."{c}"' for c in ("codigo", "area", "idep", "iprov", "imun"))
    filas = con.execute(
        f"""SELECT {cols}, p.personas, p.viviendas,
                   CASE WHEN p.ficha = 'ok' THEN 1 ELSE 0 END AS ficha
            FROM progreso p WHERE p.validado IS NOT NULL ORDER BY p.codigo"""
    ).fetchall()
    nombres = ["codigo", "area", "idep", "iprov", "imun", "personas", "viviendas", "ficha"]
    pq.write_table(
        pa.Table.from_pylist([dict(zip(nombres, f)) for f in filas]),
        AQUI / "unidades_final.parquet",
        compression="zstd",
        compression_level=6,
    )

    cols_f = ", ".join(f'f."{v}"' for v in VARIABLES)
    filas_f = con.execute(
        f"""SELECT f.codigo, p.area, p.idep, p.iprov, p.imun, {cols_f}
            FROM fichas f JOIN progreso p USING (codigo)
            WHERE p.ficha = 'ok' ORDER BY f.codigo"""
    ).fetchall()
    nombres_f = ["codigo", "area", "idep", "iprov", "imun"] + VARIABLES
    pq.write_table(
        pa.Table.from_pylist([dict(zip(nombres_f, f)) for f in filas_f]),
        AQUI / "fichas.parquet",
        compression="zstd",
        compression_level=6,
    )

    print(f"\nunidades_final.parquet : {len(filas):,} filas")
    print(f"fichas.parquet         : {len(filas_f):,} filas x {len(nombres_f)} columnas")
    resumen()


def resumen() -> None:
    con = conexion()
    print("\n--- cobertura por departamento ---")
    print(f"{'dep':>4} {'unidades':>10} {'con ficha':>10} {'%':>6} {'personas':>12} {'% pob':>7}")
    for fila in con.execute(
        """SELECT idep, COUNT(*), SUM(ficha='ok'),
                  COALESCE(SUM(personas),0), COALESCE(SUM(CASE WHEN ficha='ok' THEN personas END),0)
           FROM progreso WHERE validado IS NOT NULL GROUP BY idep ORDER BY idep"""
    ):
        dep, n, con_ficha, pob, pob_ficha = fila
        print(
            f"{dep:>4} {n:>10,} {con_ficha:>10,} {100 * con_ficha / n:>5.1f}% "
            f"{pob:>12,} {100 * pob_ficha / pob if pob else 0:>6.1f}%"
        )

    n_avisos = con.execute("SELECT COUNT(*) FROM avisos").fetchone()[0]
    n_layout = con.execute("SELECT COUNT(*) FROM progreso WHERE ficha='invalida'").fetchone()[0]
    n_error = con.execute("SELECT COUNT(*) FROM progreso WHERE error IS NOT NULL").fetchone()[0]
    print(f"\navisos de coherencia : {n_avisos:,}")
    print(f"fichas con layout raro: {n_layout:,}")
    print(f"unidades con error    : {n_error:,}")
    if n_avisos:
        print("\nejemplos de avisos:")
        for cod, av in con.execute("SELECT codigo, aviso FROM avisos LIMIT 5"):
            print(f"  {cod}: {av}")


# --- principal -----------------------------------------------------------


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--workers", type=int, default=6, help="peticiones en paralelo (defecto 6)")
    ap.add_argument("--pausa", type=float, default=0.05, help="segundos entre peticiones por hilo")
    ap.add_argument("--limite", type=int, help="procesa solo N unidades (para probar)")
    ap.add_argument("--departamento", help="restringe a un idep, p. ej. 01")
    ap.add_argument("--solo-exportar", action="store_true")
    ap.add_argument("--solo-resumen", action="store_true")
    ap.add_argument(
        "--revalidar",
        action="store_true",
        help="vuelve a consultar las unidades sin ficha, por si el INE liberó más",
    )
    args = ap.parse_args()

    crear_esquema()
    if args.solo_resumen:
        resumen()
        return
    if args.solo_exportar:
        exportar()
        return

    n = sembrar()
    if args.revalidar:
        print(f"revalidando {revalidar_sin_ficha(args.departamento):,} unidades sin ficha")
    cola = pendientes(args.departamento, args.limite)
    print(f"universo: {n:,} unidades — pendientes ahora: {len(cola):,}")
    if not cola:
        print("Nada pendiente.")
        exportar()
        return

    cli = ClienteINE(pausa=args.pausa)
    cli.token()

    conteo = {"ok": 0, "sin_ficha": 0, "error": 0, "layout": 0}
    inicio = time.time()
    hechas = 0

    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futuros = [pool.submit(procesar, cli, c, v) for c, v in cola]
        for fut in as_completed(futuros):
            conteo[fut.result()] += 1
            hechas += 1
            if hechas % 500 == 0 or hechas == len(cola):
                seg = time.time() - inicio
                ritmo = hechas / seg if seg else 0
                faltan = (len(cola) - hechas) / ritmo if ritmo else 0
                print(
                    f"  {hechas:,}/{len(cola):,} — {conteo['ok']:,} fichas, "
                    f"{conteo['sin_ficha']:,} sin ficha, {conteo['error']:,} errores, "
                    f"{conteo['layout']:,} layout — {ritmo:.1f}/s, faltan ~{faltan / 3600:.1f} h"
                )

    if conteo["layout"]:
        print(
            f"\n¡Atención! {conteo['layout']} fichas no coincidieron con campos.csv. "
            "El INE pudo cambiar el layout: revisa el detalle con\n"
            "  sqlite3 fichas.sqlite \"SELECT codigo, error FROM progreso WHERE ficha='invalida' LIMIT 3\""
        )

    exportar()


if __name__ == "__main__":
    main()

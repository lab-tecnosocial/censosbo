#!/usr/bin/env python3
"""
Añade la columna 'area' (1=Urbana, 2=Rural) directamente a los parquets
de persona de todos los censos históricos (1992, 2001, 2012) y del CPV-2024.

  1992/2012 : join persona ← vivienda via VIVIENDA_REF_ID  (columna URBRUR)
  2001      : join persona ← vivienda via VIVIENDA_REF_ID  (columna TURUR)
  2024      : join persona ← vivienda via idep+iprov+imun+i00 (columna urbrur)

Los parquets históricos se modifican in-place en original-data/censos-historicos/.
Los parquets 2024 se escriben en original-data/cpv-2024/parquets/ (para subir
como release) y también se actualizan en el caché local.

Uso:
    /opt/homebrew/bin/python3 data-raw/add_area_to_persona.py

Requiere: pandas, pyarrow  (/opt/homebrew/bin/python3)
"""

from pathlib import Path
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

COMPRESSION       = "zstd"
COMPRESSION_LEVEL = 6

REPO  = Path(__file__).parent.parent
HIST  = REPO / "original-data" / "censos-historicos"
HOME  = Path.home()
CACHE = HOME / "Library" / "Caches" / "org.R-project.R" / "R" / "censosbo"
OUT_2024 = REPO / "original-data" / "cpv-2024" / "parquets"


def write_parquet(df: pd.DataFrame, path: Path) -> None:
    table = pa.Table.from_pandas(df, preserve_index=False)
    pq.write_table(table, path,
                   compression=COMPRESSION,
                   compression_level=COMPRESSION_LEVEL)


def add_area_historico(anio: int, urb_col: str) -> None:
    """Añade columna 'area' a persona del censo ANIO via join con vivienda."""
    base      = HIST / f"censo_{anio}"
    pers_path = base / "persona.parquet"
    viv_path  = base / "vivienda.parquet"

    print(f"\n=== Censo {anio} ===")
    pers = pd.read_parquet(pers_path)
    viv  = pd.read_parquet(viv_path, columns=["VIVIENDA_REF_ID", urb_col])

    if "area" in pers.columns:
        print(f"  'area' ya existe — se sobreescribe")
        pers = pers.drop(columns=["area"])

    merged = pers.merge(
        viv.rename(columns={urb_col: "area"}),
        on="VIVIENDA_REF_ID",
        how="left"
    )
    merged["area"] = merged["area"].astype("Int64")

    dist = merged["area"].value_counts().sort_index().to_dict()
    nas  = int(merged["area"].isna().sum())
    print(f"  {len(merged):,} filas | area={dist} | NAs={nas}")
    assert nas == 0, f"¡NAs inesperados en area! ({nas})"

    write_parquet(merged, pers_path)
    print(f"  → {pers_path} actualizado ({len(merged.columns)} cols)")


def add_area_2024() -> None:
    """Añade 'area' a los persona_dep*.parquet del CPV-2024."""
    print(f"\n=== CPV-2024 ===")
    OUT_2024.mkdir(parents=True, exist_ok=True)

    viv_path = CACHE / "vivienda.parquet"
    viv = pd.read_parquet(viv_path, columns=["idep", "iprov", "imun", "i00", "urbrur"])
    viv = viv.rename(columns={"urbrur": "area"})
    viv["area"] = viv["area"].astype("Int64")
    print(f"  vivienda: {len(viv):,} filas")

    for dep in range(1, 10):
        dep_str   = f"{dep:02d}"
        pers_path = CACHE / f"persona_dep{dep_str}.parquet"
        out_path  = OUT_2024 / f"persona_dep{dep_str}.parquet"

        pers = pd.read_parquet(pers_path)
        if "area" in pers.columns:
            pers = pers.drop(columns=["area"])

        merged = pers.merge(
            viv,
            on=["idep", "iprov", "imun", "i00"],
            how="left"
        )
        merged["area"] = merged["area"].astype("Int64")

        nas  = int(merged["area"].isna().sum())
        dist = merged["area"].value_counts().sort_index().to_dict()
        print(f"  dep{dep_str}: {len(merged):,} filas | area={dist} | NAs={nas}")
        assert nas == 0, f"NAs inesperados en dep{dep_str} ({nas})"

        write_parquet(merged, out_path)
        # También actualizar el caché local
        write_parquet(merged, pers_path)

    print(f"  → Guardado en {OUT_2024}/  y  caché actualizado")


if __name__ == "__main__":
    add_area_historico(1992, "URBRUR")
    add_area_historico(2001, "TURUR")
    add_area_historico(2012, "URBRUR")
    add_area_2024()
    print("\n¡Listo! Todos los parquets de persona tienen columna 'area'.")

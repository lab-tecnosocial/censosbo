#!/usr/bin/env python3
"""
Convierte los CSV del CPV-2024 de Bolivia a formato Parquet particionado.

Uso:
    /opt/homebrew/bin/python3 data-raw/csv_to_parquet.py \
        --input-dir "temporal-data/Base de datos CSV" \
        --output-dir /tmp/censosbo-parquet [--tables all|persona|vivienda|emigracion|mortalidad]

Requiere: pandas>=3.0, pyarrow>=14.0  (/opt/homebrew/bin/python3)
"""

import argparse
import hashlib
import json
from pathlib import Path

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

# Columnas que DEBEN ser string (preservar ceros a la izquierda)
GEO_COLS = ["idep", "iprov", "imun", "i00"]

FORCE_STR = {
    "persona": GEO_COLS + [
        "p32_pueblo_cod", "p331_idiohab1_cod", "p332_idiohab2_cod",
        "p333_idiohab3_cod", "p334_idiohab_no", "p341_idiomat_cod",
        "p342_idiomat_no", "p353_paisnac_cod", "p363_paisres_cod",
        "p373_paisres5_cod", "p52_pais_mov_cod", "p57b_uhnacan",
        "ocu_1d_19", "act_eco_2d_19", "ocu_1d_13", "act_eco_2d_13",
    ],
    "vivienda":    GEO_COLS,
    "emigracion":  GEO_COLS + ["pais_destino_cod"],
    "mortalidad":  GEO_COLS,
}

COMPRESSION       = "zstd"
COMPRESSION_LEVEL = 6
CHUNK_ROWS        = 500_000


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(65536), b""):
            h.update(block)
    return h.hexdigest()


def read_csv(path: Path, str_cols: list) -> pd.DataFrame:
    dtype = {c: str for c in str_cols}
    df = pd.read_csv(
        path,
        sep=";",
        dtype=dtype,
        encoding="utf-8",
        engine="c",
        on_bad_lines="skip",
    )
    # Limpiar comillas y espacios en nombres de columnas
    df.columns = df.columns.str.strip().str.strip('"')
    # Limpiar comillas en columnas geo
    for col in GEO_COLS:
        if col in df.columns:
            df[col] = df[col].astype(str).str.strip('"').str.strip()
    return df


def convert_persona(input_path: Path, output_dir: Path) -> list[dict]:
    """Convierte Persona_CPV-2024.csv → 9 archivos por departamento."""
    output_dir.mkdir(parents=True, exist_ok=True)
    str_cols = FORCE_STR["persona"]
    dtype = {c: str for c in str_cols}
    dep_frames: dict[str, list] = {}

    print(f"Leyendo {input_path.name} en chunks de {CHUNK_ROWS:,} filas...")
    total = 0
    reader = pd.read_csv(
        input_path,
        sep=";",
        dtype=dtype,
        encoding="utf-8",
        engine="c",
        chunksize=CHUNK_ROWS,
        on_bad_lines="skip",
    )
    for i, chunk in enumerate(reader):
        chunk.columns = chunk.columns.str.strip().str.strip('"')
        chunk["idep"] = chunk["idep"].astype(str).str.strip('"').str.strip().str.zfill(2)
        for col in ["iprov", "imun", "i00"]:
            if col in chunk.columns:
                chunk[col] = chunk[col].astype(str).str.strip('"').str.strip()
        for dep, group in chunk.groupby("idep"):
            dep_frames.setdefault(dep, []).append(group)
        total += len(chunk)
        print(f"  chunk {i+1}: {total:,} filas", end="\r")
    print(f"\nTotal: {total:,} filas")

    metadata = []
    for dep, frames in sorted(dep_frames.items()):
        df = pd.concat(frames, ignore_index=True)
        df = _optimize_dtypes(df, set(str_cols))
        out = output_dir / f"persona_dep{dep}.parquet"
        table = pa.Table.from_pandas(df, preserve_index=False)
        pq.write_table(table, out, compression=COMPRESSION,
                       compression_level=COMPRESSION_LEVEL)
        mb = out.stat().st_size / 1024**2
        print(f"  -> {out.name}: {len(df):,} filas, {mb:.1f} MB")
        metadata.append({
            "archivo": out.name, "tabla": "persona", "idep": dep,
            "filas": len(df), "columnas": len(df.columns),
            "tamano_mb": round(mb, 2), "sha256": sha256(out),
        })
    return metadata


def convert_single(table_name: str, input_path: Path, output_dir: Path) -> dict:
    """Convierte Vivienda, Emigracion o Mortalidad a un único Parquet."""
    output_dir.mkdir(parents=True, exist_ok=True)
    str_cols = FORCE_STR[table_name]
    print(f"Leyendo {input_path.name}...")
    df = read_csv(input_path, str_cols)
    df = _optimize_dtypes(df, set(str_cols))
    out = output_dir / f"{table_name}.parquet"
    table = pa.Table.from_pandas(df, preserve_index=False)
    pq.write_table(table, out, compression=COMPRESSION,
                   compression_level=COMPRESSION_LEVEL)
    mb = out.stat().st_size / 1024**2
    print(f"  -> {out.name}: {len(df):,} filas, {mb:.1f} MB")
    return {
        "archivo": out.name, "tabla": table_name,
        "filas": len(df), "columnas": len(df.columns),
        "tamano_mb": round(mb, 2), "sha256": sha256(out),
    }


def _optimize_dtypes(df: pd.DataFrame, str_cols: set) -> pd.DataFrame:
    """Convierte float64 a Int32 donde no hay decimales reales."""
    for col in df.columns:
        if col in str_cols:
            continue
        if df[col].dtype == "float64":
            try:
                df[col] = df[col].astype("Int32")
            except (ValueError, TypeError):
                pass
    return df


FILE_MAP = {
    "persona":    "Persona_CPV-2024.csv",
    "vivienda":   "Vivienda_CPV-2024.csv",
    "emigracion": "Emigracion_CPV-2024.csv",
    "mortalidad": "Mortalidad_CPV-2024.csv",
}


def main():
    parser = argparse.ArgumentParser(description="CSV→Parquet para CPV-2024 Bolivia")
    parser.add_argument("--input-dir",  required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--tables", nargs="+",
                        choices=list(FILE_MAP) + ["all"], default=["all"])
    args = parser.parse_args()

    input_dir  = Path(args.input_dir)
    output_dir = Path(args.output_dir)
    tables = list(FILE_MAP) if "all" in args.tables else args.tables

    all_meta = []
    if "persona" in tables:
        all_meta.extend(convert_persona(input_dir / FILE_MAP["persona"], output_dir))
    for t in ["vivienda", "emigracion", "mortalidad"]:
        if t in tables:
            all_meta.append(convert_single(t, input_dir / FILE_MAP[t], output_dir))

    manifest = {
        "version": "1.0.0",
        "fuente": "CPV-2024 Bolivia - INE (https://anda.ine.gob.bo/index.php/catalog/132)",
        "archivos": all_meta,
    }
    manifest_path = output_dir / "manifest.json"
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    print(f"\nManifest: {manifest_path}")
    total_mb = sum(a["tamano_mb"] for a in all_meta)
    print(f"Tamaño total: {total_mb:.0f} MB")


if __name__ == "__main__":
    main()

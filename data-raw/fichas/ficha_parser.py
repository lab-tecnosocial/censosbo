"""Extracción de la ficha resumen del INE desde el XLSX.

Aquí cada variable declara, además de su celda de valor, la celda del rótulo y el
texto que debe haber en ella (``campos.csv``). Si el rótulo no coincide, se aborta
con un mensaje que dice exactamente qué celda cambió. Es preferible una descarga
que falla ruidosamente a un dataset corrupto.
"""

from __future__ import annotations

import csv
import io
import re
import unicodedata
import zipfile
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree as ET

CAMPOS_CSV = Path(__file__).parent / "campos.csv"
HOJA_FICHA = "Ficha_resumen"
HOJA_ANEXO = "Reporte_anexos"

NS_SS = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"
NS_REL = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}"
NS_PKG_REL = "{http://schemas.openxmlformats.org/package/2006/relationships}"


class FichaInvalida(RuntimeError):
    """El XLSX no tiene la forma esperada (layout cambiado o archivo corrupto)."""


@dataclass(frozen=True)
class Campo:
    bloque: str
    variable: str
    etiqueta: str
    celda: str
    celda_rotulo: str
    rotulo_esperado: str


def _norm(texto) -> str:
    """Normaliza un rótulo para comparar: sin acentos, sin notas al pie, minúsculas."""
    if texto is None:
        return ""
    s = unicodedata.normalize("NFKD", str(texto))
    s = "".join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r"\(\d+\)", " ", s)  # llamadas a nota al pie: "presentes(3)"
    s = re.sub(r"[^a-z0-9]+", " ", s.lower())
    return s.strip()


def cargar_campos(ruta: Path = CAMPOS_CSV) -> list[Campo]:
    with open(ruta, encoding="utf-8") as fh:
        campos = [Campo(**fila) for fila in csv.DictReader(fh)]
    vistas = [c.variable for c in campos]
    if len(set(vistas)) != len(vistas):
        dup = {v for v in vistas if vistas.count(v) > 1}
        raise ValueError(
            f"campos.csv tiene variables duplicadas: {sorted(dup)}")
    return campos


CAMPOS = cargar_campos()


def _a_numero(v):
    """Convierte el valor de una celda a número; None si no lo es."""
    if isinstance(v, bool) or v is None:
        return None
    if isinstance(v, (int, float)):
        return float(v)
    s = str(v).strip().replace(",", "")
    if not s or s == "-":
        return None
    try:
        return float(s)
    except ValueError:
        return None


# Celdas que hace falta leer: los rótulos a validar, los valores, y la cabecera
# con la geografía. Se calcula una vez para no recorrer el XML entero.
CELDAS_GEO = {"C4": "departamento", "C5": "provincia", "C6": "municipio"}
CELDAS_NECESARIAS = (
    {c.celda for c in CAMPOS} | {
        c.celda_rotulo for c in CAMPOS} | set(CELDAS_GEO)
)


def _leer_celdas(contenido: bytes) -> dict[str, object]:
    """Lee solo las celdas necesarias de la hoja de la ficha.

    Se hace con zipfile + ElementTree en vez de openpyxl porque el XLSX del INE
    trae además una hoja ``Reporte_anexos`` de 5.121 filas que openpyxl carga
    entera: con ~150.000 fichas por delante, eso son horas de CPU tiradas.
    """
    with zipfile.ZipFile(io.BytesIO(contenido)) as z:
        nombres = set(z.namelist())

        # Resolver qué archivo XML corresponde a la hoja de la ficha.
        wb = ET.fromstring(z.read("xl/workbook.xml"))
        hojas = {h.get("name"): h.get(f"{NS_REL}id")
                 for h in wb.iter(f"{NS_SS}sheet")}
        if HOJA_FICHA not in hojas:
            raise FichaInvalida(
                f"falta la hoja {HOJA_FICHA!r} (hay {sorted(hojas)})"
            )
        rels = ET.fromstring(z.read("xl/_rels/workbook.xml.rels"))
        destino = {
            r.get("Id"): r.get("Target") for r in rels.iter(f"{NS_PKG_REL}Relationship")
        }[hojas[HOJA_FICHA]]
        ruta = destino if destino.startswith(
            "xl/") else f"xl/{destino.lstrip('/')}"
        if ruta not in nombres:
            raise FichaInvalida(
                f"la hoja {HOJA_FICHA!r} apunta a {ruta!r}, que no existe")

        # Los rótulos viven en la tabla de cadenas compartidas.
        compartidas: list[str] = []
        if "xl/sharedStrings.xml" in nombres:
            sst = ET.fromstring(z.read("xl/sharedStrings.xml"))
            for si in sst.iter(f"{NS_SS}si"):
                compartidas.append(
                    "".join(t.text or "" for t in si.iter(f"{NS_SS}t")))

        celdas: dict[str, object] = {}
        pendientes = set(CELDAS_NECESARIAS)
        for _, elem in ET.iterparse(z.open(ruta), events=("end",)):
            if elem.tag != f"{NS_SS}c":
                continue
            ref = elem.get("r")
            if ref in pendientes:
                tipo = elem.get("t")
                if tipo == "inlineStr":
                    is_ = elem.find(f"{NS_SS}is")
                    valor = "".join(t.text or "" for t in is_.iter(
                        f"{NS_SS}t")) if is_ is not None else None
                else:
                    v = elem.find(f"{NS_SS}v")
                    valor = v.text if v is not None else None
                    if tipo == "s" and valor is not None:
                        idx = int(valor)
                        valor = compartidas[idx] if idx < len(
                            compartidas) else None
                celdas[ref] = valor
                pendientes.discard(ref)
            elem.clear()
            if not pendientes:
                break
        return celdas


def geografia(contenido: bytes) -> dict[str, str]:
    """Departamento/provincia/municipio que el propio INE declara en la ficha.

    Sirve para contrastar el municipio por el que iteramos al descargar: si no
    coincide, el listado de unidades y la ficha discrepan y hay que mirarlo.
    """
    celdas = _leer_celdas(contenido)
    return {campo: str(celdas.get(ref) or "").strip() for ref, campo in CELDAS_GEO.items()}


def parsear(contenido: bytes, *, codigo: str = "") -> dict[str, float | None]:
    """Devuelve {variable: valor} para las 160 variables de ``campos.csv``.

    Lanza :class:`FichaInvalida` si algún rótulo no está donde debería.
    """
    try:
        celdas = _leer_celdas(contenido)
    except FichaInvalida as e:
        raise FichaInvalida(f"{codigo}: {e}") from None
    except (zipfile.BadZipFile, ET.ParseError, KeyError) as e:
        raise FichaInvalida(
            f"{codigo}: XLSX ilegible ({type(e).__name__}: {e})") from None

    desajustes = []
    valores: dict[str, float | None] = {}
    for c in CAMPOS:
        crudo = celdas.get(c.celda_rotulo)
        hallado = _norm(crudo)
        esperado = _norm(c.rotulo_esperado)
        # Comparación por prefijo: el INE a veces alarga un rótulo añadiendo
        # aclaraciones al final, y eso no invalida la posición.
        if not (hallado == esperado or hallado.startswith(esperado)):
            desajustes.append(
                f"  {c.celda_rotulo}: esperaba {c.rotulo_esperado!r}, hay {crudo!r}"
            )
            continue
        valores[c.variable] = _a_numero(celdas.get(c.celda))

    if desajustes:
        raise FichaInvalida(
            f"{codigo}: el layout de la ficha cambió en {len(desajustes)} celda(s).\n"
            + "\n".join(desajustes[:10])
            + "\nRevisa data-raw/fichas/campos.csv contra una ficha nueva "
            "(uv run data-raw/fichas/sondeo.py)."
        )
    return valores


def coherencia(valores: dict[str, float | None], personas: int, viviendas: int) -> list[str]:
    """Contrasta la ficha contra los totales de ``verificar-validar``.

    Devuelve la lista de discrepancias (vacía si todo cuadra). No aborta: son
    señales para revisar, no necesariamente errores. Ojo: varios bloques son de
    respuesta múltiple (salud, TIC) y ahí la suma de categorías **no** debe
    cuadrar con el total; por eso solo se comprueban los que sí son excluyentes.
    """
    avisos = []

    def suma(*vs):
        return sum(valores.get(v) or 0 for v in vs)

    pob = suma("pob_total_h", "pob_total_m")
    if personas is not None and pob != personas:
        avisos.append(
            f"población de la ficha ({pob:.0f}) != verificar-validar ({personas})")

    edades = suma(
        "pob_edad_0a19_h", "pob_edad_0a19_m",
        "pob_edad_20a39_h", "pob_edad_20a39_m",
        "pob_edad_40a59_h", "pob_edad_40a59_m",
        "pob_edad_60ymas_h", "pob_edad_60ymas_m",
    )
    if edades != pob:
        avisos.append(
            f"suma de grupos de edad ({edades:.0f}) != población total ({pob:.0f})")

    viv = valores.get("viv_total")
    if viviendas is not None and viv is not None and viv != viviendas:
        avisos.append(
            f"viviendas de la ficha ({viv:.0f}) != verificar-validar ({viviendas})")

    return avisos

"""Cliente del API del geoportal del INE (CPV-2024, nivel manzano y comunidad).

El INE opera dos portales con el mismo origen de datos:

  - ``idg.ine.gob.bo``          : portal nuevo. Autentica con un handshake ECDH
                                  P-256 + AES-256-GCM y exige captcha
                                  (reCAPTCHA / Turnstile) en los endpoints que
                                  entregan el listado de manzanos y las fichas.
  - ``wgeoportal.ine.gob.bo``   : backend de https://geoportal.ine.gob.bo/.
                                  Token anónimo, sin captcha. Es el que usa este
                                  módulo.

Ver dev-docs/fuentes-ine.md para el detalle del hallazgo.

Endpoints usados (todos POST, JSON):

  POST /geoportal/registroSesion                 -> {session_token, token_type}
  POST /selecccion/depMunSeleccionadoPoligono    -> manzanos urbanos (polígonos)
  POST /selecccion/depMunSeleccionadoPunto       -> comunidades rurales (puntos)
  POST /ficha-tecnica/verificar-validar          -> personas/viviendas + si hay ficha
  POST /generar-excel                            -> XLSX de la ficha

El nombre ``selecccion`` lleva tres "c": es así en el API, no es una errata.
"""

from __future__ import annotations

import json
import random
import threading
import time
from dataclasses import dataclass

import requests

API_BASE = "https://wgeoportal.ine.gob.bo/api/v1"
PORTAL = "https://geoportal.ine.gob.bo"

HEADERS_BASE = {
    "Content-Type": "application/json",
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "es-ES,es;q=0.9",
    "Origin": PORTAL,
    "Referer": f"{PORTAL}/",
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
    ),
}

# El servidor devuelve XLSX con alguno de estos content-type.
CT_XLSX = (
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.ms-excel",
    "application/octet-stream",
)

REINTENTABLES = (408, 429, 500, 502, 503, 504)


class ErrorAPI(RuntimeError):
    """Fallo no recuperable al hablar con el API del INE."""


@dataclass
class Unidad:
    """Una unidad censal: manzano urbano o comunidad rural."""

    codigo: str
    nombre: str
    area: str  # "urbano" | "rural"
    idep: str
    iprov: str
    imun: str
    geojson: dict | None


class ClienteINE:
    """Cliente con sesión renovable y reintentos.

    El token es anónimo y dura 24 h. Se renueva solo ante 401/403. La instancia
    es segura para usarse desde varios hilos: cada hilo tiene su propia
    ``requests.Session`` y el token se comparte tras un lock.
    """

    def __init__(self, *, timeout: int = 60, max_reintentos: int = 6, pausa: float = 0.0):
        self.timeout = timeout
        self.max_reintentos = max_reintentos
        self.pausa = pausa  # segundos de cortesía entre peticiones, por hilo
        self._token: str | None = None
        self._lock = threading.Lock()
        self._local = threading.local()

    # -- sesión ----------------------------------------------------------

    @property
    def _sesion(self) -> requests.Session:
        s = getattr(self._local, "sesion", None)
        if s is None:
            s = requests.Session()
            s.headers.update(HEADERS_BASE)
            self._local.sesion = s
        return s

    def token(self, *, forzar: bool = False) -> str:
        with self._lock:
            if self._token and not forzar:
                return self._token
            r = self._sesion.post(
                f"{API_BASE}/geoportal/registroSesion", json={}, timeout=self.timeout
            )
            r.raise_for_status()
            tok = r.json().get("session_token")
            if not tok:
                raise ErrorAPI(f"registroSesion no devolvió session_token: {r.text[:200]}")
            self._token = tok
            return tok

    def _auth(self) -> dict[str, str]:
        # El frontend manda el token en ambas cabeceras; replicamos ese contrato.
        t = self.token()
        return {"Authorization": f"Bearer {t}", "X-Session-Token": t}

    # -- transporte ------------------------------------------------------

    def _post(self, ruta: str, cuerpo: dict, *, binario: bool = False):
        """POST con reintentos y backoff exponencial con jitter."""
        espera = 1.0
        ultimo = None
        for intento in range(1, self.max_reintentos + 1):
            if self.pausa:
                time.sleep(self.pausa)
            try:
                r = self._sesion.post(
                    f"{API_BASE}{ruta}",
                    json=cuerpo,
                    headers=self._auth(),
                    timeout=self.timeout,
                )
            except requests.RequestException as e:
                ultimo = e
            else:
                if r.status_code == 200:
                    if binario:
                        ct = r.headers.get("content-type", "").split(";")[0].strip()
                        if ct not in CT_XLSX:
                            # 200 con JSON de error: el servidor a veces responde
                            # así en vez de un código de error. Reintentable.
                            ultimo = ErrorAPI(f"{ruta}: esperaba XLSX, llegó {ct}: {r.text[:200]}")
                        else:
                            return r.content
                    else:
                        return r.json()
                elif r.status_code in (401, 403):
                    self.token(forzar=True)
                    ultimo = ErrorAPI(f"{ruta}: {r.status_code}, token renovado")
                elif r.status_code in REINTENTABLES:
                    ultimo = ErrorAPI(f"{ruta}: HTTP {r.status_code}")
                else:
                    raise ErrorAPI(f"{ruta}: HTTP {r.status_code} — {r.text[:300]}")

            if intento < self.max_reintentos:
                time.sleep(espera + random.random() * 0.5)
                espera = min(espera * 2, 60)

        raise ErrorAPI(f"{ruta}: agotados {self.max_reintentos} intentos. Último: {ultimo}")

    # -- endpoints -------------------------------------------------------

    def unidades(self, id_municipio: str, area: str) -> list[Unidad]:
        """Lista las unidades de un municipio.

        ``id_municipio`` son 6 dígitos: ``idep`` (2) + ``iprov`` (2) + ``imun`` (2).
        ``area`` es "urbano" (polígonos de manzano) o "rural" (puntos de comunidad).
        """
        if area == "urbano":
            ruta = "/selecccion/depMunSeleccionadoPoligono"
        elif area == "rural":
            ruta = "/selecccion/depMunSeleccionadoPunto"
        else:
            raise ValueError(f"area debe ser 'urbano' o 'rural', no {area!r}")

        datos = self._post(ruta, {"id": id_municipio, "tipo": "municipio"})
        # El endpoint de puntos envuelve en {"datos": [...]}; el de polígonos
        # devuelve la lista pelada.
        if isinstance(datos, dict):
            filas = datos.get("datos") or datos.get("resultadoFinal") or []
        else:
            filas = datos or []

        out = []
        for f in filas:
            codigo = f.get("id") or f.get("codigo")
            if not codigo:
                continue
            geo = f.get("geojson")
            if isinstance(geo, str):
                try:
                    geo = json.loads(geo)
                except json.JSONDecodeError:
                    geo = None
            out.append(
                Unidad(
                    codigo=str(codigo),
                    nombre=(f.get("nombre") or "").strip(),
                    area=area,
                    idep=id_municipio[0:2],
                    iprov=id_municipio[2:4],
                    imun=id_municipio[4:6],
                    geojson=geo,
                )
            )
        return out

    def validar(self, codigo: str) -> dict:
        """Personas, viviendas y si el INE libera la ficha de esta unidad.

        El INE oculta la ficha de unidades con poca población, por privacidad;
        en ese caso ``validado`` es False y solo hay conteos totales.
        """
        d = self._post("/ficha-tecnica/verificar-validar", {"codigos": [codigo]})
        return {
            "validado": bool(d.get("validado")),
            "personas": d.get("cantidad_personas"),
            "viviendas": d.get("cantidad_viviendas"),
            "mensaje": d.get("mensaje"),
        }

    def ficha_xlsx(self, codigo: str, *, vivienda: bool = False) -> bytes:
        """Descarga la ficha en XLSX.

        ``vivienda=False`` trae la ficha base (población, educación, salud,
        migración, empleo, servicios); ``vivienda=True`` la ampliada de vivienda
        (materiales, hacinamiento, tipo de hogar).
        """
        return self._post(
            "/generar-excel", {"codigos": [codigo], "vivienda": vivienda}, binario=True
        )

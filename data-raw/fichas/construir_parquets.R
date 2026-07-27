## Construye los Parquet finales de manzanos y comunidades para el release.
##
## Entradas (las produce la descarga en esta misma carpeta):
##   unidades.parquet        codigo, nombre, area, idep, iprov, imun
##   unidades_final.parquet  codigo, area, geografía, personas, viviendas, ficha
##   fichas.parquet          codigo, geografía + 160 indicadores
##
## Salidas (en release/, listas para subir con upload_releases_fichas.R):
##   unidad.parquet   universo completo de unidades censales
##   ficha.parquet    solo las unidades cuya ficha libera el INE
##
## Las geometrías las genera construir_geometrias.py (WKB), no este script.
##
## Ejecutar desde la raíz del paquete:
##   Rscript data-raw/fichas/construir_parquets.R

library(arrow)

AQUI    <- "data-raw/fichas"
RELEASE <- file.path(AQUI, "release")
dir.create(RELEASE, showWarnings = FALSE)

load("data/geo_bolivia.rda")

leer <- function(x) as.data.frame(arrow::read_parquet(file.path(AQUI, x)))

# La descarga escribe "urbano"/"rural"; el paquete usa 1 = Urbana, 2 = Rural.
.codificar_area <- function(x) {
  cod <- c(urbano = 1L, rural = 2L)[x]
  stopifnot("hay valores de area desconocidos" = !anyNA(cod))
  unname(cod)
}

# ── 1. UNIDADES ──────────────────────────────────────────────────────────────

nombres  <- leer("unidades.parquet")[, c("codigo", "nombre")]
unidades <- leer("unidades_final.parquet")

unidades <- merge(unidades, nombres, by = "codigo", all.x = TRUE)
unidades$ficha <- as.logical(unidades$ficha)
# `area` se guarda con el mismo dominio que en los microdatos (1 = Urbana,
# 2 = Rural) para no tener dos vocabularios del mismo concepto en el paquete.
unidades$area <- .codificar_area(unidades$area)
unidades <- unidades[, c("codigo", "area", "idep", "iprov", "imun", "nombre",
                         "personas", "viviendas", "ficha")]
unidades <- unidades[order(unidades$codigo), ]
row.names(unidades) <- NULL

# ── 2. FICHAS ────────────────────────────────────────────────────────────────

fichas <- leer("fichas.parquet")
fichas$area <- .codificar_area(fichas$area)
fichas <- fichas[order(fichas$codigo), ]
row.names(fichas) <- NULL

# ── 2b. FICHA AMPLIADA DE VIVIENDA (34 campos) ───────────────────────────────
# Materiales, hacinamiento y tipo de hogar salían de una segunda ficha que el
# portal antiguo (idg.ine.gob.bo) entregaba y el actual ya no: el flag `vivienda`
# se ignora en todas sus variantes (ver sondeo_vivienda.py). La única captura
# que existe es la de los repos atlasurbano/atlasrural, hecha en junio de 2026
# cuando ese endpoint aún respondía. Son datos públicos del INE.
#
# No se incorporan a ciegas: abajo se validan contra la ficha PDF oficial y
# contra nuestros propios conteos de viviendas. Ver fuentes-ine-geoportal.md.

VIV_FUENTES <- file.path("original-data/otros",
                         c("atlasurbano-main", "atlasrural-main"),
                         "datos/fichas.parquet")

if (all(file.exists(VIV_FUENTES))) {
  mapa_viv <- utils::read.csv(file.path(AQUI, "campos_vivienda.csv"),
                              stringsAsFactors = FALSE, encoding = "UTF-8")
  stopifnot(nrow(mapa_viv) == 34, !anyDuplicated(mapa_viv$variable))

  viv <- do.call(rbind, lapply(VIV_FUENTES, function(f) {
    d <- as.data.frame(arrow::read_parquet(f))
    faltan <- setdiff(mapa_viv$variable_origen, names(d))
    if (length(faltan)) {
      stop("la fuente ", f, " no tiene: ", paste(faltan, collapse = ", "))
    }
    d[, c("codigo", mapa_viv$variable_origen)]
  }))
  viv <- viv[!duplicated(viv$codigo), ]           # urbano y rural se solapan
  names(viv) <- c("codigo", mapa_viv$variable)

  # -- Validación 1: coherencia contra nuestros propios conteos --------------
  # Cada bloque debe sumar las viviendas particulares con personas presentes
  # (que también son los hogares), dato que descargamos por separado del API.
  # Si el parseo de origen estuviera desplazado, estas sumas no cuadrarían.
  chk <- merge(fichas[, c("codigo", "viv_tipo_presentes")], viv, by = "codigo")
  bloques <- list(
    pared    = grep("^mat_pared_",   names(viv), value = TRUE),
    revoque  = grep("^mat_revoque_", names(viv), value = TRUE),
    techo    = grep("^mat_techo_",   names(viv), value = TRUE),
    piso     = grep("^mat_piso_",    names(viv), value = TRUE),
    hac      = grep("^hac_",         names(viv), value = TRUE),
    hogar    = grep("^hogar_",       names(viv), value = TRUE)
  )
  for (b in names(bloques)) {
    descuadre <- sum(rowSums(chk[, bloques[[b]]]) != chk$viv_tipo_presentes)
    if (descuadre > 0) {
      stop(sprintf("bloque '%s' de la ficha de vivienda descuadra en %s de %s fichas",
                   b, format(descuadre, big.mark = ","), format(nrow(chk), big.mark = ",")))
    }
  }
  message(sprintf("  ficha de vivienda: %s bloques x %s fichas cuadran con viv_tipo_presentes",
                  length(bloques), format(nrow(chk), big.mark = ",")))

  # -- Validación 2: contra la ficha PDF oficial del INE ---------------------
  # Manzano 00417298575-A de Sucre, cuyo PDF está en
  # original-data/otros/atlasurbano-main/recursos/ficha_vivienda_ejemplo.pdf
  ref <- c(mat_pared_ladrillo = 38, mat_pared_adobe = 5, mat_revoque_con = 41,
           mat_revoque_sin = 2, mat_techo_calamina = 16, mat_techo_teja = 22,
           mat_techo_losa = 3, mat_piso_ceramica = 31, mat_piso_mosaico = 4,
           mat_piso_ladrillo = 2, hac_sin = 37, hac_medio = 4, hac_alto = 2,
           hogar_unipersonal = 8, hogar_monoparental = 10, hogar_extendido = 12)
  fila <- viv[viv$codigo == "00417298575-A", , drop = FALSE]
  if (nrow(fila) == 1) {
    mal <- names(ref)[vapply(names(ref), function(v) fila[[v]] != ref[[v]], logical(1))]
    if (length(mal)) {
      stop("no coincide con la ficha PDF oficial del INE en: ", paste(mal, collapse = ", "))
    }
    message("  ficha de vivienda: coincide con el PDF oficial del INE (", length(ref), " campos)")
  }

  antes <- nrow(fichas)
  fichas <- merge(fichas, viv, by = "codigo", all.x = TRUE)
  fichas <- fichas[order(fichas$codigo), ]
  row.names(fichas) <- NULL
  stopifnot("el merge de vivienda duplicó filas" = nrow(fichas) == antes)

  sin_viv <- sum(is.na(fichas$mat_pared_ladrillo))
  if (sin_viv > 0) {
    warning(sin_viv, " fichas sin datos de vivienda (no estaban en la captura de 2026-06).",
            call. = FALSE)
  }
} else {
  warning("no se encontró la captura de la ficha de vivienda: ",
          "ficha.parquet saldrá con 160 variables en vez de 194.", call. = FALSE)
}

# ── 3. VERIFICACIONES ────────────────────────────────────────────────────────
# Fallar aquí es mucho más barato que publicar un release con datos torcidos.

stopifnot(
  "hay códigos de unidad duplicados"     = !anyDuplicated(unidades$codigo),
  "hay códigos de ficha duplicados"      = !anyDuplicated(fichas$codigo),
  "hay fichas sin unidad correspondiente" = all(fichas$codigo %in% unidades$codigo),
  "area solo puede ser 1 (urbana) o 2 (rural)" = all(unidades$area %in% 1:2),
  "hay geografía vacía"                  = !anyNA(unidades$idep)
)

# La marca `ficha` de unidades debe coincidir exactamente con estar en fichas.
con_ficha <- unidades$codigo[unidades$ficha]
if (!setequal(con_ficha, fichas$codigo)) {
  stop("unidades$ficha no concuerda con las filas de ficha.parquet: ",
       length(setdiff(con_ficha, fichas$codigo)), " marcadas sin ficha, ",
       length(setdiff(fichas$codigo, con_ficha)), " con ficha sin marcar")
}

# Toda la geografía debe existir en geo_bolivia, que es la referencia del paquete.
clave_u <- unique(paste(unidades$idep, unidades$iprov, unidades$imun))
clave_g <- paste(geo_bolivia$idep, geo_bolivia$iprov, geo_bolivia$imun)
huerfanas <- setdiff(clave_u, clave_g)
if (length(huerfanas)) {
  stop("municipios que no están en geo_bolivia: ", paste(huerfanas, collapse = ", "))
}

# Descarga incompleta: avisar, no abortar (permite construir un release parcial
# a propósito, pero nunca por descuido). Hay que comparar contra el universo de
# `unidades.parquet`, porque `unidades_final.parquet` solo trae las ya validadas
# y por sí solo siempre parece completo.
universo <- nrow(nombres)
if (nrow(unidades) < universo) {
  warning(sprintf(
    "descarga incompleta: %s de %s unidades (%.1f%%). El release quedaría parcial.",
    format(nrow(unidades), big.mark = ","), format(universo, big.mark = ","),
    100 * nrow(unidades) / universo
  ), call. = FALSE)
} else if (nrow(unidades) > universo) {
  stop("hay más unidades que en el universo de unidades.parquet: revisa la descarga")
}

# ── 4. ESCRITURA ─────────────────────────────────────────────────────────────

escribir <- function(df, nombre) {
  ruta <- file.path(RELEASE, nombre)
  arrow::write_parquet(df, ruta, compression = "zstd", compression_level = 6)
  message(sprintf("  %-22s %8s filas x %3d col  %6.1f MB",
                  nombre, format(nrow(df), big.mark = ","), ncol(df),
                  file.size(ruta) / 1e6))
}

message("Escribiendo en ", RELEASE, ":")
escribir(unidades, "unidad.parquet")
escribir(fichas,   "ficha.parquet")

# ── 5. RESUMEN ───────────────────────────────────────────────────────────────

message("\nCobertura por área:")
for (a in 1:2) {
  s <- unidades[unidades$area == a, ]
  message(sprintf("  %-7s %7s unidades, %6.1f%% con ficha, %10s personas (%.1f%% con ficha)",
                  c("Urbana", "Rural")[a], format(nrow(s), big.mark = ","),
                  100 * mean(s$ficha),
                  format(sum(s$personas, na.rm = TRUE), big.mark = ","),
                  100 * sum(s$personas[s$ficha], na.rm = TRUE) /
                    sum(s$personas, na.rm = TRUE)))
}
message(sprintf("\nTotal: %s unidades, %s personas, %s viviendas",
                format(nrow(unidades), big.mark = ","),
                format(sum(unidades$personas, na.rm = TRUE), big.mark = ","),
                format(sum(unidades$viviendas, na.rm = TRUE), big.mark = ",")))

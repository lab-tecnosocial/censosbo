## Enriquece los codebooks con la taxonomía temática y los metadatos del DDI.
##
## Patch IDEMPOTENTE, al estilo de add_derived_vars.R: no reconstruye nada desde
## el xlsx del INE, solo añade/reescribe columnas por join sobre los .rda que ya
## existen. Correrlo dos veces produce archivos byte-idénticos.
##
## Escribe en data/:
##   codebook_meta.rda            + 7 columnas (2024)
##   codebook_historico_meta.rda  + 7 columnas (los 4 años; NA donde no aplica)
##   censo_temas_meta.rda         nuevo: catálogo de los 20 temas
##   censo_bloques_meta.rda       nuevo: los 15 bloques de las fichas
##   codebook_docs_meta.rda       nuevo: textos largos del DDI (383 filas)
##
## Y en data-raw/ddi/:
##   reporte_valores.md           discrepancias DDI vs REDATAM (no toca el dato)
##
## Requisitos: haber corrido build_codebook.R, build_codebooks_historicos.R,
## fichas/build_codebook_fichas.R y ddi/descargar_ddi.R. NO necesita el volumen
## externo de original-data/.
##
## Ejecutar desde la raíz del paquete:
##   Rscript data-raw/add_taxonomia_to_codebook.R

source("data-raw/ddi/parse_ddi.R")
source("data-raw/taxonomia/join_ddi.R")
source("data-raw/taxonomia/validar_taxonomia.R")

TAX_DIR <- "data-raw/taxonomia"

# Los cinco censos tienen diccionario DDI en el catálogo ANDA (estudios 132, 8,
# 10, 47 y 46), así que todos reciben taxonomía completa.
ANIOS_HISTORICOS <- c("1976", "1992", "2001", "2012")

# Columnas nuevas, en este orden. Van SIEMPRE al final, después de las cinco
# originales, cuyo orden es contrato con censos-explorer. Todos los codebooks
# reciben las nueve, con NA donde no aplican, para que codebook() devuelva la
# misma forma en los cinco censos y un rbind() entre años funcione.
COLS_TAXONOMIA <- c("tema", "capitulo", "pregunta", "pregunta_num", "origen",
                    "universo", "grupo_ine", "bloque", "denominador",
                    "valores_fuente")

# Garantiza que un codebook tenga las nueve columnas nuevas, en el orden canónico
# y al final. Idempotente.
homogeneizar <- function(cb) {
  for (col in COLS_TAXONOMIA) {
    if (!col %in% names(cb)) {
      cb[[col]] <- if (col == "pregunta_num") NA_integer_ else NA_character_
    }
  }
  base <- setdiff(names(cb), COLS_TAXONOMIA)
  cb[, c(base, COLS_TAXONOMIA), drop = FALSE]
}

load("data/codebook_meta.rda")
load("data/codebook_historico_meta.rda")

temas_csv <- utils::read.csv(file.path(TAX_DIR, "temas.csv"), stringsAsFactors = FALSE)
capitulos_csv <- utils::read.csv(file.path(TAX_DIR, "capitulos.csv"), stringsAsFactors = FALSE)
bloques_csv <- utils::read.csv(file.path(TAX_DIR, "bloque_tema.csv"),
                               stringsAsFactors = FALSE, na.strings = c("", "NA"))

leer_mapa <- function(anio) {
  utils::read.csv(file.path(TAX_DIR, sprintf("variable_tema_%d.csv", anio)),
                  stringsAsFactors = FALSE, na.strings = c("", "NA"))
}

# ==============================================================================
# capitulo: se deriva del número de pregunta; si no hay, se hereda del tema
# ==============================================================================

# Rangos de pregunta del cuestionario CPV-2024 -> capítulo.
CAPITULO_POR_PREGUNTA <- function(n) {
  ifelse(is.na(n), NA_character_,
  ifelse(n <= 2, "B",
  ifelse(n <= 19, "C",
  ifelse(n == 20, "D",
  ifelse(n == 21, "E",
  ifelse(n <= 23, "F", "G"))))))
}

derivar_capitulo <- function(pregunta_num, tema) {
  cap <- CAPITULO_POR_PREGUNTA(pregunta_num)
  # Sin número de pregunta (geografía, identificadores, derivadas, indicadores de
  # ficha) el capítulo se hereda del tema. Es coherente con que capítulo y tema
  # sean dos facetas independientes: la derivada `nivel_edu` no tiene pregunta
  # propia, pero pertenece al capítulo donde se preguntó por educación.
  falta <- is.na(cap)
  cap[falta] <- temas_csv$capitulo[match(tema[falta], temas_csv$tema)]
  cap
}

# ==============================================================================
# Enriquecer un codebook
# ==============================================================================

enriquecer <- function(cb, anio, con_capitulo) {
  anio <- as.integer(anio)
  mapa <- leer_mapa(anio)
  ddi <- ddi_preparado(anio)

  cb$.clave <- clave_codebook(cb, anio)
  k_map <- clave_codebook(mapa, anio)
  k_ddi <- clave_ddi(ddi, anio)

  # Biyección con el CSV curado, en ambas direcciones: una variable nueva del INE
  # debe abortar el build, no colarse sin tema.
  faltan_en_mapa <- setdiff(cb$.clave, k_map)
  if (length(faltan_en_mapa) > 0) {
    stop(sprintf(
      "%d: %d variable(s) del codebook sin fila en variable_tema_%d.csv:\n  %s\nCorre data-raw/taxonomia/semilla_variable_tema.R y añade las filas nuevas.",
      anio, length(faltan_en_mapa), anio, paste(faltan_en_mapa, collapse = "\n  ")
    ), call. = FALSE)
  }
  sobran_en_mapa <- setdiff(k_map, cb$.clave)
  if (length(sobran_en_mapa) > 0) {
    stop(sprintf("%d: %d fila(s) de variable_tema_%d.csv que no existen en el codebook:\n  %s",
                 anio, length(sobran_en_mapa), anio,
                 paste(sobran_en_mapa, collapse = "\n  ")), call. = FALSE)
  }

  i_map <- match(cb$.clave, k_map)
  i_ddi <- match(cb$.clave, k_ddi)

  cb$tema <- mapa$tema[i_map]
  cb$origen <- mapa$origen[i_map]
  cb$pregunta <- mapa$pregunta[i_map]
  cb$pregunta_num <- suppressWarnings(as.integer(sub("[^0-9].*$", "", cb$pregunta)))
  cb$universo <- ddi$universo[i_ddi]
  cb$grupo_ine <- ddi$grupo_ine[i_ddi]

  # `bloque` y `denominador` son competencia de fichas/build_codebook_fichas.R,
  # que los lee de campos.csv. Si ya vienen en el codebook no se tocan: una sola
  # fuente de verdad. El CSV de taxonomía solo los usa como referencia para
  # proponer el tema.
  if (!"bloque" %in% names(cb) && "bloque" %in% names(mapa)) {
    cb$bloque <- mapa$bloque[i_map]
  }

  cb$capitulo <- if (con_capitulo) derivar_capitulo(cb$pregunta_num, cb$tema) else NA_character_

  # Los indicadores de ficha y las unidades censales no están en el ANDA: su
  # universo se fija por el bloque, no por el DDI.
  if (anio == 2024L) {
    UNIV_BLOQUE <- c(unidad = "todas_viviendas", vivienda = "viviendas_presentes",
                     servicios = "viviendas_presentes", tic = "viviendas_presentes",
                     material = "viviendas_presentes", hacinamiento = "viviendas_presentes",
                     hogar = "viviendas_presentes")
    es_ind <- cb$tabla %in% c("ficha", "unidad") & is.na(cb$universo)
    cb$universo[es_ind] <- unname(UNIV_BLOQUE[cb$bloque[es_ind]])
    # Los bloques de personas (poblacion, educacion, salud_*, nacimiento,
    # residencia, ocupacion, actividad) se cuentan sobre personas.
    cb$universo[es_ind & is.na(cb$universo)] <- "todas_personas"
    # Los identificadores no tienen universo analítico.
    cb$universo[cb$origen == "identificador"] <- NA_character_
  }

  cb$.clave <- NULL
  cb
}

# ==============================================================================
# 1. codebook_meta (CPV-2024)
# ==============================================================================

message("Enriqueciendo codebook_meta (2024)...")

# `i00` (Nro. de vivienda) está documentado en el DDI y presente en los parquets,
# y .apply_variable_selection() lo devuelve siempre, pero no estaba descrito. Sin
# él, etiquetar_variables() no lo etiqueta y los consumidores no lo explican.
agregar_i00 <- function(cb) {
  ya <- tolower(cb$variable) == "i00"
  if (any(ya)) {
    message("  i00 ya estaba en codebook_meta; no se duplica.")
    return(cb)
  }
  tablas <- c("persona", "vivienda", "emigracion", "mortalidad")
  nuevas <- data.frame(
    variable = "i00",
    etiqueta = "Número de vivienda dentro del predio",
    tabla = tablas,
    tipo = "categorica",
    stringsAsFactors = FALSE
  )
  nuevas$valores_codigos <- vector("list", nrow(nuevas))
  # Respetar el orden de columnas del codebook.
  nuevas <- nuevas[, names(cb)[names(cb) %in% names(nuevas)], drop = FALSE]
  faltan <- setdiff(names(cb), names(nuevas))
  for (f in faltan) nuevas[[f]] <- if (f == "valores_codigos") vector("list", nrow(nuevas)) else NA
  rbind(cb, nuevas[, names(cb), drop = FALSE])
}

codebook_meta <- agregar_i00(codebook_meta)

# El DDI documenta i00 en las 4 tablas, así que tras añadirlo el join es total.
ddi24 <- ddi_preparado(2024)
cb_micro <- codebook_meta[codebook_meta$tabla %in%
                            c("persona", "vivienda", "emigracion", "mortalidad"), ]
if (!any(tolower(cb_micro$variable) == "i00")) {
  verificar_join_2024(cb_micro, ddi24)
} else {
  # Con i00 ya presente, la única discrepancia esperada es `persona area`.
  k_cb <- clave_codebook(cb_micro, 2024)
  k_ddi <- clave_ddi(ddi24, 2024)
  stopifnot(length(setdiff(k_ddi, k_cb)) == 0)
  stopifnot(identical(sort(setdiff(k_cb, k_ddi)), sort(JOIN_2024_SOLO_CB)))
}

codebook_meta <- enriquecer(codebook_meta, 2024, con_capitulo = TRUE)

# ==============================================================================
# 2. codebook_historico_meta (2012 y 2001 con taxonomía; 1976 y 1992 con NA)
# ==============================================================================

for (anio in ANIOS_HISTORICOS) {
  cb <- codebook_historico_meta[[anio]]
  if (is.null(cb)) next
  message(sprintf("Enriqueciendo codebook_historico_meta[[%s]]...", anio))
  # `capitulo` es solo del cuestionario CPV-2024: los anteriores tienen otra
  # estructura y, en 1976, 1992 y 2001, numeran vivienda y persona en paralelo.
  codebook_historico_meta[[anio]] <- enriquecer(cb, anio, con_capitulo = FALSE)
}

# ==============================================================================
# 3. Datasets nuevos de la taxonomía
# ==============================================================================

message("Construyendo censo_temas_meta y censo_bloques_meta...")

# En qué censos existe cada tema, calculado del dato en vez de declarado a mano.
anios_por_tema <- function(tema) {
  presentes <- character()
  if (tema %in% codebook_meta$tema) presentes <- c(presentes, "2024")
  for (a in c("2012", "2001", "1992", "1976")) {
    if (tema %in% codebook_historico_meta[[a]]$tema) presentes <- c(presentes, a)
  }
  paste(presentes, collapse = ",")
}

# Todos los capítulos en que aparece cada tema (2024, el único con capítulos).
capitulos_por_tema <- function(tema) {
  caps <- sort(unique(na.omit(codebook_meta$capitulo[codebook_meta$tema == tema])))
  paste(caps, collapse = ",")
}

censo_temas_meta <- data.frame(
  tema = temas_csv$tema,
  etiqueta = temas_csv$etiqueta,
  capitulo = temas_csv$capitulo,
  capitulo_etiqueta = capitulos_csv$etiqueta[match(temas_csv$capitulo, capitulos_csv$capitulo)],
  capitulos = vapply(temas_csv$tema, capitulos_por_tema, character(1), USE.NAMES = FALSE),
  anios = vapply(temas_csv$tema, anios_por_tema, character(1), USE.NAMES = FALSE),
  fuente = temas_csv$fuente,
  orden = as.integer(temas_csv$orden),
  descripcion = temas_csv$descripcion,
  stringsAsFactors = FALSE
)
censo_temas_meta <- censo_temas_meta[order(censo_temas_meta$orden), ]
rownames(censo_temas_meta) <- NULL

censo_bloques_meta <- data.frame(
  bloque = bloques_csv$bloque,
  etiqueta = bloques_csv$etiqueta_bloque,
  tema = bloques_csv$tema,
  capitulo = bloques_csv$capitulo,
  orden = as.integer(bloques_csv$orden),
  stringsAsFactors = FALSE
)
censo_bloques_meta <- censo_bloques_meta[order(censo_bloques_meta$orden), ]
rownames(censo_bloques_meta) <- NULL

# ==============================================================================
# 4. codebook_docs_meta: los textos largos del DDI
# ==============================================================================

message("Construyendo codebook_docs_meta...")

docs_de <- function(anio) {
  cb <- if (anio == 2024) codebook_meta else codebook_historico_meta[[as.character(anio)]]
  ddi <- ddi_preparado(anio)
  k_cb <- clave_codebook(cb, anio)
  k_ddi <- clave_ddi(ddi, anio)

  # Una fila por variable del DDI que tenga par en el codebook, con el nombre y la
  # tabla del CODEBOOK (que es como el usuario la va a pedir).
  i <- match(k_ddi, k_cb)
  ok <- !is.na(i)
  data.frame(
    anio = as.integer(anio),
    variable = cb$variable[i[ok]],
    tabla = cb$tabla[i[ok]],
    variable_ddi = ddi$variable_ddi[ok],
    definicion = ddi$definicion[ok],
    universo_literal = ddi$universo_literal[ok],
    pregunta_literal = ddi$pregunta_literal[ok],
    regla_derivacion = ddi$regla_derivacion[ok],
    notas = ddi$notas[ok],
    informante = ddi$informante_norm[ok],
    instruccion = ddi$instruccion[ok],
    stringsAsFactors = FALSE
  )
}

codebook_docs_meta <- do.call(rbind, lapply(c(2024, 2012, 2001, 1992, 1976), docs_de))
codebook_docs_meta <- codebook_docs_meta[
  order(codebook_docs_meta$anio, codebook_docs_meta$tabla, codebook_docs_meta$variable), ]
rownames(codebook_docs_meta) <- NULL

# Procedencia: codebook_docs_meta reproduce texto oficial del INE verbatim
# (definiciones e instrucciones al censista), así que la atribución es requisito.
manifest <- utils::read.csv("data-raw/ddi/MANIFEST.csv", stringsAsFactors = FALSE)
attr(codebook_docs_meta, "ddi") <- manifest[, c("anio", "estudio", "idno", "url",
                                                "fecha", "sha256", "n_var")]

# ==============================================================================
# 5. valores_codigos: completar desde el DDI (2012 y 2001) y reportar
# ==============================================================================

source("data-raw/taxonomia/completar_valores.R")

res <- completar_valores_codigos(codebook_historico_meta,
                                 anios = c(2012, 2001, 1992, 1976))
codebook_historico_meta <- res$codebook
writeLines(res$reporte, "data-raw/ddi/reporte_valores.md")
message(sprintf("  completadas %d variable(s); %d discrepancia(s) en reporte_valores.md",
                res$n_completadas, res$n_discrepancias))

# ==============================================================================
# 6. Validar y escribir
# ==============================================================================

# Orden de filas determinista. Sin esto, la posición de las cuatro filas de `i00`
# depende de si fichas/build_codebook_fichas.R corrió antes o después de que
# existieran, así que dos reconstrucciones del pipeline daban el mismo contenido en
# distinto orden y `data/*.rda` aparecía modificado sin cambios reales.
#
# El orden es el de `codebook()`: agrupa por tabla y, dentro de cada tabla, conserva
# el orden del cuestionario del INE (`order` es estable).
ordenar_filas <- function(cb) {
  tabla_orden <- c("persona", "vivienda", "emigracion", "mortalidad", "discapacidad",
                   "unidad", "ficha", "depto", "provin", "munic")
  rango <- match(cb$tabla, tabla_orden)
  rango[is.na(rango)] <- length(tabla_orden) + 1L
  cb <- cb[order(rango), ]
  rownames(cb) <- NULL
  cb
}
codebook_meta <- ordenar_filas(codebook_meta)
for (anio in ANIOS_HISTORICOS) {
  codebook_historico_meta[[anio]] <- ordenar_filas(codebook_historico_meta[[anio]])
}

# Esquema homogéneo: las nueve columnas nuevas, en el mismo orden, al final de
# los cinco codebooks. Se hace justo antes de validar y escribir, después de que
# completar_valores_codigos() haya añadido `valores_fuente`.
codebook_meta <- homogeneizar(codebook_meta)
for (anio in ANIOS_HISTORICOS) {
  codebook_historico_meta[[anio]] <- homogeneizar(codebook_historico_meta[[anio]])
}
esquemas <- unique(c(
  list(names(codebook_meta)),
  lapply(ANIOS_HISTORICOS, function(a) names(codebook_historico_meta[[a]]))
))
if (length(esquemas) > 1) {
  # Las cinco primeras columnas difieren de orden entre codebook_meta y los
  # históricos desde antes de esta entrega; codebook() las reordena al devolver.
  nuevas <- lapply(esquemas, function(n) n[(length(n) - length(COLS_TAXONOMIA) + 1):length(n)])
  stopifnot(length(unique(nuevas)) == 1L)
  stopifnot(length(unique(lapply(esquemas, sort))) == 1L)
}

mapas <- c(list(`2024` = codebook_meta),
           stats::setNames(lapply(ANIOS_HISTORICOS,
                                  function(a) codebook_historico_meta[[a]]),
                           ANIOS_HISTORICOS))
validar_taxonomia(mapas, temas_csv, capitulos_csv, bloques_csv)

usethis::use_data(codebook_meta, overwrite = TRUE, compress = "xz")
usethis::use_data(codebook_historico_meta, overwrite = TRUE, compress = "xz")
usethis::use_data(censo_temas_meta, overwrite = TRUE, compress = "xz")
usethis::use_data(censo_bloques_meta, overwrite = TRUE, compress = "xz")
usethis::use_data(codebook_docs_meta, overwrite = TRUE, compress = "xz")

message("\nResumen:")
message(sprintf("  codebook_meta:           %d filas x %d cols",
                nrow(codebook_meta), ncol(codebook_meta)))
for (a in ANIOS_HISTORICOS) {
  message(sprintf("  historico[[%s]]:        %d filas x %d cols", a,
                  nrow(codebook_historico_meta[[a]]), ncol(codebook_historico_meta[[a]])))
}
message(sprintf("  censo_temas_meta:        %d filas", nrow(censo_temas_meta)))
message(sprintf("  censo_bloques_meta:      %d filas", nrow(censo_bloques_meta)))
message(sprintf("  codebook_docs_meta:      %d filas", nrow(codebook_docs_meta)))
message(sprintf("  data/ total:             %.0f KB",
                sum(file.info(list.files("data", full.names = TRUE))$size) / 1024))

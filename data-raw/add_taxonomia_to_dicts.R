## Publica la taxonomía en los diccionarios de los GitHub Releases.
##
## Gemelo de add_tipo_to_dicts.R: mismo join por entidad+variable, misma escritura
## in-place sobre `diccionario_variables.parquet`.
##
## Un solo diccionario, no dos. Se consideró publicar las columnas nuevas en un
## asset aparte (`_v2`) para no tocar el que ya leen los consumidores, porque la
## caché del plugin de QGIS no se invalida nunca: `_download_file()` hace
## `if os.path.exists(dest): return` y la ruta no depende del tag del release.
##
## Se descartó: mantener dos assets en paralelo es complejidad permanente, y con
## los consumidores bajo el mismo control basta con vaciar la caché una vez. Lo que
## SÍ hay que hacer es añadir esa acción al plugin — ver
## dev-docs/consumidores-taxonomia.md.
##
## Ejecutar DESPUÉS de add_taxonomia_to_codebook.R y add_tipo_to_dicts.R:
##   Rscript data-raw/add_taxonomia_to_dicts.R

library(arrow)

# Ruta a las fuentes del INE (disco externo, montado solo a demanda).
source("data-raw/_rutas.R")

## Contrato del diccionario publicado. Estos nombres son públicos y estables: el
## plugin debe leerlos por nombre exacto, no con la búsqueda aproximada de
## _find_col(). Documentado en dev-docs/pipeline-datos.md y
## consumidores-taxonomia.md.
COLS_TAXONOMIA <- c("tema", "tema_etiqueta", "capitulo", "capitulo_etiqueta",
                    "pregunta", "pregunta_num", "origen", "universo", "grupo_ine",
                    "denominador")

load("data/codebook_meta.rda")
load("data/codebook_historico_meta.rda")
load("data/censo_temas_meta.rda")

# Etiquetas legibles, denormalizadas: un consumidor que no puede ejecutar R no
# podría hacer el join con censo_temas_meta.
tema_etiqueta_de <- function(tema) {
  censo_temas_meta$etiqueta[match(tema, censo_temas_meta$tema)]
}
capitulo_etiqueta_de <- function(capitulo) {
  ref <- unique(censo_temas_meta[, c("capitulo", "capitulo_etiqueta")])
  ref$capitulo_etiqueta[match(capitulo, ref$capitulo)]
}

agregar_taxonomia <- function(dir, meta, anio) {
  vpath <- file.path(dir, "diccionario_variables.parquet")
  if (!file.exists(vpath)) return(invisible(NULL))
  vars <- as.data.frame(read_parquet(vpath))

  # Igual que add_tipo_to_dicts.R: 1976 usa "tabla" donde el resto usa "entidad".
  ent_col <- if ("entidad" %in% names(vars)) "entidad" else
    if ("tabla" %in% names(vars)) "tabla" else NA

  meta_key <- paste(tolower(meta$tabla), tolower(meta$variable))
  vars_key <- paste(
    if (!is.na(ent_col)) tolower(vars[[ent_col]]) else NA_character_,
    tolower(vars$variable)
  )
  j <- match(vars_key, meta_key)

  # Idempotente: si el parquet ya trae las columnas de una corrida anterior, se
  # reescriben con el valor actual en vez de duplicarse.
  vars <- vars[, setdiff(names(vars), COLS_TAXONOMIA), drop = FALSE]

  vars$tema              <- meta$tema[j]
  vars$tema_etiqueta     <- tema_etiqueta_de(vars$tema)
  vars$capitulo          <- meta$capitulo[j]
  vars$capitulo_etiqueta <- capitulo_etiqueta_de(vars$capitulo)
  vars$pregunta          <- meta$pregunta[j]
  vars$pregunta_num      <- as.integer(meta$pregunta_num[j])
  vars$origen            <- meta$origen[j]
  vars$universo          <- meta$universo[j]
  vars$grupo_ine         <- meta$grupo_ine[j]
  vars$denominador       <- if ("denominador" %in% names(meta)) meta$denominador[j] else NA_character_

  stopifnot(all(COLS_TAXONOMIA %in% names(vars)))
  write_parquet(vars, vpath)

  sin_tema <- sum(is.na(vars$tema))
  message(sprintf("  %-52s  %d filas, %d con tema%s", sub("^original-data/", "", vpath),
                  nrow(vars), nrow(vars) - sin_tema,
                  if (sin_tema > 0) sprintf(" (%d sin par en el codebook)", sin_tema) else ""))
  invisible(vars)
}

# `original-data/` es un symlink a un volumen externo. Si no está montado, los
# file.exists() fallan uno a uno y el script termina sin haber hecho nada, con
# apariencia de éxito. Mejor abortar con un mensaje claro.
if (!dir.exists(od())) {
  stop("`original-data/` no está accesible: monta el volumen externo antes de correr esto.\n",
       "  Es un symlink a /Volumes/eDriveA/. Sin él no hay parquets que actualizar.",
       call. = FALSE)
}

message("CPV-2024:")
n <- agregar_taxonomia(od("r/cpv-2024/parquets"), codebook_meta, 2024)
if (is.null(n)) {
  stop("No se encontró original-data/r/cpv-2024/parquets/diccionario_variables.parquet.",
       call. = FALSE)
}

message("\nCensos históricos:")
escritos <- 0L
for (anio in c("1976", "1992", "2001", "2012")) {
  meta <- codebook_historico_meta[[anio]]
  for (raiz in c(od("r/censos-historicos"),
                 od("python/censos-historicos"))) {
    res <- agregar_taxonomia(file.path(raiz, paste0("censo_", anio)), meta, as.integer(anio))
    if (!is.null(res)) escritos <- escritos + 1L
  }
}
if (escritos == 0L) {
  stop("No se actualizó ningún diccionario histórico; revisa las rutas.", call. = FALSE)
}

message("\nListo: los diccionarios publicados llevan la taxonomía.")
message("OJO: la caché del plugin de QGIS (~/.censosbo_qgis/) no se invalida sola.")
message("     Hay que vaciarla una vez para que baje la versión nueva.")
message("Contrato de las columnas: dev-docs/consumidores-taxonomia.md")

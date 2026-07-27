## Sube los Parquet de manzanos y comunidades al release data-fichas-v1.0.0.
##
## Usa el CLI `gh`, que toma las credenciales ya configuradas de la máquina
## (`gh auth status` para comprobarlas). No hace falta exportar ningún token.
##
## Uso:
##   Rscript data-raw/fichas/upload_releases_fichas.R
##   Rscript data-raw/fichas/upload_releases_fichas.R --dry-run

REPO    <- "lab-tecnosocial/censosbo"
TAG     <- "data-fichas-v1.0.0"
RELEASE <- "data-raw/fichas/release"

ARCHIVOS <- c(
  "unidad.parquet",
  "ficha.parquet",
  sprintf("geo_manzano_dep%02d.parquet", 1:9),
  "geo_comunidad.parquet"
)

NOTAS <- paste(
  "Datos agregados del Censo de Población y Vivienda 2024 de Bolivia a nivel de",
  "manzano urbano y comunidad rural, obtenidos de las fichas resumen del",
  "geoportal del INE (https://geoportal.ine.gob.bo/).",
  "",
  "| Archivo | Contenido |",
  "|---|---|",
  "| `unidad.parquet` | 268.604 unidades censales con población, viviendas y si tienen ficha |",
  "| `ficha.parquet` | 194 indicadores para las 150.744 unidades cuya ficha libera el INE |",
  "| `geo_manzano_dep01..09.parquet` | Polígonos de manzanos por departamento (WKB, EPSG:4326) |",
  "| `geo_comunidad.parquet` | Geometrías de comunidades rurales (en su mayoría puntos) |",
  "",
  "El INE no publica la ficha de las unidades con poca población, por reserva",
  "estadística: queda fuera el 47% de los manzanos, pero las que sí la tienen",
  "cubren el 92% de la población y el 90% de las viviendas del país.",
  "",
  "Se accede desde R con `get_unidades_2024()`, `get_fichas_2024()`,",
  "`get_geo_manzanos()` y `get_geo_comunidades()` del paquete censosbo.",
  sep = "\n"
)

dry <- "--dry-run" %in% commandArgs(trailingOnly = TRUE)

# Los argumentos se entrecomillan: `system2()` no lo hace, así que un título con
# espacios llegaría a gh partido en varios argumentos. Y se comprueba el estado
# de salida: sin esto, un fallo al crear el release pasa desapercibido y el
# script sigue hasta anunciar un éxito que no ocurrió.
gh <- function(...) {
  args <- vapply(c(...), shQuote, character(1), USE.NAMES = FALSE)
  if (dry) {
    message("  [dry-run] gh ", paste(args, collapse = " "))
    return(invisible(character(0)))
  }
  salida <- suppressWarnings(system2("gh", args, stdout = TRUE, stderr = TRUE))
  estado <- attr(salida, "status")
  if (!is.null(estado) && estado != 0) {
    stop("falló `gh ", paste(c(...)[1:2], collapse = " "), "` (estado ", estado, "):\n  ",
         paste(salida, collapse = "\n  "), call. = FALSE)
  }
  invisible(salida)
}

# ── Comprobaciones previas ───────────────────────────────────────────────────

if (Sys.which("gh") == "") {
  stop("No se encontró el CLI `gh`. Instálalo con: brew install gh")
}

rutas <- file.path(RELEASE, ARCHIVOS)
faltan <- ARCHIVOS[!file.exists(rutas)]
if (length(faltan)) {
  stop("Faltan archivos en ", RELEASE, ":\n  ", paste(faltan, collapse = "\n  "),
       "\nEjecuta antes construir_parquets.R y construir_geometrias.py.")
}

# Un Parquet truncado subiría sin quejarse y rompería a los usuarios: se
# comprueba que cada archivo se abre y cuántas filas tiene antes de publicarlo.
suppressMessages(library(arrow))
message("Verificando los ", length(ARCHIVOS), " archivos:")
for (i in seq_along(ARCHIVOS)) {
  n <- tryCatch(nrow(arrow::read_parquet(rutas[i], col_select = 1)),
                error = function(e) stop("no se puede leer ", ARCHIVOS[i], ": ",
                                         conditionMessage(e)))
  message(sprintf("  %-28s %9s filas  %6.1f MB",
                  ARCHIVOS[i], format(n, big.mark = ","),
                  file.size(rutas[i]) / 1e6))
}

# ── Crear el release si no existe ────────────────────────────────────────────

existe <- length(suppressWarnings(
  system2("gh", c("release", "view", TAG, "--repo", REPO, "--json", "tagName"),
          stdout = TRUE, stderr = FALSE)
)) > 0

notas_tmp <- tempfile(fileext = ".md")
writeLines(NOTAS, notas_tmp)

if (!existe) {
  message("\nCreando release ", TAG, "...")
  gh("release", "create", TAG,
     "--repo", REPO,
     "--title", "Datos agregados CPV-2024 por manzano y comunidad",
     "--notes-file", notas_tmp)
} else {
  message("\nEl release ", TAG, " ya existe: se actualizan notas y archivos.")
  gh("release", "edit", TAG,
     "--repo", REPO,
     "--title", "Datos agregados CPV-2024 por manzano y comunidad",
     "--notes-file", notas_tmp)
}

# ── Subir ────────────────────────────────────────────────────────────────────

message("Subiendo ", length(rutas), " archivos (",
        round(sum(file.size(rutas)) / 1e6, 1), " MB en total)...")
gh(c("release", "upload", TAG, rutas, "--repo", REPO, "--clobber"))

message("\nListo: https://github.com/", REPO, "/releases/tag/", TAG)

# Sube los parquets del CPV-2024 al release data-v1.0.0 en GitHub.
# Requiere GITHUB_PAT con permisos de escritura.
#
# Uso:
#   Sys.setenv(GITHUB_PAT = "ghp_xxxx")
#   source("data-raw/upload_releases_2024.R")
#
# Los parquets de persona (con columna 'area' pre-unida desde vivienda) se
# generan con:  /opt/homebrew/bin/python3 data-raw/add_area_to_persona.py

library(piggyback)

REPO    <- "lab-tecnosocial/censosbo"
TAG     <- "data-v1.0.0"
DIR_OUT <- "original-data/cpv-2024/parquets"

# Archivos a subir (persona_dep01-09 con area; vivienda/emigracion/mortalidad sin cambios)
PERSONA_DEPS <- sprintf("persona_dep%02d.parquet", 1:9)

# vivienda, emigracion, mortalidad se leen del caché (no cambiaron)
CACHE <- file.path(
  Sys.getenv("HOME"),
  "Library/Caches/org.R-project.R/R/censosbo"
)
OTROS <- c("vivienda.parquet", "emigracion.parquet", "mortalidad.parquet")

message("=== Subiendo CPV-2024 al release ", TAG, " ===\n")

# Verificar que el release existe
releases_existentes <- tryCatch(
  pb_list(repo = REPO)$tag,
  error = function(e) character(0)
)
if (!TAG %in% releases_existentes) {
  message("Creando release ", TAG, "...")
  pb_new_release(
    repo = REPO, tag = TAG,
    name = "Datos CPV-2024 Bolivia",
    body = "Microdatos del Censo de Población y Vivienda 2024 de Bolivia (formato Parquet)."
  )
}

# Subir persona_dep01-09 (con columna area)
for (fname in PERSONA_DEPS) {
  path <- file.path(DIR_OUT, fname)
  if (!file.exists(path)) {
    warning("No encontrado, saltando: ", path)
    next
  }
  mb <- round(file.size(path) / 1024^2, 1)
  message("  Subiendo ", fname, " (", mb, " MB)...")
  pb_upload(path, repo = REPO, tag = TAG, name = fname, overwrite = TRUE)
  message("  OK")
}

# Subir vivienda/emigracion/mortalidad desde caché (sin cambios)
for (fname in OTROS) {
  path <- file.path(CACHE, fname)
  if (!file.exists(path)) {
    warning("No encontrado en caché, saltando: ", path)
    next
  }
  mb <- round(file.size(path) / 1024^2, 1)
  message("  Subiendo ", fname, " (", mb, " MB)...")
  pb_upload(path, repo = REPO, tag = TAG, name = fname, overwrite = TRUE)
  message("  OK")
}

message("\nCPV-2024 completado. Verifica en:")
message("https://github.com/", REPO, "/releases/tag/", TAG)

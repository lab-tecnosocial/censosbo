# Script para crear los GitHub Releases de los censos históricos y subir los
# archivos Parquet. Requiere que GITHUB_PAT esté configurado con permisos de
# escritura en el repositorio.
#
# Uso:
#   Sys.setenv(GITHUB_PAT = "ghp_xxxx")
#   source("data-raw/upload_releases_historicos.R")
#
# Solo debe correrse una vez (o cuando se actualicen los datos).

library(piggyback)

REPO <- "lab-tecnosocial/censosbo"
BASE <- "original-data/censos-historicos"

# Mapa: anio → tag del release + archivos a subir
# local_name  = nombre del archivo en disco
# remote_name = nombre con que se sube al release (el que pide get_censo())
RELEASES <- list(

  "1976" = list(
    tag   = "data-1976-v1.0.0",
    dir   = file.path(BASE, "censo_1976"),
    files = list(
      list(local = "poblacion.parquet",             remote = "poblacion.parquet"),
      list(local = "vivienda.parquet",              remote = "vivienda.parquet"),
      list(local = "diccionario_variables.parquet", remote = "diccionario_variables.parquet"),
      list(local = "diccionario_etiquetas.parquet", remote = "diccionario_etiquetas.parquet")
    )
  ),

  "1992" = list(
    tag   = "data-1992-v1.0.0",
    dir   = file.path(BASE, "censo_1992"),
    files = list(
      list(local = "persona.parquet",               remote = "persona.parquet"),
      list(local = "vivienda.parquet",              remote = "vivienda.parquet"),
      list(local = "mortalidad.parquet",            remote = "mortalidad.parquet"),
      list(local = "depto.parquet",                 remote = "depto.parquet"),
      list(local = "provin.parquet",                remote = "provin.parquet"),
      list(local = "munic.parquet",                 remote = "munic.parquet"),
      list(local = "diccionario_variables.parquet", remote = "diccionario_variables.parquet"),
      list(local = "diccionario_etiquetas.parquet", remote = "diccionario_etiquetas.parquet")
    )
  ),

  "2001" = list(
    tag   = "data-2001-v1.0.0",
    dir   = file.path(BASE, "censo_2001"),
    files = list(
      list(local = "persona.parquet",               remote = "persona.parquet"),
      list(local = "vivienda.parquet",              remote = "vivienda.parquet"),
      # En disco: poblacion_comunidades.parquet → sube como: comunidades_poblacion.parquet
      list(local = "poblacion_comunidades.parquet", remote = "comunidades_poblacion.parquet"),
      list(local = "vivienda_comunidades.parquet",  remote = "comunidades_vivienda.parquet"),
      list(local = "depto.parquet",                 remote = "depto.parquet"),
      list(local = "provin.parquet",                remote = "provin.parquet"),
      list(local = "munic.parquet",                 remote = "munic.parquet"),
      list(local = "diccionario_variables.parquet", remote = "diccionario_variables.parquet"),
      list(local = "diccionario_etiquetas.parquet", remote = "diccionario_etiquetas.parquet")
    )
  ),

  "2012" = list(
    tag   = "data-2012-v1.0.0",
    dir   = file.path(BASE, "censo_2012"),
    files = list(
      list(local = "persona.parquet",               remote = "persona.parquet"),
      list(local = "vivienda.parquet",              remote = "vivienda.parquet"),
      list(local = "emigracion.parquet",            remote = "emigracion.parquet"),
      list(local = "discapacidad.parquet",          remote = "discapacidad.parquet"),
      list(local = "depto.parquet",                 remote = "depto.parquet"),
      list(local = "provin.parquet",                remote = "provin.parquet"),
      list(local = "munic.parquet",                 remote = "munic.parquet"),
      list(local = "diccionario_variables.parquet", remote = "diccionario_variables.parquet"),
      list(local = "diccionario_etiquetas.parquet", remote = "diccionario_etiquetas.parquet")
      # cpv2012.parquet no se sube: no es referenciado por ninguna función
    )
  )
)

# ─── Subir releases ───────────────────────────────────────────────────────────

for (anio in names(RELEASES)) {
  cfg <- RELEASES[[anio]]
  tag <- cfg$tag

  message("\n=== Censo ", anio, " (tag: ", tag, ") ===")

  # Crear el release si no existe
  releases_existentes <- tryCatch(
    pb_list(repo = REPO)$tag,
    error = function(e) character(0)
  )

  if (!tag %in% releases_existentes) {
    message("Creando release ", tag, "...")
    pb_new_release(repo = REPO, tag = tag,
                   name = paste("Datos censo", anio),
                   body = paste0(
                     "Microdatos del Censo Nacional de Población y Vivienda ",
                     anio, " de Bolivia (formato Parquet)."
                   ))
  } else {
    message("Release ", tag, " ya existe, subiendo archivos...")
  }

  # Subir cada archivo
  for (f in cfg$files) {
    local_path  <- file.path(cfg$dir, f$local)
    remote_name <- f$remote

    if (!file.exists(local_path)) {
      warning("Archivo no encontrado, saltando: ", local_path)
      next
    }

    size_mb <- round(file.size(local_path) / 1024^2, 1)
    message("  Subiendo ", remote_name, " (", size_mb, " MB)...")

    # Si local y remote tienen distinto nombre, copiar a un temporal
    if (f$local != remote_name) {
      tmp <- file.path(tempdir(), remote_name)
      file.copy(local_path, tmp, overwrite = TRUE)
      pb_upload(tmp, repo = REPO, tag = tag, name = remote_name, overwrite = TRUE)
      file.remove(tmp)
    } else {
      pb_upload(local_path, repo = REPO, tag = tag, name = remote_name, overwrite = TRUE)
    }

    message("  OK: ", remote_name)
  }

  message("Censo ", anio, " completado.")
}

message("\nTodos los releases subidos. Verifica en:")
message("https://github.com/", REPO, "/releases")

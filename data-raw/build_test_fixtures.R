## Genera fixtures pequeños de Parquet para los tests offline.
## Extrae 100 filas de cada tabla por departamento.
## Requiere: arrow, dplyr
##
## Ejecutar una vez después de tener los parquets completos en el caché.

library(arrow)

fixture_dir <- "tests/testthat/fixtures"
dir.create(fixture_dir, showWarnings = FALSE, recursive = TRUE)

cache_dir <- tools::R_user_dir("censosbo", "cache")

# Tablas simples (un solo parquet)
for (tabla in c("vivienda", "emigracion", "mortalidad")) {
  src <- file.path(cache_dir, paste0(tabla, ".parquet"))
  if (!file.exists(src)) {
    message("No encontrado en caché: ", src, " — saltando")
    next
  }
  ds <- arrow::read_parquet(src)
  fixture <- head(ds, 100)
  out <- file.path(fixture_dir, paste0(tabla, ".parquet"))
  arrow::write_parquet(fixture, out, compression = "snappy")
  message("Generado: ", out, " (", nrow(fixture), " filas)")
}

# Persona: un archivo por departamento
for (dep in sprintf("%02d", 1:9)) {
  src <- file.path(cache_dir, paste0("persona_dep", dep, ".parquet"))
  if (!file.exists(src)) {
    message("No encontrado en caché: ", src, " — saltando")
    next
  }
  ds <- arrow::read_parquet(src)
  fixture <- head(ds, 100)
  out <- file.path(fixture_dir, paste0("persona_dep", dep, ".parquet"))
  arrow::write_parquet(fixture, out, compression = "snappy")
  message("Generado: ", out, " (", nrow(fixture), " filas)")
}

message("\nFixtures en: ", fixture_dir)
message("Tamaño total: ", sum(file.size(list.files(fixture_dir, full.names = TRUE))), " bytes")

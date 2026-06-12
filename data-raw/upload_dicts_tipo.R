## Sube SOLO los diccionario_variables.parquet (ahora con columna `tipo`) a cada
## GitHub Release. No re-sube los parquets de datos (persona/vivienda), que no
## cambiaron en esta actualización.
##
## Requiere autenticación: usa el token del gh CLI si GITHUB_PAT no está seteado.
##   source("data-raw/upload_dicts_tipo.R")

library(piggyback)

if (Sys.getenv("GITHUB_PAT") == "" && Sys.getenv("GITHUB_TOKEN") == "") {
  tok <- tryCatch(system2("gh", c("auth", "token"), stdout = TRUE), error = function(e) "")
  if (length(tok) && nzchar(tok)) Sys.setenv(GITHUB_PAT = tok)
}

REPO <- "lab-tecnosocial/censosbo"

# tag del release  ->  diccionario_variables.parquet local correspondiente
DICTS <- list(
  list(tag = "data-v1.0.0",      path = "original-data/r/cpv-2024/parquets/diccionario_variables.parquet"),
  list(tag = "data-1976-v1.0.0", path = "original-data/r/censos-historicos/censo_1976/diccionario_variables.parquet"),
  list(tag = "data-1992-v1.0.0", path = "original-data/r/censos-historicos/censo_1992/diccionario_variables.parquet"),
  list(tag = "data-2001-v1.0.0", path = "original-data/r/censos-historicos/censo_2001/diccionario_variables.parquet"),
  list(tag = "data-2012-v1.0.0", path = "original-data/r/censos-historicos/censo_2012/diccionario_variables.parquet")
)

for (d in DICTS) {
  stopifnot(file.exists(d$path))
  kb <- round(file.size(d$path) / 1024, 1)
  message("Subiendo diccionario_variables.parquet (", kb, " KB) a ", d$tag, " ...")
  pb_upload(d$path, repo = REPO, tag = d$tag,
            name = "diccionario_variables.parquet", overwrite = TRUE)
  message("  OK")
}

message("\nListo. Verifica en https://github.com/", REPO, "/releases")

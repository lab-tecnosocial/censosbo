## Patch reproducible: añade las variables derivadas (ver derived_codebook_vars.R)
## al data/codebook_meta.rda vigente, SIN necesitar el Excel original del INE.
## Útil cuando el disco con original-data no está montado. Idempotente.

source("data-raw/derived_codebook_vars.R")
load("data/codebook_meta.rda")

codebook_meta <- .add_derived_codebook_vars(codebook_meta)

message("Filas 'area': ", sum(codebook_meta$variable == "area"),
        " (tablas: ",
        paste(codebook_meta$tabla[codebook_meta$variable == "area"], collapse = ", "),
        ")")

usethis::use_data(codebook_meta, overwrite = TRUE)
message("codebook_meta actualizado (", nrow(codebook_meta), " variables).")

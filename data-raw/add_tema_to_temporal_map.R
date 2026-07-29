## Añade la columna `tema` a variable_temporal_map.
##
## Cierra el hueco entre los dos vocabularios temáticos del paquete:
##   - `grupos_variables()` — 6 grupos sobre nombres ARMONIZADOS
##   - `censo_temas()`      — 21 temas sobre variables CRUDAS de cada censo
##
## Con esta columna, cada variable armonizada declara a qué tema pertenece, así
## que se puede pasar de una vista a la otra sin tabla externa. El tema se toma
## del codebook de 2024 (la variable `v2024` de cada fila), que es el vocabulario
## canónico.
##
## Patch idempotente. Ejecutar después de add_taxonomia_to_codebook.R:
##   Rscript data-raw/add_tema_to_temporal_map.R

load("data/variable_temporal_map.rda")
load("data/codebook_meta.rda")

tema_de <- function(v2024, tabla) {
  if (is.na(v2024) || !nzchar(v2024)) return(NA_character_)
  j <- which(tolower(codebook_meta$variable) == tolower(v2024) &
               codebook_meta$tabla == tabla)
  if (length(j) == 0) j <- which(tolower(codebook_meta$variable) == tolower(v2024))
  if (length(j) == 0) return(NA_character_)
  codebook_meta$tema[j[1]]
}

variable_temporal_map$tema <- vapply(
  seq_len(nrow(variable_temporal_map)),
  function(i) tema_de(variable_temporal_map$v2024[i], variable_temporal_map$tabla[i]),
  character(1)
)

# `departamento` es la clave geográfica, no un dato temático: su v2024 apunta a
# una variable de vivienda y el tema que hereda no describe lo que mide.
variable_temporal_map$tema[variable_temporal_map$variable == "departamento"] <-
  "ubicacion_geografica"

sin_tema <- variable_temporal_map$variable[is.na(variable_temporal_map$tema)]
if (length(sin_tema) > 0) {
  stop(sprintf("Variables armonizadas sin tema: %s", paste(sin_tema, collapse = ", ")))
}

usethis::use_data(variable_temporal_map, overwrite = TRUE, compress = "xz")

message(sprintf("variable_temporal_map: %d filas, %d temas distintos",
                nrow(variable_temporal_map), length(unique(variable_temporal_map$tema))))
print(table(variable_temporal_map$tema))

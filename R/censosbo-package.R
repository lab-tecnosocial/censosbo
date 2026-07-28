#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data
#' @importFrom dplyr filter select collect all_of
## usethis namespace: end
#'
# `st_as_sf` no se usa aquí: el importFrom existe para que el namespace de sf se
# CARGUE junto con censosbo. Sin él, `library(censosbo)` no cargaba sf (está en
# Imports del DESCRIPTION pero nada lo importaba en NAMESPACE), así que sus
# métodos S3 no quedaban registrados: `geo_municipios[i, ]` caía en
# `[.data.frame`, que degrada la columna sfc a una lista corriente, y el mapa
# resultante fallaba con "sf_column does not point to a geometry column".
#' @importFrom sf st_as_sf
NULL

# Silenciar notas de R CMD check sobre datos del paquete accedidos por nombre
utils::globalVariables(c("codebook_meta", "geo_bolivia",
                          "codebook_historico_meta", "variable_temporal_map",
                          "geo_departamentos", "geo_municipios"))

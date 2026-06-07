#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data
#' @importFrom dplyr filter select collect all_of
## usethis namespace: end
NULL

# Silenciar notas de R CMD check sobre datos del paquete accedidos por nombre
utils::globalVariables(c("codebook_meta", "geo_bolivia",
                          "codebook_historico_meta", "variable_longitudinal_map",
                          "geo_departamentos", "geo_municipios"))

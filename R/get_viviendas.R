#' Accede a los microdatos de viviendas del CPV-2024
#'
#' Descarga y/o carga desde caché los datos de viviendas del Censo de Población
#' y Vivienda 2024 de Bolivia, con filtros geográficos opcionales.
#'
#' @inheritParams get_personas
#' @param as Formato de retorno: `"arrow"` (por defecto), `"tibble"` o
#'   `"duckdb"` (tabla `"viviendas"`).
#'
#' @return Ver [get_personas()].
#'
#' @details
#' La tabla de viviendas contiene 48 variables para ~4.5 millones de viviendas
#' particulares y colectivas. Se puede unir con [get_personas()] usando la
#' clave `idep + iprov + imun + i00`.
#'
#' @export
#' @examples
#' \dontrun{
#' # Viviendas de Cochabamba
#' get_viviendas(departamento = "Cochabamba")
#'
#' # Condiciones de servicios básicos en Oruro
#' library(dplyr)
#' get_viviendas(departamento = "04", variables = c("urbrur", "v07_aguapro", "v09_energia")) |>
#'   count(urbrur, v07_aguapro) |>
#'   collect()
#' }
get_viviendas <- function(
    departamento = NULL,
    provincia    = NULL,
    municipio    = NULL,
    variables    = NULL,
    as           = c("arrow", "tibble", "duckdb"),
    overwrite    = FALSE,
    verbose      = TRUE
) {
  as <- match.arg(as)
  local_path <- .download_parquet("vivienda.parquet", overwrite = overwrite, verbose = verbose)
  ds <- arrow::open_dataset(local_path, format = "parquet")
  ds <- .apply_geo_filters(ds, departamento, provincia, municipio)
  ds <- .apply_variable_selection(ds, variables)
  .return_as(ds, as, table_name = "viviendas", verbose = verbose)
}

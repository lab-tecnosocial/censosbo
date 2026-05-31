#' Accede a los microdatos de emigración internacional del CPV-2024
#'
#' Descarga y/o carga desde caché los datos de emigración internacional del
#' Censo de Población y Vivienda 2024 de Bolivia.
#'
#' @inheritParams get_personas
#' @param as Formato de retorno: `"arrow"` (por defecto), `"tibble"` o
#'   `"duckdb"` (tabla `"emigracion"`).
#'
#' @return Ver [get_personas()].
#'
#' @details
#' Registra los miembros del hogar que emigraron al exterior en los últimos
#' 5 años. Variables principales: sexo, año de salida, edad al salir y país
#' de destino (`pais_destino_cod`).
#'
#' @export
#' @examples
#' \dontrun{
#' # Emigración por país de destino
#' library(dplyr)
#' get_emigracion() |>
#'   count(pais_destino_cod, sort = TRUE) |>
#'   collect()
#' }
get_emigracion <- function(
    departamento = NULL,
    provincia    = NULL,
    municipio    = NULL,
    variables    = NULL,
    as           = c("arrow", "tibble", "duckdb"),
    overwrite    = FALSE,
    verbose      = TRUE
) {
  as <- match.arg(as)
  local_path <- .download_parquet("emigracion.parquet", overwrite = overwrite, verbose = verbose)
  ds <- arrow::open_dataset(local_path, format = "parquet")
  ds <- .apply_geo_filters(ds, departamento, provincia, municipio)
  ds <- .apply_variable_selection(ds, variables)
  .return_as(ds, as, table_name = "emigracion", verbose = verbose)
}

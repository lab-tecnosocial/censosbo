#' Accede a los microdatos de mortalidad del CPV-2024
#'
#' Descarga y/o carga desde caché los datos de mortalidad del Censo de Población
#' y Vivienda 2024 de Bolivia.
#'
#' @inheritParams get_personas_2024
#' @param as Formato de retorno: `"arrow"` (por defecto), `"tibble"` o
#'   `"duckdb"` (tabla `"mortalidad"`).
#'
#' @return Ver [get_personas_2024()].
#'
#' @details
#' Registra los fallecimientos ocurridos en el hogar durante los últimos
#' 12 meses. Variables principales: mes y año de fallecimiento, edad,
#' causa COVID-19 (`m214_cov`), sexo y si fue parto (`m216_parto`).
#'
#' Para mortalidad del censo 1992 usa [get_mortalidad_1992()] o
#' `get_censo(1992, "mortalidad")`.
#'
#' @export
#' @examples
#' \dontrun{
#' # Fallecimientos por departamento
#' library(dplyr)
#' get_mortalidad_2024() |>
#'   count(idep) |>
#'   collect()
#' }
get_mortalidad_2024 <- function(
    departamento = NULL,
    provincia    = NULL,
    municipio    = NULL,
    variables    = NULL,
    as           = c("arrow", "tibble", "duckdb"),
    overwrite    = FALSE,
    verbose      = TRUE
) {
  as <- match.arg(as)
  local_path <- .download_parquet("mortalidad.parquet", overwrite = overwrite, verbose = verbose)
  ds <- arrow::open_dataset(local_path, format = "parquet")
  ds <- .apply_geo_filters(ds, departamento, provincia, municipio)
  ds <- .apply_variable_selection(ds, variables)
  .return_as(ds, as, table_name = "mortalidad", verbose = verbose)
}


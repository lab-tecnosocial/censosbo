#' Accede a los microdatos de viviendas del CPV-2024
#'
#' Descarga y/o carga desde caché los datos de viviendas del Censo de Población
#' y Vivienda 2024 de Bolivia, con filtros geográficos opcionales.
#'
#' @inheritParams get_personas_2024
#' @param universo Qué registros de la entidad devolver:
#'   - `"viviendas"` (por defecto): el universo oficial del INE, 4.480.201
#'     viviendas. Excluye a las personas censadas en la calle o en tránsito.
#'   - `"particulares"`: solo viviendas particulares (4.463.773).
#'   - `"colectivas"`: solo viviendas colectivas (16.428).
#'   - `"todos"`: los 4.490.488 registros crudos de la entidad de REDATAM,
#'     incluidas las personas en la calle y en tránsito.
#'
#'   Ver [tipos_vivienda()] para el detalle código a código.
#' @param as Formato de retorno: `"arrow"` (por defecto), `"tibble"` o
#'   `"duckdb"` (tabla `"viviendas"`).
#'
#' @return Ver [get_personas_2024()].
#'
#' @details
#' La tabla de viviendas contiene 48 variables. Se puede unir con
#' [get_personas_2024()] usando la clave `idep + iprov + imun + i00`.
#'
#' Para viviendas de censos históricos usa [get_viviendas_1992()],
#' [get_viviendas_2001()], [get_viviendas_2012()] o [get_censo()].
#'
#' @section El universo de vivienda:
#' La entidad `vivienda` de REDATAM tiene 4.490.488 registros, pero **10.287 no
#' son viviendas**: son personas censadas fuera de una vivienda, marcadas en
#' `v01_tipoviv` como *persona que vive en la calle* (código 15, 3.311 registros)
#' o *en tránsito: terminal, aeropuerto, puerto u otro* (código 16, 6.976). El
#' INE no las cuenta como viviendas en ningún tabulado, y descontarlas da
#' exactamente su total oficial de **4.480.201 viviendas** —también por área
#' (2.898.140 urbanas y 1.582.061 rurales) y en los 343 municipios, donde
#' coincide al registro con las viviendas del geoportal ([get_unidades_2024()]).
#'
#' Por eso el defecto es `universo = "viviendas"`. Para contar los registros
#' crudos de la entidad, como los devuelve REDATAM, usa `universo = "todos"`.
#'
#' El filtro necesita la columna `v01_tipoviv`: si pasas `variables` sin
#' incluirla, se añade automáticamente al resultado.
#'
#' @seealso [tipos_vivienda()] para los códigos de cada grupo.
#'
#' @export
#' @examples
#' \dontrun{
#' # Viviendas de Cochabamba (universo oficial)
#' get_viviendas_2024(departamento = "Cochabamba")
#'
#' # Solo viviendas colectivas del país
#' get_viviendas_2024(universo = "colectivas")
#'
#' # La entidad cruda de REDATAM, con calle y tránsito
#' get_viviendas_2024(universo = "todos")
#'
#' # Condiciones de servicios básicos en Oruro
#' library(dplyr)
#' get_viviendas_2024(departamento = "04",
#'                    variables = c("urbrur", "v07_aguapro", "v09_energia")) |>
#'   count(urbrur, v07_aguapro) |>
#'   collect()
#' }
get_viviendas_2024 <- function(
    departamento = NULL,
    provincia    = NULL,
    municipio    = NULL,
    variables    = NULL,
    universo     = c("viviendas", "particulares", "colectivas", "todos"),
    as           = c("arrow", "tibble", "duckdb"),
    overwrite    = FALSE,
    verbose      = TRUE
) {
  as       <- match.arg(as)
  universo <- match.arg(universo)
  local_path <- .download_parquet("vivienda.parquet", overwrite = overwrite, verbose = verbose)
  ds <- arrow::open_dataset(local_path, format = "parquet")
  ds <- .apply_geo_filters(ds, departamento, provincia, municipio)
  # La selección de variables va después del filtro de universo para no tener que
  # conservar `v01_tipoviv` cuando el usuario no la pidió... pero entonces el
  # filtro no vería la columna. Se añade a `variables` y se conserva: es un dato
  # del universo, y ocultarla haría el resultado imposible de auditar.
  variables <- .con_columna_universo(variables, 2024L, universo)
  ds <- .apply_variable_selection(ds, variables, anio = 2024L, verbose = verbose)
  ds <- .filtrar_universo_vivienda(ds, 2024L, universo, verbose = verbose)
  .return_as(ds, as, table_name = "viviendas", verbose = verbose)
}


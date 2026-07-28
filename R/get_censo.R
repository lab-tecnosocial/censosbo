#' Accede a los microdatos de cualquier censo de Bolivia
#'
#' Descarga y/o carga desde caché los microdatos de los censos de población
#' de Bolivia de 1976, 1992, 2001, 2012 y 2024, con filtros geográficos
#' opcionales. Es la API genérica por año; para el CPV-2024 delega en
#' [get_personas_2024()] y sus funciones hermanas.
#'
#' @param anio Entero. Año del censo: `1976`, `1992`, `2001`, `2012` o `2024`.
#' @param tabla Caracteres. Nombre de la tabla a consultar. Depende del año:
#'   - **1976**: `"poblacion"` (o `"persona"` como alias), `"vivienda"`
#'   - **1992**: `"persona"`, `"vivienda"`, `"mortalidad"`
#'   - **2001**: `"persona"`, `"vivienda"`
#'   - **2012**: `"persona"`, `"vivienda"`, `"emigracion"`, `"discapacidad"`
#'   - **2024**: `"persona"`, `"vivienda"`, `"emigracion"`, `"mortalidad"`
#' @param departamento Vector de caracteres. Código(s) `"01"`-`"09"` o nombre(s) del
#'   departamento. Si `NULL`, incluye todos.
#' @param provincia Vector de caracteres. Código(s) o nombre(s) de provincia.
#'   En 1992/2001/2012 acepta nombres (se resuelven contra el catálogo del
#'   CPV-2024). En **1976** solo acepta códigos numéricos (geografía cantonal
#'   distinta). Si `NULL`, incluye todas.
#' @param municipio Vector de caracteres. Código(s) o nombre(s) de municipio.
#'   En 1992/2001/2012 acepta nombres; en **1976** solo códigos de cantón.
#'   Si `NULL`, incluye todos. Si el municipio no existe en el año solicitado,
#'   se emite una advertencia y se retorna `NULL`.
#' @param variables Vector de caracteres. Nombres de columnas a seleccionar.
#'   Si `NULL`, devuelve todas las columnas.
#' @param as Formato de retorno: `"arrow"` (lazy, por defecto), `"tibble"` o
#'   `"duckdb"`.
#' @param overwrite Lógico. Si `TRUE`, re-descarga aunque exista en caché.
#' @param verbose Lógico. Mostrar mensajes de progreso. Por defecto `TRUE`.
#'
#' @return Según `as`:
#'   - `"arrow"`: un `arrow::Dataset` o `arrow::Table` (lazy cuando no hay filtros geo)
#'   - `"tibble"`: un `data.frame` con los datos en RAM
#'   - `"duckdb"`: una conexión `DBI` con la tabla registrada (con el nombre de
#'     `tabla`, p.ej. `"persona"`); cierra con
#'     `DBI::dbDisconnect(con, shutdown = TRUE)`.
#'
#' @details
#' Todas las tablas exponen los códigos geográficos armonizados como columnas
#' directas: `idep`, `iprov` e `imun` (2 dígitos, consistentes con el CPV-2024).
#' Esto permite filtrar por geografía sin reconstruir la jerarquía REDATAM
#' (antes requería un join `persona → vivienda → municipio`). El filtrado se hace
#' directamente sobre estas columnas, igual que en el CPV-2024.
#'
#' El censo 1976 no tuvo municipios comparables (usó cantones), por lo que solo
#' expone `idep` e `iprov`; el filtro de `municipio` se aplica sobre el cantón.
#'
#' Con `anio = 2024` la llamada se redirige a [get_personas_2024()],
#' [get_viviendas_2024()], [get_emigracion_2024()] o [get_mortalidad_2024()]
#' según `tabla`, así que el resultado es idéntico al de esas funciones — incluido
#' el nombre con que se registra la tabla en DuckDB (`"personas"`, `"viviendas"`,
#' en plural, a diferencia de los censos históricos).
#'
#' @section Advertencia sobre municipios:
#' El número de municipios cambió entre censos. Un código de municipio válido en
#' 2012 puede no existir en 1992. En ese caso se emite una advertencia y se retorna
#' `NULL` sin error.
#'
#' @importFrom stats setNames
#' @importFrom DBI dbConnect dbExecute dbGetQuery dbDisconnect
#' @importFrom duckdb duckdb
#' @importFrom dplyr as_tibble
#' @export
#' @examples
#' \dontrun{
#' # Personas de Santa Cruz en el censo 2012
#' get_censo(2012, "persona", departamento = "07")
#'
#' # Viviendas del censo 1992 en La Paz
#' get_censo(1992, "vivienda", departamento = "La Paz")
#'
#' # Todas las personas del censo 1976 (descarga completa ~46 MB)
#' get_censo(1976, "poblacion")
#'
#' # El CPV-2024 también: equivale a get_personas_2024(departamento = "07")
#' get_censo(2024, "persona", departamento = "07")
#'
#' # Consulta SQL sobre censo 2001
#' con <- get_censo(2001, "persona", departamento = "03", as = "duckdb")
#' DBI::dbGetQuery(con, "SELECT P28, COUNT(*) AS n FROM persona GROUP BY P28")
#' DBI::dbDisconnect(con, shutdown = TRUE)
#' }
get_censo <- function(
    anio,
    tabla       = "persona",
    departamento = NULL,
    provincia   = NULL,
    municipio   = NULL,
    variables   = NULL,
    as          = c("arrow", "tibble", "duckdb"),
    overwrite   = FALSE,
    verbose     = TRUE
) {
  as   <- match.arg(as)
  anio <- as.integer(anio)

  # "persona" es alias de "poblacion" en el censo 1976
  if (anio == 1976L && tabla == "persona") {
    cli::cli_inform(c(
      "i" = "El censo 1976 usa {.val poblacion} en lugar de {.val persona}. Redirigiendo."
    ))
    tabla <- "poblacion"
  }

  .validate_censo_args(anio, tabla)

  if (anio == 2024L) {
    # El CPV-2024 no vive en los releases históricos: se delega en las funciones
    # get_*_2024(), que ya conocen su particionado por departamento y el nombre
    # con que registran la tabla en DuckDB.
    .get_censo_2024(tabla, departamento, provincia, municipio,
                    variables, as, overwrite, verbose)
  } else if (anio == 1976L) {
    # 1976 usa geografía cantonal (columna `can`), no comparable con los
    # municipios del CPV-2024: provincia/municipio solo aceptan códigos.
    if (!is.null(provincia) && any(grepl("[^0-9]", as.character(provincia)))) {
      cli::cli_abort("En el censo 1976, {.arg provincia} solo acepta códigos numéricos.")
    }
    if (!is.null(municipio) && any(grepl("[^0-9]", as.character(municipio)))) {
      cli::cli_abort(c(
        "En el censo 1976, {.arg municipio} solo acepta códigos de cantón numéricos.",
        "i" = "El censo 1976 no tiene municipios comparables con el CPV-2024."
      ))
    }
    dep_codes  <- .resolve_dep_codes(departamento)
    prov_codes <- if (!is.null(provincia)) sprintf("%02d", as.integer(provincia)) else NULL
    mun_codes  <- if (!is.null(municipio)) sprintf("%02d", as.integer(municipio)) else NULL
    .get_censo_1976(tabla, dep_codes, prov_codes, mun_codes, variables, as, overwrite, verbose)
  } else {
    # 1992/2001/2012 exponen idep/iprov/imun consistentes con el CPV-2024, así
    # que se reutiliza el mismo resolver (acepta códigos o nombres, valida y
    # filtra por la tupla completa). Un municipio válido en 2024 que no existía
    # en el año pedido simplemente no traerá filas (aviso de resultado vacío).
    geo <- .resolve_geo(departamento, provincia, municipio)
    .get_censo_redatam(anio, tabla, geo, variables, as, overwrite, verbose)
  }
}

# --- 2024: delega en las funciones específicas del CPV-2024 ---

.get_censo_2024 <- function(tabla, departamento, provincia, municipio,
                            variables, as, overwrite, verbose) {
  fn <- switch(
    tabla,
    "persona"    = get_personas_2024,
    "vivienda"   = get_viviendas_2024,
    "emigracion" = get_emigracion_2024,
    "mortalidad" = get_mortalidad_2024
  )
  fn(departamento = departamento, provincia = provincia, municipio = municipio,
     variables = variables, as = as, overwrite = overwrite, verbose = verbose)
}

# --- 1976: columnas geográficas directas, sin REDATAM ---

.get_censo_1976 <- function(tabla, dep_codes, prov_codes, mun_codes,
                             variables, as, overwrite, verbose) {
  filename <- paste0(tabla, ".parquet")
  main_path <- .download_censo(1976L, filename, overwrite, verbose)
  ds <- arrow::open_dataset(main_path)

  # idep/iprov disponibles como columnas string ("01".."09") en poblacion y
  # vivienda. 1976 no tiene municipios comparables: el filtro de municipio usa
  # el cantón (`can`, entero).
  if (!is.null(dep_codes))  ds <- dplyr::filter(ds, .data$idep  %in% dep_codes)
  if (!is.null(prov_codes)) ds <- dplyr::filter(ds, .data$iprov %in% prov_codes)
  if (!is.null(mun_codes))  ds <- dplyr::filter(ds, .data$can %in% as.integer(mun_codes))

  ds <- .apply_variable_selection(ds, variables)

  # Contrato uniforme: si el filtro geográfico no deja filas, avisar y devolver
  # NULL sea cual sea `as` (antes solo se comprobaba con as = "tibble").
  if (!is.null(dep_codes) || !is.null(prov_codes) || !is.null(mun_codes)) {
    if (.ds_is_empty(ds)) {
      .warn_if_empty_geo(0L, 1976L, dep_codes, prov_codes, mun_codes)
      return(NULL)
    }
  }
  .return_as(ds, as, table_name = tabla, verbose = verbose)
}

# --- 1992/2001/2012: idep/iprov/imun denormalizados como columnas directas ---

.get_censo_redatam <- function(anio, tabla, geo, variables, as, overwrite, verbose) {
  filename  <- paste0(tabla, ".parquet")
  main_path <- .download_censo(anio, filename, overwrite, verbose)
  ds <- arrow::open_dataset(main_path)

  # Todas las tablas (persona, vivienda, mortalidad, emigracion, discapacidad)
  # traen idep/iprov/imun pre-unidos. El filtro geográfico es directo sobre esas
  # columnas string (por departamento y, si aplica, por la tupla completa).
  ds <- .apply_geo(ds, geo)

  ds <- .apply_variable_selection(ds, variables)

  # Contrato uniforme de resultado vacío (ver .get_censo_1976).
  if (!is.null(geo$dep_codes) || !is.null(geo$rows)) {
    if (.ds_is_empty(ds)) {
      .warn_if_empty_geo(0L, anio, geo$dep_codes,
                         if (is.null(geo$rows)) NULL else unique(geo$rows$iprov),
                         if (is.null(geo$rows)) NULL else unique(geo$rows$imun))
      return(NULL)
    }
  }
  .return_as(ds, as, table_name = tabla, verbose = verbose)
}

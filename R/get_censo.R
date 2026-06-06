#' Accede a los microdatos de los censos históricos de Bolivia
#'
#' Descarga y/o carga desde caché los microdatos de los censos de población
#' de Bolivia de 1976, 1992, 2001 y 2012, con filtros geográficos opcionales.
#'
#' @param anio Entero. Año del censo: `1976`, `1992`, `2001` o `2012`.
#' @param tabla Caracteres. Nombre de la tabla a consultar. Depende del año:
#'   - **1976**: `"poblacion"` (o `"persona"` como alias), `"vivienda"`
#'   - **1992**: `"persona"`, `"vivienda"`, `"mortalidad"`
#'   - **2001**: `"persona"`, `"vivienda"`, `"comunidades_poblacion"`, `"comunidades_vivienda"`
#'   - **2012**: `"persona"`, `"vivienda"`, `"emigracion"`, `"discapacidad"`
#' @param departamento Vector de caracteres. Código(s) `"01"`-`"09"` o nombre(s) del
#'   departamento. Si `NULL`, incluye todos.
#' @param provincia Vector de caracteres. Código(s) de provincia. Si `NULL`,
#'   incluye todas.
#' @param municipio Vector de caracteres. Código(s) de municipio. Si `NULL`,
#'   incluye todos. Si el municipio no existe en el año solicitado, se emite
#'   una advertencia y se retorna `NULL`.
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
#'   - `"duckdb"`: una conexión `DBI` con la tabla registrada; cierra con
#'     `DBI::dbDisconnect(con)`.
#'
#' @details
#' Los censos 1992, 2001 y 2012 usan la estructura jerárquica de REDATAM
#' (persona → vivienda → municipio → provincia → departamento). Cuando se aplica
#' un filtro geográfico, `get_censo()` resuelve la jerarquía internamente.
#'
#' Con filtro geográfico, el resultado incluye las columnas `idep`, `iprov` e `imun`
#' con los códigos geográficos armonizados (2 dígitos, consistentes con el CPV-2024).
#'
#' El censo 1976 usa columnas geográficas directas (`dep`, `pro`, `can`), no REDATAM.
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
#' # Todas las personas del censo 1976 (descarga completa ~63 MB)
#' get_censo(1976, "poblacion")
#'
#' # Consulta SQL sobre censo 2001
#' con <- get_censo(2001, "persona", departamento = "03", as = "duckdb")
#' DBI::dbGetQuery(con, "SELECT P28, COUNT(*) AS n FROM persona GROUP BY P28")
#' DBI::dbDisconnect(con)
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

  dep_codes  <- .resolve_dep_codes(departamento)
  prov_codes <- if (!is.null(provincia))  sprintf("%02d", as.integer(provincia))  else NULL
  mun_codes  <- if (!is.null(municipio))  sprintf("%02d", as.integer(municipio))  else NULL

  if (anio == 1976L) {
    .get_censo_1976(tabla, dep_codes, prov_codes, mun_codes, variables, as, overwrite, verbose)
  } else {
    .get_censo_redatam(anio, tabla, dep_codes, prov_codes, mun_codes, variables, as, overwrite, verbose)
  }
}

# --- 1976: columnas geográficas directas, sin REDATAM ---

.get_censo_1976 <- function(tabla, dep_codes, prov_codes, mun_codes,
                             variables, as, overwrite, verbose) {
  filename <- paste0(tabla, ".parquet")
  main_path <- .download_censo(1976L, filename, overwrite, verbose)
  ds <- arrow::open_dataset(main_path)

  dep_col <- if (tabla == "poblacion") "dep" else "idep"
  pro_col <- "pro"
  can_col <- "can"

  if (!is.null(dep_codes)) {
    dep_int <- as.integer(dep_codes)
    ds <- dplyr::filter(ds, .data[[dep_col]] %in% dep_int)
  }
  if (!is.null(prov_codes)) {
    ds <- dplyr::filter(ds, .data[[pro_col]] %in% as.integer(prov_codes))
  }
  if (!is.null(mun_codes)) {
    ds <- dplyr::filter(ds, .data[[can_col]] %in% as.integer(mun_codes))
  }

  ds <- .apply_variable_selection(ds, variables)
  result <- .return_as(ds, as, table_name = tabla, verbose = verbose)

  # Comprobar si hay datos (solo para tibble; Arrow no materializa)
  if (is.data.frame(result) && nrow(result) == 0) {
    .warn_if_empty_geo(0L, 1976L, dep_codes, prov_codes, mun_codes)
    return(NULL)
  }
  result
}

# --- 1992/2001/2012: jerarquía REDATAM, join via DuckDB ---

.get_censo_redatam <- function(anio, tabla, dep_codes, prov_codes, mun_codes,
                                variables, as, overwrite, verbose) {
  filename  <- paste0(tabla, ".parquet")
  main_path <- .download_censo(anio, filename, overwrite, verbose)

  needs_geo <- !is.null(dep_codes) || !is.null(prov_codes) || !is.null(mun_codes)
  # Forzar join si se piden columnas geo (idep/iprov/imun) que solo existen via REDCODEN
  needs_join <- needs_geo || (!is.null(variables) && any(c("idep", "iprov", "imun") %in% variables))

  # Sin necesidad de join y no se pide duckdb: retorna Arrow Dataset directamente
  if (!needs_join && as != "duckdb") {
    ds <- arrow::open_dataset(main_path)
    ds <- .apply_variable_selection(ds, variables)
    return(.return_as(ds, as, table_name = tabla, verbose = verbose))
  }

  # Descargar tablas geográficas auxiliares para el join REDATAM
  geo_files <- c("depto.parquet", "provin.parquet", "munic.parquet")
  geo_paths <- stats::setNames(
    vapply(geo_files, function(f) {
      .download_censo(anio, f, overwrite = FALSE, verbose = FALSE)
    }, character(1)),
    c("depto", "provin", "munic")
  )

  # Para tablas con VIVIENDA_REF_ID, descargar vivienda para el join
  tablas_persona <- .CENSO_TABLAS_PERSONA[[as.character(anio)]]
  is_persona_table <- tabla %in% tablas_persona
  viv_path <- if (is_persona_table || tabla == "vivienda") {
    .download_censo(anio, "vivienda.parquet", overwrite = FALSE, verbose = FALSE)
  } else NULL

  # Construir conexión DuckDB para el join
  con <- DBI::dbConnect(duckdb::duckdb(), ":memory:")

  # Registrar todas las vistas
  .duckdb_view(con, "main_tbl", main_path)
  .duckdb_view(con, "depto",    geo_paths[["depto"]])
  .duckdb_view(con, "provin",   geo_paths[["provin"]])
  .duckdb_view(con, "munic",    geo_paths[["munic"]])
  if (!is.null(viv_path)) .duckdb_view(con, "vivienda", viv_path)

  # Columnas geo armonizadas calculadas desde REDCODEN de munic (5 dígitos)
  # DuckDB usa // para división entera; % para módulo
  geo_select <- paste(
    "PRINTF('%02d', CAST(m.REDCODEN AS INTEGER) // 10000) AS idep",
    "PRINTF('%02d', (CAST(m.REDCODEN AS INTEGER) % 10000) // 100) AS iprov",
    "PRINTF('%02d', CAST(m.REDCODEN AS INTEGER) % 100) AS imun",
    sep = ", "
  )

  # Cláusula WHERE usando REDCODEN
  where_clause <- .build_geo_where(dep_codes, prov_codes, mun_codes)

  # JOIN según tipo de tabla
  if (tabla == "vivienda") {
    join_clause <- "JOIN munic m ON main_tbl.MUNIC_REF_ID = m.MUNIC_REF_ID"
  } else if (is_persona_table) {
    join_clause <- paste(
      "JOIN vivienda v ON main_tbl.VIVIENDA_REF_ID = v.VIVIENDA_REF_ID",
      "JOIN munic m ON v.MUNIC_REF_ID = m.MUNIC_REF_ID"
    )
  } else {
    join_clause <- ""
    geo_select  <- ""
    where_clause <- ""
  }

  select_part <- if (nchar(geo_select) > 0) {
    paste("main_tbl.*,", geo_select)
  } else {
    "main_tbl.*"
  }

  sql_view <- sprintf(
    "SELECT %s FROM main_tbl %s %s",
    select_part, join_clause, where_clause
  )

  if (as == "duckdb") {
    DBI::dbExecute(con, sprintf("CREATE VIEW %s AS %s", tabla, sql_view))
    return(con)
  }

  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  if (verbose) cli::cli_inform("Ejecutando consulta...")
  result <- DBI::dbGetQuery(con, sql_view)

  .warn_if_empty_geo(nrow(result), anio, dep_codes, prov_codes, mun_codes)
  if (nrow(result) == 0) return(NULL)

  # Aplicar selección de variables
  if (!is.null(variables)) {
    geo_always <- c("idep", "iprov", "imun")
    keep <- unique(c(intersect(geo_always, names(result)), variables))
    missing_cols <- setdiff(variables, names(result))
    if (length(missing_cols) > 0) {
      cli::cli_warn(c(
        "Columnas no encontradas: {.val {missing_cols}}",
        "i" = "Usa {.code codebook(anio = {anio})} para ver las variables disponibles."
      ))
    }
    result <- result[, intersect(keep, names(result)), drop = FALSE]
  }

  switch(as,
    "tibble" = dplyr::as_tibble(result),
    "arrow"  = arrow::as_arrow_table(result)
  )
}

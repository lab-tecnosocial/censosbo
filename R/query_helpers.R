# Aplica filtros geográficos a un Arrow Dataset usando dplyr (que Arrow soporta)
.apply_geo_filters <- function(ds, departamento, provincia, municipio) {
  dep_codes <- .resolve_dep_codes(departamento)
  if (!is.null(dep_codes)) {
    ds <- dplyr::filter(ds, .data$idep %in% dep_codes)
  }
  if (!is.null(provincia)) {
    ds <- dplyr::filter(ds, .data$iprov %in% as.character(provincia))
  }
  if (!is.null(municipio)) {
    ds <- dplyr::filter(ds, .data$imun %in% as.character(municipio))
  }
  ds
}

# Selecciona variables preservando siempre las columnas geográficas
.apply_variable_selection <- function(ds, variables) {
  if (is.null(variables)) return(ds)
  geo_always <- c("idep", "iprov", "imun", "i00")
  cols <- unique(c(geo_always, variables))
  available <- names(ds)
  missing_cols <- setdiff(cols, available)
  if (length(missing_cols) > 0) {
    cli::cli_warn(c(
      "Columnas no encontradas: {.val {missing_cols}}",
      "i" = "Usa {.code codebook()} para ver las variables disponibles."
    ))
    cols <- intersect(cols, available)
  }
  dplyr::select(ds, dplyr::all_of(cols))
}

# Retorna el dataset en el formato solicitado
.return_as <- function(ds, as, table_name = "datos", verbose = TRUE) {
  switch(as,
    "arrow" = ds,
    "tibble" = {
      if (verbose) cli::cli_inform("Cargando datos a memoria RAM...")
      dplyr::collect(ds)
    },
    "duckdb" = {
      con <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
      duckdb::duckdb_register_arrow(con, table_name, ds)
      con
    }
  )
}

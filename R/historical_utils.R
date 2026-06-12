.CENSOS_HISTORICOS <- c(1976L, 1992L, 2001L, 2012L)

.CENSO_TABLAS <- list(
  "1976" = c("poblacion", "vivienda"),
  "1992" = c("persona", "vivienda", "mortalidad"),
  "2001" = c("persona", "vivienda"),
  "2012" = c("persona", "vivienda", "emigracion", "discapacidad")
)

# Tablas de personas (necesitan join via VIVIENDA_REF_ID en REDATAM)
.CENSO_TABLAS_PERSONA <- list(
  "1992" = c("persona", "mortalidad"),
  "2001" = c("persona"),
  "2012" = c("persona", "emigracion", "discapacidad")
)

# Tamaños estimados en MB para mensajes de progreso
.CENSO_SIZE_MB <- list(
  "1976" = list(poblacion = 64, vivienda = 8),
  "1992" = list(persona = 135, vivienda = 30, mortalidad = 17,
                depto = 1, provin = 1, munic = 1),
  "2001" = list(persona = 137, vivienda = 20,
                depto = 1, provin = 1, munic = 1),
  "2012" = list(persona = 147, vivienda = 39, emigracion = 6, discapacidad = 4,
                depto = 1, provin = 1, munic = 1)
)

.validate_censo_args <- function(anio, tabla) {
  if (!anio %in% .CENSOS_HISTORICOS) {
    disponibles <- .CENSOS_HISTORICOS
    cli::cli_abort(c(
      "Año de censo no válido: {.val {anio}}.",
      "i" = "Los censos históricos disponibles son: {.val {disponibles}}.",
      "i" = "Para el CPV-2024 usa {.fn get_personas_2024} o {.fn get_viviendas_2024}."
    ))
  }
  validas <- .CENSO_TABLAS[[as.character(anio)]]
  if (!tabla %in% validas) {
    cli::cli_abort(c(
      "Tabla {.val {tabla}} no disponible para el censo {anio}.",
      "i" = "Las tablas disponibles son: {.val {validas}}."
    ))
  }
}

# Construye el geo lookup MUNIC_REF_ID → (idep, iprov, imun) desde munic.parquet
# El REDCODEN en munic es de 5 dígitos: dep(1) + prov(2) + mun(2)
# Ej: "10101" = dep=1, prov=01, mun=01 → idep="01", iprov="01", imun="01"
.build_geo_lookup <- function(munic_path) {
  munic_df  <- arrow::read_parquet(munic_path)
  redcoden  <- as.integer(munic_df$REDCODEN)
  data.frame(
    MUNIC_REF_ID = munic_df$MUNIC_REF_ID,
    idep  = sprintf("%02d", redcoden %/% 10000L),
    iprov = sprintf("%02d", (redcoden %% 10000L) %/% 100L),
    imun  = sprintf("%02d", redcoden %% 100L),
    stringsAsFactors = FALSE
  )
}

# Registra un archivo Parquet como vista en una conexión DuckDB
.duckdb_view <- function(con, name, path) {
  DBI::dbExecute(con, sprintf(
    "CREATE OR REPLACE VIEW %s AS SELECT * FROM read_parquet('%s')",
    name, path
  ))
}

# Construye cláusula WHERE basada en REDCODEN del munic (5 dígitos)
# dep_codes, prov_codes, mun_codes son vectores de strings de 2 dígitos ("01"-"09")
# DuckDB usa // para división entera (/ devuelve float)
.build_geo_where <- function(dep_codes, prov_codes, mun_codes) {
  parts <- character(0)
  if (!is.null(dep_codes)) {
    dep_int <- paste(as.integer(dep_codes), collapse = ", ")
    parts <- c(parts, sprintf("(CAST(m.REDCODEN AS INTEGER) // 10000) IN (%s)", dep_int))
  }
  if (!is.null(prov_codes)) {
    prov_int <- paste(as.integer(prov_codes), collapse = ", ")
    parts <- c(parts, sprintf("((CAST(m.REDCODEN AS INTEGER) %% 10000) // 100) IN (%s)", prov_int))
  }
  if (!is.null(mun_codes)) {
    mun_int <- paste(as.integer(mun_codes), collapse = ", ")
    parts <- c(parts, sprintf("(CAST(m.REDCODEN AS INTEGER) %% 100) IN (%s)", mun_int))
  }
  if (length(parts) == 0) "" else paste("WHERE", paste(parts, collapse = " AND "))
}

# Verifica si el filtro geográfico resultó en datos y advierte si no
.warn_if_empty_geo <- function(nrow_result, anio, dep_codes, prov_codes, mun_codes) {
  if (nrow_result == 0) {
    cli::cli_warn(c(
      "!" = "No se encontraron datos para los filtros geográficos en el censo {anio}.",
      "i" = "Los códigos de provincia o municipio pueden no existir en ese año.",
      "i" = "El número de municipios cambió entre censos: 1976 (cantones), 1992 (339), 2001 (343), 2012 (339)."
    ))
  }
}

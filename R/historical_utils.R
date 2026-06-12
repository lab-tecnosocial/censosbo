.CENSOS_HISTORICOS <- c(1976L, 1992L, 2001L, 2012L)

.CENSO_TABLAS <- list(
  "1976" = c("poblacion", "vivienda"),
  "1992" = c("persona", "vivienda", "mortalidad"),
  "2001" = c("persona", "vivienda"),
  "2012" = c("persona", "vivienda", "emigracion", "discapacidad")
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

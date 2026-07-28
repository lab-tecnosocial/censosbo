.CENSOS_HISTORICOS <- c(1976L, 1992L, 2001L, 2012L)

# Todos los censos que acepta get_censo(). El CPV-2024 se sirve delegando a las
# funciones get_*_2024() (ver .get_censo_2024), no desde los releases históricos.
.CENSOS_DISPONIBLES <- c(.CENSOS_HISTORICOS, 2024L)

.CENSO_TABLAS <- list(
  "1976" = c("poblacion", "vivienda"),
  "1992" = c("persona", "vivienda", "mortalidad"),
  "2001" = c("persona", "vivienda"),
  "2012" = c("persona", "vivienda", "emigracion", "discapacidad"),
  "2024" = c("persona", "vivienda", "emigracion", "mortalidad")
)

# Tamaños en MiB para los mensajes de progreso, medidos sobre los archivos
# publicados en los releases data-<anio>-v1.0.0.
.CENSO_SIZE_MB <- list(
  "1976" = list(poblacion = 46, vivienda = 5),
  "1992" = list(persona = 99, vivienda = 21, mortalidad = 11,
                depto = 1, provin = 1, munic = 1),
  "2001" = list(persona = 135, vivienda = 21,
                depto = 1, provin = 1, munic = 1),
  "2012" = list(persona = 120, vivienda = 26, emigracion = 4, discapacidad = 3,
                depto = 1, provin = 1, munic = 1)
)

.validate_censo_args <- function(anio, tabla) {
  if (!anio %in% .CENSOS_DISPONIBLES) {
    disponibles <- .CENSOS_DISPONIBLES
    cli::cli_abort(c(
      "Año de censo no válido: {.val {anio}}.",
      "i" = "Los censos disponibles son: {.val {disponibles}}."
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
      "i" = "El número de municipios cambió entre censos: 1976 (cantones), 1992 (339), 2001 (343), 2012 (339), 2024 (343)."
    ))
  }
}

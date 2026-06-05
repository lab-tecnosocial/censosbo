# Atajos por año: wrappers de get_censo() que permiten acceder a cada tabla
# de cada censo con una función corta y predecible.
# Las funciones _2024 están definidas en sus propios archivos (get_personas.R, etc.)

# ─── Censo 1976 ─────────────────────────────────────────────────────────────

#' @rdname get_censo
#' @export
get_poblacion_1976 <- function(departamento = NULL, provincia = NULL,
                                municipio = NULL, variables = NULL,
                                as = c("arrow", "tibble", "duckdb"),
                                overwrite = FALSE, verbose = TRUE) {
  get_censo(1976L, "poblacion", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

#' @rdname get_censo
#' @export
get_viviendas_1976 <- function(departamento = NULL, provincia = NULL,
                                municipio = NULL, variables = NULL,
                                as = c("arrow", "tibble", "duckdb"),
                                overwrite = FALSE, verbose = TRUE) {
  get_censo(1976L, "vivienda", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

# ─── Censo 1992 ─────────────────────────────────────────────────────────────

#' @rdname get_censo
#' @export
get_personas_1992 <- function(departamento = NULL, provincia = NULL,
                               municipio = NULL, variables = NULL,
                               as = c("arrow", "tibble", "duckdb"),
                               overwrite = FALSE, verbose = TRUE) {
  get_censo(1992L, "persona", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

#' @rdname get_censo
#' @export
get_viviendas_1992 <- function(departamento = NULL, provincia = NULL,
                                municipio = NULL, variables = NULL,
                                as = c("arrow", "tibble", "duckdb"),
                                overwrite = FALSE, verbose = TRUE) {
  get_censo(1992L, "vivienda", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

#' @rdname get_censo
#' @export
get_mortalidad_1992 <- function(departamento = NULL, provincia = NULL,
                                 municipio = NULL, variables = NULL,
                                 as = c("arrow", "tibble", "duckdb"),
                                 overwrite = FALSE, verbose = TRUE) {
  get_censo(1992L, "mortalidad", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

# ─── Censo 2001 ─────────────────────────────────────────────────────────────

#' @rdname get_censo
#' @export
get_personas_2001 <- function(departamento = NULL, provincia = NULL,
                               municipio = NULL, variables = NULL,
                               as = c("arrow", "tibble", "duckdb"),
                               overwrite = FALSE, verbose = TRUE) {
  get_censo(2001L, "persona", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

#' @rdname get_censo
#' @export
get_viviendas_2001 <- function(departamento = NULL, provincia = NULL,
                                municipio = NULL, variables = NULL,
                                as = c("arrow", "tibble", "duckdb"),
                                overwrite = FALSE, verbose = TRUE) {
  get_censo(2001L, "vivienda", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

# ─── Censo 2012 ─────────────────────────────────────────────────────────────

#' @rdname get_censo
#' @export
get_personas_2012 <- function(departamento = NULL, provincia = NULL,
                               municipio = NULL, variables = NULL,
                               as = c("arrow", "tibble", "duckdb"),
                               overwrite = FALSE, verbose = TRUE) {
  get_censo(2012L, "persona", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

#' @rdname get_censo
#' @export
get_viviendas_2012 <- function(departamento = NULL, provincia = NULL,
                                municipio = NULL, variables = NULL,
                                as = c("arrow", "tibble", "duckdb"),
                                overwrite = FALSE, verbose = TRUE) {
  get_censo(2012L, "vivienda", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

#' @rdname get_censo
#' @export
get_emigracion_2012 <- function(departamento = NULL, provincia = NULL,
                                 municipio = NULL, variables = NULL,
                                 as = c("arrow", "tibble", "duckdb"),
                                 overwrite = FALSE, verbose = TRUE) {
  get_censo(2012L, "emigracion", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

#' @rdname get_censo
#' @export
get_discapacidad_2012 <- function(departamento = NULL, provincia = NULL,
                                   municipio = NULL, variables = NULL,
                                   as = c("arrow", "tibble", "duckdb"),
                                   overwrite = FALSE, verbose = TRUE) {
  get_censo(2012L, "discapacidad", departamento = departamento, provincia = provincia,
            municipio = municipio, variables = variables,
            as = match.arg(as), overwrite = overwrite, verbose = verbose)
}

# ─── Codebooks por año ───────────────────────────────────────────────────────

#' @rdname codebook
#' @export
codebook_1976 <- function(variable = NULL, tabla = NULL, buscar = NULL) {
  codebook(variable = variable, tabla = tabla, buscar = buscar, anio = 1976L)
}

#' @rdname codebook
#' @export
codebook_1992 <- function(variable = NULL, tabla = NULL, buscar = NULL) {
  codebook(variable = variable, tabla = tabla, buscar = buscar, anio = 1992L)
}

#' @rdname codebook
#' @export
codebook_2001 <- function(variable = NULL, tabla = NULL, buscar = NULL) {
  codebook(variable = variable, tabla = tabla, buscar = buscar, anio = 2001L)
}

#' @rdname codebook
#' @export
codebook_2012 <- function(variable = NULL, tabla = NULL, buscar = NULL) {
  codebook(variable = variable, tabla = tabla, buscar = buscar, anio = 2012L)
}

#' @rdname codebook
#' @export
codebook_2024 <- function(variable = NULL, tabla = NULL, buscar = NULL) {
  codebook(variable = variable, tabla = tabla, buscar = buscar, anio = 2024L)
}

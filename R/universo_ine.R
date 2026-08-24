#' Aplica el universo de los tabulados oficiales del INE
#'
#' Recorta una tabla de personas al universo que el INE usa en sus cuadros
#' publicados: solo residentes habituales en el país y, si se indica, a partir
#' de una edad mínima. Sin este recorte, un conteo hecho sobre los microdatos
#' no cuadra con el tabulado equivalente del INE aunque el cálculo sea
#' correcto.
#'
#' @param datos Tabla de personas: `arrow::Dataset`, `tbl` o `data.frame`,
#'   tal como la devuelven [get_personas_2024()], [get_personas_2012()] o
#'   [get_personas_2001()]. Debe conservar las columnas de residencia habitual
#'   y de edad del censo correspondiente (ver *Details*).
#' @param anio Año del censo: `2001`, `2012` o `2024`.
#' @param edad_min Entero o `NULL`. Edad mínima del universo, en años
#'   cumplidos. `NULL` (por defecto) no filtra por edad. Los cuadros del INE
#'   usan 4 para idioma materno, 6 para idioma de mayor uso e idiomas
#'   hablados, 5 para discapacidad y 14 para condición de actividad; el valor
#'   exacto viene en el título de cada cuadro.
#'
#' @return La misma tabla, filtrada. El tipo de objeto se conserva: un
#'   `Dataset` de Arrow sigue siendo perezoso y no se trae a RAM.
#'
#' @details
#' Los cuadros temáticos del INE llevan al pie la nota *«No incluye personas
#' que residen habitualmente en el exterior»*. Esa exclusión no está en
#' ninguna variable derivada: hay que aplicarla a mano sobre la pregunta de
#' residencia habitual, que cambia de nombre en cada censo.
#'
#' | Censo | Residencia habitual | Edad | Se excluye |
#' |---|---|---|---|
#' | 2024 | `p36_lugres` | `p26_edad` | `3` (otro país) y `9` (sin especificar) |
#' | 2012 | `P33A` | `P25` | `3` (en el exterior) |
#' | 2001 | `P33A` | `P29` | `3` (en el exterior) |
#'
#' En 2024 la categoría «sin especificar» también queda fuera; en 2012 y 2001
#' esa categoría no existe. Para 1976 y 1992 la función aborta: los tabulados
#' de esos censos no llevan la nota y la equivalencia no está verificada.
#'
#' Comprobado contra los cuadros municipales del CPV-2024 de idioma materno,
#' idioma de mayor uso, idiomas hablados y multilingüismo: con este recorte
#' los conteos por municipio, área y lengua coinciden **exactamente** con los
#' publicados por el INE.
#'
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#'
#' # Idioma materno, universo del INE (4 años o más, residentes en el país)
#' get_personas_2024(departamento = "Chuquisaca",
#'                   variables = c("p26_edad", "p36_lugres", "idioma_mat")) |>
#'   universo_ine(2024, edad_min = 4) |>
#'   count(idioma_mat) |>
#'   collect()
#'
#' # Idiomas hablados: el universo es 6 años o más
#' get_personas_2024(departamento = "Chuquisaca",
#'                   variables = c("p26_edad", "p36_lugres",
#'                                 "p331_idiohab1_cod")) |>
#'   universo_ine(2024, edad_min = 6)
#' }
universo_ine <- function(datos, anio, edad_min = NULL) {
  anio <- .validar_anio_universo(anio)
  reglas <- .UNIVERSO_INE[[as.character(anio)]]

  faltan <- setdiff(
    c(reglas$residencia, if (!is.null(edad_min)) reglas$edad),
    .columnas(datos)
  )
  if (length(faltan)) {
    receta <- paste0(
      "get_personas_", anio, "(variables = c(",
      paste0('"', faltan, '"', collapse = ", "), ", ...))"
    )
    cli::cli_abort(c(
      "No se puede aplicar el universo del INE: faltan columnas.",
      "x" = "No {?est\u00e1/est\u00e1n} en los datos: {.var {faltan}}.",  # está/están
      "i" = "{cli::qty(faltan)}P\u00eddela{?s} al leer los datos: {.code {receta}}."  # Pídela
    ))
  }

  residencia <- reglas$residencia
  datos <- dplyr::filter(
    datos,
    !is.na(.data[[residencia]]),
    !as.integer(.data[[residencia]]) %in% reglas$excluir
  )

  if (!is.null(edad_min)) {
    edad_min <- .validar_edad_minima(edad_min)
    edad <- reglas$edad
    datos <- dplyr::filter(datos, as.integer(.data[[edad]]) >= edad_min)
  }

  datos
}

# Los nombres de columna de un `arrow_dplyr_query` no salen por `colnames()`
# —devuelve un vector vacío, no un error— sino por `names()`. Un `data.frame`
# responde igual a las dos, así que preguntar por `names()` primero cubre los
# dos casos sin ramificar por clase.
.columnas <- function(datos) {
  cols <- names(datos)
  if (length(cols)) cols else colnames(datos)
}

# Nombres de la pregunta de residencia habitual y de la edad, y códigos que el
# INE deja fuera de sus cuadros, censo por censo.
.UNIVERSO_INE <- list(
  "2024" = list(residencia = "p36_lugres", edad = "p26_edad", excluir = c(3L, 9L)),
  "2012" = list(residencia = "P33A",       edad = "P25",      excluir = 3L),
  "2001" = list(residencia = "P33A",       edad = "P29",      excluir = 3L)
)

.validar_anio_universo <- function(anio) {
  anio <- suppressWarnings(as.integer(anio))
  if (is.na(anio) || !as.character(anio) %in% names(.UNIVERSO_INE)) {
    disponibles <- names(.UNIVERSO_INE)
    cli::cli_abort(c(
      "{.arg anio} debe ser uno de {.val {disponibles}}.",
      "x" = "Recibido: {.val {anio}}.",
      "i" = "Para 1976 y 1992 los cuadros del INE no declaran esta
             exclusi\u00f3n y la equivalencia no est\u00e1 verificada."
    ))
  }
  anio
}

.validar_edad_minima <- function(edad_min) {
  edad_min <- suppressWarnings(as.integer(edad_min))
  if (is.na(edad_min) || edad_min < 0L) {
    cli::cli_abort("{.arg edad_min} debe ser un entero no negativo o {.code NULL}.")
  }
  edad_min
}

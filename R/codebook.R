#' Diccionario de variables del CPV-2024
#'
#' Metadatos de todas las variables del Censo de Población y Vivienda 2024
#' de Bolivia, extraídos del Diccionario de Variables oficial del INE.
#'
#' @format Un data.frame con las siguientes columnas:
#' \describe{
#'   \item{variable}{Nombre de la variable (minúsculas, igual que en los datos)}
#'   \item{etiqueta}{Descripción en español de la variable}
#'   \item{tabla}{Tabla a la que pertenece: `"persona"`, `"vivienda"`,
#'     `"emigracion"` o `"mortalidad"`}
#'   \item{tipo}{Tipo de dato: `"categorica"`, `"numerica"` o `"texto"`.
#'     Una variable es `"categorica"` si sus valores son códigos con etiquetas
#'     (aunque sean números, como `sexo` 1/2) o si su nombre indica un código de
#'     clasificación (sufijo `cod`: códigos geográficos, de ocupación, etc.);
#'     `"texto"` si almacena texto libre; `"numerica"` en los demás casos
#'     (conteos y medidas)}
#'   \item{valores_codigos}{Lista de data.frames con los códigos y etiquetas
#'     para variables categóricas; `NULL` para variables numéricas o de texto}
#' }
#' @source INE Bolivia, CPV-2024. Diccionario de Variables CPV 2024.xlsx.
"codebook_meta"

#' Diccionarios de variables de los censos históricos de Bolivia
#'
#' Lista nombrada con los metadatos de variables de los censos 1976, 1992,
#' 2001 y 2012. Cada elemento es un data.frame con la misma estructura que
#' [codebook_meta].
#'
#' @format Una lista con elementos `"1976"`, `"1992"`, `"2001"` y `"2012"`,
#'   cada uno un data.frame con columnas:
#' \describe{
#'   \item{variable}{Nombre original de la variable en el censo}
#'   \item{etiqueta}{Descripción de la variable}
#'   \item{tabla}{Tabla/entidad REDATAM de origen}
#'   \item{tipo}{`"categorica"`, `"numerica"` o `"texto"` (misma regla que en
#'     [codebook_meta]: códigos con etiquetas o con nombre tipo `cod` son
#'     categóricos aunque sus valores sean números)}
#'   \item{valores_codigos}{Lista de data.frames con códigos y etiquetas}
#' }
#' @source INE Bolivia. Diccionarios Parquet generados por open-redatam.
"codebook_historico_meta"

#' Consulta el diccionario de variables de un censo de Bolivia
#'
#' Permite buscar variables del censo por nombre, tabla o texto libre en
#' las etiquetas.
#'
#' @param variable Vector de caracteres. Nombre(s) de variable a consultar.
#'   Si `NULL`, devuelve todas.
#' @param tabla Caracteres. Filtra por tabla (e.g., `"persona"`, `"vivienda"`).
#'   Si `NULL`, devuelve todas las tablas.
#' @param buscar Caracteres. Texto libre para buscar en las etiquetas y nombres
#'   de variables (no distingue mayúsculas/minúsculas).
#' @param anio Entero. Año del censo: `2024` (defecto), `1976`, `1992`, `2001`
#'   o `2012`.
#'
#' @return Un data.frame con las variables que coinciden con los filtros.
#'
#' @export
#' @examples
#' # Ver etiqueta de una variable específica del CPV-2024
#' codebook("p25_sexo")
#'
#' # Variables de sexo en el censo 2012
#' codebook(buscar = "sexo", anio = 2012)
#'
#' # Todas las variables de vivienda del censo 1992
#' codebook(tabla = "vivienda", anio = 1992)
codebook <- function(variable = NULL, tabla = NULL, buscar = NULL, anio = 2024) {
  anio <- as.integer(anio)
  meta <- if (anio == 2024L) {
    codebook_meta
  } else {
    if (!exists("codebook_historico_meta")) {
      cli::cli_abort(c(
        "Los diccionarios históricos no están cargados.",
        "i" = "Asegúrate de tener instalada la versión más reciente del paquete."
      ))
    }
    key <- as.character(anio)
    if (is.null(codebook_historico_meta[[key]])) {
      cli::cli_abort("No hay diccionario disponible para el censo {anio}.")
    }
    codebook_historico_meta[[key]]
  }

  if (!is.null(tabla)) {
    tablas_validas <- unique(meta$tabla)
    desconocidas <- setdiff(tolower(tabla), tolower(tablas_validas))
    if (length(desconocidas) > 0) {
      cli::cli_abort(c(
        "Tabla no reconocida en el censo {anio}: {.val {desconocidas}}",
        "i" = "Tablas disponibles: {.val {tablas_validas}}."
      ))
    }
    meta <- meta[tolower(meta$tabla) %in% tolower(tabla), ]
  }
  if (!is.null(variable)) {
    meta <- meta[tolower(meta$variable) %in% tolower(variable), ]
  }
  if (!is.null(buscar)) {
    mask <- grepl(buscar, meta$etiqueta, ignore.case = TRUE) |
      grepl(buscar, meta$variable, ignore.case = TRUE)
    meta <- meta[mask, ]
  }

  if (nrow(meta) == 0) {
    cli::cli_inform("No se encontraron variables con esos criterios en el censo {anio}.")
  }

  # Bug 4: ordenar para que "persona" preceda a "vivienda" y otras tablas auxiliares,
  # evitando que el usuario use por error variables de vivienda en datos de personas
  tabla_orden <- c(
    "persona", "vivienda", "emigracion", "mortalidad", "discapacidad",
    "depto", "provin", "munic"
  )
  rango <- match(meta$tabla, tabla_orden)
  rango[is.na(rango)] <- length(tabla_orden) + 1L
  meta <- meta[order(rango), ]
  rownames(meta) <- NULL

  meta
}

#' Muestra los valores codificados de una variable categórica
#'
#' @param variable Caracteres. Nombre de la variable (e.g., `"p25_sexo"`, `"P23"`).
#' @param anio Entero. Año del censo: `2024` (defecto), `1976`, `1992`, `2001`
#'   o `2012`.
#' @return Un data.frame con columnas `codigo` y `etiqueta`, o un mensaje
#'   si la variable no tiene categorías.
#' @export
#' @examples
#' \dontrun{
#' codebook_valores("p25_sexo")
#' codebook_valores("P23", anio = 2012)
#' }
codebook_valores <- function(variable, anio = 2024) {
  meta <- codebook(variable = variable, anio = anio)
  if (nrow(meta) == 0) {
    cli::cli_abort("Variable {.var {variable}} no encontrada en el diccionario del censo {anio}.")
  }
  if (nrow(meta) > 1) {
    tabla_usada <- meta$tabla[1]
    cli::cli_inform(c(
      "i" = "{.var {variable}} existe en varias tablas ({.val {meta$tabla}}); se muestran los valores de {.val {tabla_usada}}.",
      " " = "Para otra tabla usa {.code codebook_valores()} sobre el resultado de {.code codebook(variable, tabla = ...)}."
    ))
  }
  vals <- meta$valores_codigos[[1]]
  if (is.null(vals) || nrow(vals) == 0) {
    cli::cli_inform(
      "La variable {.var {variable}} ({meta$etiqueta[1]}) es {meta$tipo[1]}, sin categorías."
    )
    return(invisible(NULL))
  }
  vals
}

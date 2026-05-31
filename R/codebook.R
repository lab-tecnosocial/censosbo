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
#'   \item{tipo}{Tipo de dato: `"numerica"`, `"categorica"` o `"texto"`}
#'   \item{valores_codigos}{Lista de data.frames con los códigos y etiquetas
#'     para variables categóricas; `NULL` para variables numéricas}
#' }
#' @source INE Bolivia, CPV-2024. Diccionario de Variables CPV 2024.xlsx.
"codebook_meta"

#' Consulta el diccionario de variables del CPV-2024
#'
#' Permite buscar variables del censo por nombre, tabla o texto libre en
#' las etiquetas.
#'
#' @param variable Vector de caracteres. Nombre(s) de variable a consultar.
#'   Si `NULL`, devuelve todas.
#' @param tabla Caracteres. Filtra por tabla: `"persona"`, `"vivienda"`,
#'   `"emigracion"` o `"mortalidad"`. Si `NULL`, devuelve todas las tablas.
#' @param buscar Caracteres. Texto libre para buscar en las etiquetas y nombres
#'   de variables (no distingue mayúsculas/minúsculas).
#'
#' @return Un data.frame con las variables que coinciden con los filtros.
#'
#' @export
#' @examples
#' # Ver etiqueta de una variable específica
#' codebook("p25_sexo")
#'
#' # Variables de educación
#' codebook(buscar = "educaci")
#'
#' # Todas las variables de vivienda
#' codebook(tabla = "vivienda")
#'
#' # Búsqueda combinada
#' codebook(tabla = "persona", buscar = "idioma")
codebook <- function(variable = NULL, tabla = NULL, buscar = NULL) {
  meta <- codebook_meta

  if (!is.null(tabla)) {
    meta <- meta[meta$tabla %in% tolower(tabla), ]
  }
  if (!is.null(variable)) {
    meta <- meta[meta$variable %in% tolower(variable), ]
  }
  if (!is.null(buscar)) {
    mask <- grepl(buscar, meta$etiqueta, ignore.case = TRUE) |
      grepl(buscar, meta$variable, ignore.case = TRUE)
    meta <- meta[mask, ]
  }

  if (nrow(meta) == 0) {
    cli::cli_inform("No se encontraron variables con esos criterios.")
  }
  meta
}

#' Muestra los valores codificados de una variable categórica
#'
#' @param variable Caracteres. Nombre de la variable (e.g., `"p25_sexo"`).
#' @return Un data.frame con columnas `codigo` y `etiqueta`, o un mensaje
#'   si la variable no tiene categorías.
#' @export
#' @examples
#' \dontrun{
#' codebook_valores("p25_sexo")
#' codebook_valores("nivel_edu")
#' }
codebook_valores <- function(variable) {
  meta <- codebook(variable = variable)
  if (nrow(meta) == 0) {
    cli::cli_abort("Variable {.var {variable}} no encontrada en el diccionario.")
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

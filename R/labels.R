#' Etiqueta los valores de las variables categóricas
#'
#' Convierte los códigos numéricos de las columnas categóricas del CPV-2024
#' en factores con las etiquetas en español del diccionario oficial del INE.
#' Se usa típicamente después de `collect()` para que los resultados sean
#' legibles directamente.
#'
#' @param df Un data.frame (resultado de `collect()`, `DBI::dbGetQuery()` u otro).
#' @param columnas Vector de caracteres con los nombres de columnas a etiquetar.
#'   Si `NULL` (por defecto), etiqueta todas las columnas categóricas presentes.
#'
#' @return El mismo `df` con las columnas categóricas convertidas a `factor`
#'   con las etiquetas del diccionario. Las columnas no encontradas en el
#'   diccionario se devuelven sin cambios.
#'
#' @details
#' Los valores que no coinciden con ningún código del diccionario (incluyendo
#' `NA`) quedan como `NA` en el factor resultante. Para ver los códigos
#' disponibles de una variable usa `codebook_valores()`.
#'
#' Para volver de etiquetas a códigos:
#' ```r
#' as.integer(df$p25_sexo)   # → 1, 2
#' as.character(df$p25_sexo) # → "Mujer", "Hombre"
#' ```
#'
#' Para etiquetar también los nombres de columna, encadena con
#' `etiquetar_variables()`.
#'
#' @seealso [etiquetar_variables()] para renombrar columnas con sus descripciones.
#' @export
#' @examples
#' # Etiquetar todas las columnas categóricas de un data.frame
#' \dontrun{
#' get_personas_2024(departamento = "Pando", as = "tibble") |>
#'   etiquetar_valores() |>
#'   head(3)
#' }
#'
#' # Flujo típico: Arrow → collect → etiquetar_valores
#' \dontrun{
#' get_personas_2024(departamento = "Santa Cruz") |>
#'   dplyr::filter(p26_edad >= 18) |>
#'   dplyr::count(p25_sexo) |>
#'   dplyr::collect() |>
#'   etiquetar_valores()
#' }
etiquetar_valores <- function(df, columnas = NULL) {
  cols <- if (is.null(columnas)) names(df) else columnas

  for (col in intersect(cols, names(df))) {
    idx <- which(codebook_meta$variable == col & codebook_meta$tipo == "categorica")
    if (length(idx) == 0) next

    vc <- codebook_meta$valores_codigos[[idx[1]]]
    if (is.null(vc) || nrow(vc) == 0) next

    df[[col]] <- factor(
      as.character(df[[col]]),
      levels = vc$codigo,
      labels = vc$etiqueta
    )
  }
  df
}

#' Etiqueta los nombres de las variables (columnas)
#'
#' Reemplaza los nombres técnicos de las columnas (e.g., `p25_sexo`) por sus
#' descripciones en español del diccionario oficial del INE
#' (e.g., `"25. Es mujer u hombre"`). Útil para tablas y reportes destinados
#' a lectores no técnicos.
#'
#' @param df Un data.frame.
#'
#' @return El mismo `df` con los nombres de columnas reemplazados por sus
#'   descripciones. Las columnas no encontradas en el diccionario conservan
#'   su nombre original.
#'
#' @details
#' Las descripciones pueden contener espacios y caracteres especiales.
#' En RMarkdown/Quarto se muestran directamente en tablas. Para referenciarlas
#' en código R usa backticks: \code{df$`25. Es mujer u hombre`}.
#'
#' Para etiquetar también los valores de las columnas, encadena con
#' `etiquetar_valores()`.
#'
#' @seealso [etiquetar_valores()] para convertir códigos numéricos a etiquetas.
#' @export
#' @examples
#' # Renombrar columnas de un resumen del diccionario
#' codebook_meta[1:5, c("variable", "etiqueta", "tabla")] |>
#'   etiquetar_variables()
#'
#' # Con datos reales: valores y nombres etiquetados
#' \dontrun{
#' get_personas_2024(departamento = "Pando") |>
#'   dplyr::count(p25_sexo, nivel_edu) |>
#'   dplyr::collect() |>
#'   etiquetar_valores() |>
#'   etiquetar_variables()
#' }
etiquetar_variables <- function(df) {
  names(df) <- vapply(names(df), function(col) {
    idx <- which(codebook_meta$variable == col)
    if (length(idx) == 0) col else codebook_meta$etiqueta[idx[1]]
  }, character(1))
  df
}

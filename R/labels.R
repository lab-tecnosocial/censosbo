#' Aplica etiquetas a las variables categóricas de un data.frame
#'
#' Convierte los códigos numéricos de las variables categóricas del CPV-2024
#' en factores con las etiquetas en español del diccionario oficial del INE.
#' Se usa típicamente después de `collect()` para que los resultados sean
#' legibles directamente.
#'
#' @param df Un data.frame (resultado de `collect()`, `DBI::dbGetQuery()` u otro).
#' @param variables Vector de caracteres con los nombres de columnas a etiquetar.
#'   Si `NULL` (por defecto), etiqueta todas las columnas categóricas presentes.
#'
#' @return El mismo `df` con las columnas categóricas convertidas a `factor`
#'   ordenado con las etiquetas del diccionario. Las columnas no encontradas
#'   en el diccionario se devuelven sin cambios.
#'
#' @details
#' Los valores que no coinciden con ningún código del diccionario (incluyendo
#' `NA`) se convierten en `NA` en el factor resultante. Para ver los códigos
#' disponibles de una variable usa `codebook_valores()`.
#'
#' Para cambiar entre etiquetas y códigos sobre un factor ya etiquetado:
#' ```r
#' # Etiquetas → códigos numéricos
#' as.integer(df$p25_sexo)
#'
#' # Etiquetas → cadenas de texto sin factor
#' as.character(df$p25_sexo)
#' ```
#'
#' @export
#' @examples
#' # Etiquetar todas las variables categóricas de una vez
#' sample_personas |> etiquetar() |> head(3)
#'
#' # Solo una variable específica
#' sample_personas |> etiquetar(variables = "p25_sexo") |> head(3)
#'
#' # Flujo típico: Arrow → collect → etiquetar
#' \dontrun{
#' get_personas(departamento = "Santa Cruz") |>
#'   dplyr::filter(p26_edad >= 18) |>
#'   dplyr::count(p25_sexo) |>
#'   dplyr::collect() |>
#'   etiquetar()
#' }
etiquetar <- function(df, variables = NULL) {
  cols <- if (is.null(variables)) names(df) else variables

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

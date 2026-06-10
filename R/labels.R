# Detecta el año del censo a partir de los nombres de columna del data frame.
# Compara contra todos los codebooks y devuelve el año con más coincidencias.
.detect_censo_anio <- function(df) {
  cols <- names(df)
  all_cbs <- c(list("2024" = codebook_meta), codebook_historico_meta)
  matches <- vapply(all_cbs, function(cb) sum(cols %in% cb$variable), integer(1))
  if (max(matches) == 0) {
    cli::cli_warn(c(
      "No se pudo detectar el censo por los nombres de columnas. Usando 2024.",
      "i" = "Especifica el año con {.arg anio}: {.code etiquetar_valores(df, anio = 1992)}"
    ))
    return(2024L)
  }
  as.integer(names(which.max(matches)))
}

.get_codebook_for_anio <- function(anio) {
  anio <- as.integer(anio)
  if (anio == 2024L) codebook_meta else codebook_historico_meta[[as.character(anio)]]
}

#' Etiqueta los valores de las variables categóricas
#'
#' Convierte los códigos numéricos de las columnas categóricas en factores con
#' las etiquetas en español del diccionario oficial del INE. Detecta
#' automáticamente el censo (1976, 1992, 2001, 2012 o 2024) a partir de los
#' nombres de columna del data frame.
#'
#' @param df Un data.frame (resultado de `collect()`, `DBI::dbGetQuery()` u otro).
#' @param columnas Vector de caracteres con los nombres de columnas a etiquetar.
#'   Si `NULL` (por defecto), etiqueta todas las columnas categóricas presentes.
#' @param anio Entero. Año del censo: `1976`, `1992`, `2001`, `2012` o `2024`.
#'   Si `NULL` (por defecto), se detecta automáticamente a partir de los nombres
#'   de columna del data frame.
#'
#' @return El mismo `df` con las columnas categóricas convertidas a `factor`
#'   con las etiquetas del diccionario. Las columnas no encontradas en el
#'   diccionario se devuelven sin cambios.
#'
#' @details
#' La detección automática del censo funciona comparando los nombres de columna
#' del data frame con los de cada codebook. Dado que cada censo usa una
#' convención de nombrado única (p.ej. `p25_sexo` en 2024 vs `P25` en 1992),
#' la detección es confiable incluso después de `count()` o `filter()`.
#'
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
#' @seealso [etiquetar_variables()] para renombrar columnas con sus descripciones.
#' @export
#' @examples
#' # Censo 2024 — detección automática
#' \dontrun{
#' get_personas_2024(departamento = "Pando", as = "tibble") |>
#'   etiquetar_valores() |>
#'   head(3)
#' }
#'
#' # Censo 1992 — detección automática
#' \dontrun{
#' get_personas_1992(departamento = "07", as = "tibble") |>
#'   dplyr::count(P25) |>
#'   etiquetar_valores()
#' }
#'
#' # Año explícito como escape hatch
#' \dontrun{
#' df |> etiquetar_valores(anio = 1992)
#' }
etiquetar_valores <- function(df, columnas = NULL, anio = NULL) {
  anio <- if (!is.null(anio)) as.integer(anio) else .detect_censo_anio(df)
  meta <- .get_codebook_for_anio(anio)
  cols <- if (is.null(columnas)) names(df) else columnas

  for (col in intersect(cols, names(df))) {
    idx <- which(meta$variable == col & meta$tipo == "categorica")
    if (length(idx) == 0) next

    vc <- meta$valores_codigos[[idx[1]]]
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
#' (e.g., `"25. Es mujer u hombre"`). Detecta automáticamente el censo
#' (1976, 1992, 2001, 2012 o 2024) a partir de los nombres de columna.
#' Útil para tablas y reportes destinados a lectores no técnicos.
#'
#' @param df Un data.frame.
#' @param anio Entero. Año del censo: `1976`, `1992`, `2001`, `2012` o `2024`.
#'   Si `NULL` (por defecto), se detecta automáticamente a partir de los nombres
#'   de columna del data frame.
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
#' La detección automática del censo compara nombres de columna con los
#' codebooks disponibles. Usa `anio` explícito si el data frame tiene muy
#' pocas columnas o solo columnas geográficas.
#'
#' @seealso [etiquetar_valores()] para convertir códigos numéricos a etiquetas.
#' @export
#' @examples
#' # Renombrar columnas de un resumen del diccionario
#' codebook_meta[1:5, c("variable", "etiqueta", "tabla")] |>
#'   etiquetar_variables()
#'
#' # Censo 2024: valores y nombres etiquetados
#' \dontrun{
#' get_personas_2024(departamento = "Pando") |>
#'   dplyr::count(p25_sexo, nivel_edu) |>
#'   dplyr::collect() |>
#'   etiquetar_valores() |>
#'   etiquetar_variables()
#' }
#'
#' # Censo 1992: mismo flujo sin especificar año
#' \dontrun{
#' get_personas_1992(departamento = "07") |>
#'   dplyr::count(P25) |>
#'   dplyr::collect() |>
#'   etiquetar_valores() |>
#'   etiquetar_variables()
#' }
etiquetar_variables <- function(df, anio = NULL) {
  anio <- if (!is.null(anio)) as.integer(anio) else .detect_censo_anio(df)
  meta <- .get_codebook_for_anio(anio)

  names(df) <- vapply(names(df), function(col) {
    idx <- which(meta$variable == col)
    if (length(idx) == 0) col else meta$etiqueta[idx[1]]
  }, character(1))
  df
}

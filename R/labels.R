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

# Columnas que son categóricas en ALGÚN codebook (2024 o histórico). Se usa para
# distinguir "no se etiquetó porque no hay nada categórico" de "no se etiquetó
# porque se detectó el censo equivocado".
.cols_categoricas_conocidas <- function(cols) {
  all_cbs <- c(list(codebook_meta), unname(codebook_historico_meta))
  reconocidas <- character(0)
  for (cb in all_cbs) {
    reconocidas <- c(reconocidas, cb$variable[cb$tipo == "categorica"])
  }
  intersect(cols, unique(reconocidas))
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
#' Con datos de [get_temporal()] / [get_temporal_vivienda()] se usan las etiquetas
#' **armonizadas** (no las de un censo concreto). Esto se detecta por la columna
#' `anio`; conviene conservarla al resumir. Para variables cuyo nombre también
#' existe como columna cruda (`nivel_edu`, `area`, `pea`, `pet`), la columna `anio`
#' es necesaria para distinguir datos temporales de datos crudos del CPV-2024.
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
  cols <- if (is.null(columnas)) names(df) else columnas

  # Datos armonizados de get_temporal()/get_temporal_vivienda(). Sus códigos NO
  # coinciden con el diccionario de ningún censo individual, así que se usan
  # etiquetas propias (y las variables passthrough se dejan sin tocar).
  # Detección: (a) columna `anio` con años censales —señal definitiva, incluso para
  # nombres que también existen como columnas crudas (nivel_edu, area, pea, pet)—, o
  # (b) sin `anio`, basta un nombre armonizado que no colisione con ningún censo crudo.
  anios_censales <- c(1976L, 1992L, 2001L, 2012L, 2024L)
  tiene_anio <- "anio" %in% names(df) &&
    length(stats::na.omit(as.integer(df[["anio"]]))) > 0 &&
    all(stats::na.omit(as.integer(df[["anio"]])) %in% anios_censales)
  nombres_armon_unicos <- setdiff(names(.HARMONIZED_VALUE_LABELS),
                                  c("area", "nivel_edu", "pea", "pet"))
  es_temporal <- is.null(anio) &&
    (tiene_anio || any(intersect(cols, names(df)) %in% nombres_armon_unicos))
  if (es_temporal) {
    for (col in intersect(cols, names(df))) {
      labs <- .HARMONIZED_VALUE_LABELS[[col]]
      if (is.null(labs)) next
      df[[col]] <- factor(
        as.character(df[[col]]),
        levels = names(labs),
        labels = unname(labs)
      )
    }
    return(df)
  }

  deteccion_auto <- is.null(anio)
  anio <- if (!is.null(anio)) as.integer(anio) else .detect_censo_anio(df)
  meta <- .get_codebook_for_anio(anio)

  cols_presentes <- intersect(cols, names(df))
  etiquetadas <- 0L
  sin_match   <- character(0)  # categóricas reconocidas cuyos valores no matchearon

  for (col in cols_presentes) {
    idx <- which(meta$variable == col & meta$tipo == "categorica")
    if (length(idx) == 0) next

    vc <- meta$valores_codigos[[idx[1]]]
    if (is.null(vc) || nrow(vc) == 0) next

    orig <- as.character(df[[col]])
    f <- factor(orig, levels = vc$codigo, labels = vc$etiqueta)

    # Si la columna traía datos pero NINGÚN valor coincidió con los códigos del
    # censo detectado, es señal de censo equivocado: se deja cruda y se avisa
    # (en vez de devolver una columna toda-NA en silencio).
    if (any(!is.na(orig)) && all(is.na(f))) {
      sin_match <- c(sin_match, col)
      next
    }
    df[[col]] <- f
    etiquetadas <- etiquetadas + 1L
  }

  # Avisos de detección ambigua / etiquetado fallido (solo con detección auto).
  if (deteccion_auto) {
    if (length(sin_match) > 0) {
      cli::cli_warn(c(
        "!" = "No se pudo etiquetar {.val {sin_match}}: sus valores no coinciden con los códigos del censo {anio}.",
        "i" = "Puede que el censo detectado sea incorrecto. Especifícalo con {.arg anio}, p.ej. {.code etiquetar_valores(df, anio = 1992)}."
      ))
    } else if (etiquetadas == 0L && length(.cols_categoricas_conocidas(cols_presentes)) > 0) {
      cli::cli_warn(c(
        "!" = "No se etiquetó ninguna columna: ninguna de las categóricas presentes existe en el censo {anio} detectado.",
        "i" = "Especifica el censo con {.arg anio}, p.ej. {.code etiquetar_valores(df, anio = 1992)}."
      ))
    }
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
#'   descripciones. Las columnas no encontradas en el diccionario —y las que
#'   están pero sin descripción, como algunas variables derivadas del censo
#'   1976— conservan su nombre original.
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
    if (length(idx) == 0) return(col)
    etq <- meta$etiqueta[idx[1]]
    # Algunas variables derivadas del censo 1976 llegan sin etiqueta en el
    # diccionario del INE. Renombrarlas a "" dejaría columnas sin nombre (y
    # duplicadas entre sí), así que en ese caso se conserva el nombre original.
    if (is.na(etq) || !nzchar(trimws(etq))) col else etq
  }, character(1))
  df
}

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
#'     `"emigracion"`, `"mortalidad"`, `"unidad"` o `"ficha"`}
#'   \item{valores_codigos}{Lista de data.frames con los códigos y etiquetas
#'     para variables categóricas; `NULL` para variables numéricas o de texto}
#'   \item{tipo}{Tipo de dato: `"categorica"`, `"numerica"` o `"texto"`.
#'     Una variable es `"categorica"` si sus valores son códigos con etiquetas
#'     (aunque sean números, como `sexo` 1/2) o si su nombre indica un código de
#'     clasificación (sufijo `cod`: códigos geográficos, de ocupación, etc.);
#'     `"texto"` si almacena texto libre; `"numerica"` en los demás casos
#'     (conteos y medidas)}
#'   \item{tema}{Uno de los 21 temas de [censo_temas_meta]. Es el eje comparable
#'     entre censos}
#'   \item{capitulo}{Capítulo del cuestionario del CPV-2024 (`"A"`–`"G"`); `NA` en
#'     los censos anteriores, cuya estructura oficial está en `grupo_ine`}
#'   \item{pregunta, pregunta_num}{Número de pregunta del formulario, como texto y
#'     como entero, para recorrer el censo en el orden en que se aplicó}
#'   \item{origen}{Procedencia: `"cuestionario"` (pregunta directa), `"derivada"`
#'     (construida por el INE o por REDATAM), `"geografia"`, `"identificador"` o
#'     `"indicador"` (agregados de las fichas de manzano y comunidad)}
#'   \item{universo}{Población de referencia normalizada (`"personas_5_mas"`,
#'     `"mujeres_12_mas"`, `"viviendas_presentes"`…). Es el denominador correcto
#'     de la variable; `NA` cuando el INE no lo declara}
#'   \item{grupo_ine}{Agrupación oficial del censo de origen; `NA` en 2024, que no
#'     la publica}
#'   \item{bloque, denominador}{Bloque de [censo_bloques_meta] y denominador de los
#'     indicadores de manzano y comunidad; `NA` en el resto de variables}
#'   \item{valores_fuente}{De dónde salen las etiquetas de valor: `"redatam"`,
#'     `"ddi"` o el diccionario oficial}
#' }
#' @source INE Bolivia, CPV-2024. Diccionario de Variables CPV 2024.xlsx, los
#'   cuestionarios censales y el DDI del estudio 132 del catálogo ANDA.
#' @seealso [censo_temas()] y [vars_tema()] para navegar por tema, y
#'   [codebook_docs_meta] para los textos conceptuales del INE.
"codebook_meta"

#' Diccionarios de variables de los censos históricos de Bolivia
#'
#' Lista nombrada con los metadatos de variables de los censos 1976, 1992,
#' 2001 y 2012. Cada elemento es un data.frame con la misma estructura que
#' [codebook_meta].
#'
#' @format Una lista con elementos `"1976"`, `"1992"`, `"2001"` y `"2012"`, cada
#'   uno un data.frame con las mismas columnas que [codebook_meta]. Estos objetos
#'   guardan `tipo` y `valores_codigos` en orden inverso al de `codebook_meta`, por
#'   razones históricas; [codebook()] reordena las columnas al devolver, así que
#'   consultado por ahí el esquema es idéntico en los cinco censos. Tres
#'   particularidades de contenido:
#' \describe{
#'   \item{variable}{Conserva el nombre original del censo, que en los primeros
#'     años son códigos cortos (`p10`, `anioes1`) y no nombres descriptivos}
#'   \item{tabla}{Es la entidad REDATAM de origen, así que varía entre censos
#'     (`"poblacion"` en 1976 donde 2024 usa `"persona"`)}
#'   \item{capitulo}{Siempre `NA`: los capítulos son los del cuestionario del
#'     CPV-2024. La estructura oficial de cada año está en `grupo_ine`}
#' }
#' @source INE Bolivia. Diccionarios Parquet generados por open-redatam, con el
#'   tema y el universo añadidos desde los DDI del catálogo ANDA (estudios 8, 10,
#'   47 y 46) y los cuestionarios de cada censo.
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
#'   de variables, y también en el tema y el capítulo (no distingue
#'   mayúsculas/minúsculas). Se interpreta como expresión regular.
#' @param anio Entero. Año del censo: `2024` (defecto), `1976`, `1992`, `2001`
#'   o `2012`.
#' @param tema Caracteres. Filtra por tema, con los slugs de [censo_temas_meta]
#'   (e.g. `"educacion"`, `"servicios_basicos"`). Acepta varios. Disponible en los
#'   cinco censos; ver [censo_temas()].
#' @param capitulo Caracteres. Filtra por capítulo del cuestionario del CPV-2024:
#'   la letra (`"C"`) o parte de su nombre (`"vivienda"`). Solo aplica a 2024: los
#'   cuestionarios anteriores tienen otra estructura y varios numeran las secciones
#'   de vivienda y de persona en paralelo. El eje comparable entre censos es `tema`.
#' @param origen Caracteres. Filtra por procedencia de la variable:
#'   `"cuestionario"` (pregunta directa), `"derivada"` (construida por el INE),
#'   `"geografia"`, `"identificador"` o `"indicador"` (agregados de las fichas de
#'   manzano y comunidad).
#'
#' @return Un data.frame con las variables que coinciden con los filtros. Las
#'   columnas son siempre las mismas para los cinco censos.
#'
#' @seealso [censo_temas()] para el catálogo de temas, [vars_tema()] para obtener
#'   los nombres de variable de un tema, y [codebook_docs()] para la definición
#'   conceptual y la pregunta literal de cada variable.
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
#'
#' # Por tema, y comparando entre censos
#' codebook(tema = "educacion", tabla = "persona")
#' codebook(tema = "educacion", tabla = "persona", anio = 2012)
#'
#' # Por capítulo del cuestionario, solo las preguntas directas
#' codebook(capitulo = "C", origen = "cuestionario")
codebook <- function(variable = NULL, tabla = NULL, buscar = NULL, anio = 2024,
                     tema = NULL, capitulo = NULL, origen = NULL) {
  anio <- as.integer(anio)
  meta <- if (anio == 2024L) {
    codebook_meta
  } else {
    if (!exists("codebook_historico_meta")) {
      cli::cli_abort(c(
        "Los diccionarios hist\u00f3ricos no est\u00e1n cargados.",
        "i" = "Aseg\u00farate de tener instalada la versi\u00f3n m\u00e1s reciente del paquete."
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

  # Filtros de taxonomía. Van después de `tabla` y antes de `buscar`.
  if (!is.null(tema)) meta <- .filtrar_tema(meta, tema, anio)
  if (!is.null(capitulo)) meta <- .filtrar_capitulo(meta, capitulo, anio)
  if (!is.null(origen)) meta <- .filtrar_origen(meta, origen, anio)

  if (!is.null(buscar)) {
    mask <- grepl(buscar, meta$etiqueta, ignore.case = TRUE) |
      grepl(buscar, meta$variable, ignore.case = TRUE)
    # `buscar` alcanza también al tema y al capítulo, para que
    # codebook(buscar = "salud") encuentre el tema completo y no solo las
    # variables cuya etiqueta contiene la palabra.
    if ("tema" %in% names(meta)) {
      etiq_tema <- censo_temas_meta$etiqueta[match(meta$tema, censo_temas_meta$tema)]
      mask <- mask |
        (!is.na(meta$tema) & grepl(buscar, meta$tema, ignore.case = TRUE)) |
        (!is.na(etiq_tema) & grepl(buscar, etiq_tema, ignore.case = TRUE))
    }
    meta <- meta[mask, ]
  }

  if (nrow(meta) == 0) {
    cli::cli_inform("No se encontraron variables con esos criterios en el censo {anio}.")
  }

  # Bug 4: ordenar para que "persona" preceda a "vivienda" y otras tablas auxiliares,
  # evitando que el usuario use por error variables de vivienda en datos de personas
  tabla_orden <- c(
    "persona", "vivienda", "emigracion", "mortalidad", "discapacidad",
    "unidad", "ficha", "depto", "provin", "munic"
  )
  rango <- match(meta$tabla, tabla_orden)
  rango[is.na(rango)] <- length(tabla_orden) + 1L
  meta <- meta[order(rango), ]
  rownames(meta) <- NULL

  .ordenar_columnas_codebook(meta)
}

# Orden canónico de columnas. Los codebooks históricos guardan `tipo` y
# `valores_codigos` en orden inverso al de codebook_meta desde antes de que
# existiera la taxonomía; reordenar aquí (y no en los .rda) hace que codebook()
# devuelva la misma forma en los cinco censos sin alterar el dato guardado ni el
# orden que codebook_meta expone como contrato.
.COLS_CODEBOOK <- c(
  "variable", "etiqueta", "tabla", "valores_codigos", "tipo",
  "tema", "capitulo", "pregunta", "pregunta_num", "origen",
  "universo", "grupo_ine", "bloque", "denominador", "valores_fuente"
)

.ordenar_columnas_codebook <- function(meta) {
  presentes <- intersect(.COLS_CODEBOOK, names(meta))
  meta <- meta[, c(presentes, setdiff(names(meta), presentes)), drop = FALSE]
  # Clase propia solo para la impresión (ver print.censosbo_codebook). Hereda de
  # data.frame, así que todo lo demás —`$`, `[`, dplyr, arrow— sigue funcionando
  # igual, y quien la pierda por el camino obtiene la impresión estándar.
  class(meta) <- c("censosbo_codebook", "data.frame")
  meta
}

# Los cinco censos tienen diccionario DDI en el catálogo ANDA, así que todos
# llevan taxonomía. `capitulo` es la excepción: son los capítulos del cuestionario
# del CPV-2024 y no existen en los anteriores (ver .filtrar_capitulo).
.ANIOS_CON_TAXONOMIA <- c(2024L, 2012L, 2001L, 1992L, 1976L)

.exigir_taxonomia <- function(anio, arg) {
  if (anio %in% .ANIOS_CON_TAXONOMIA) return(invisible(TRUE))
  # La variable local es necesaria: cli >= 3.4 interpreta `{.algo}` como un
  # estilo, no como una interpolación.
  disponibles <- .ANIOS_CON_TAXONOMIA
  # Los cinco censos tienen taxonomía, así que cualquier otro año simplemente no es
  # un censo de Bolivia. Decirlo así, en vez de sugerir que falta el metadato.
  cli::cli_abort(c(
    "No hay diccionario para el censo {anio}.",
    "i" = "Los censos disponibles son {.val {disponibles}}."
  ))
}

.filtrar_tema <- function(meta, tema, anio) {
  .exigir_taxonomia(anio, "tema")
  validos <- censo_temas_meta$tema
  pedidos <- tolower(trimws(tema))
  desconocidos <- setdiff(pedidos, tolower(validos))
  if (length(desconocidos) > 0) {
    # Distancia de edición en vez de agrep(): agrep busca subcadenas aproximadas,
    # y ante "educacon" proponía "ubicacion_geografica" (que contiene algo
    # parecido a "ucacion") antes que "educacion".
    sugerencias <- unlist(lapply(desconocidos, function(d) {
      dist <- utils::adist(d, validos, ignore.case = TRUE)[1, ]
      rel <- dist / pmax(nchar(d), nchar(validos))
      if (min(rel) <= 0.4) validos[which.min(rel)] else character()
    }))
    cli::cli_abort(c(
      "Tema no reconocido: {.val {desconocidos}}",
      if (length(sugerencias)) c("i" = "\u00bfQuisiste decir {.val {unique(sugerencias)}}?"),
      "i" = "Usa {.code censo_temas()} para ver los {length(validos)} temas disponibles."
    ))
  }
  meta[!is.na(meta$tema) & tolower(meta$tema) %in% pedidos, ]
}

.filtrar_capitulo <- function(meta, capitulo, anio) {
  if (anio != 2024L) {
    cli::cli_abort(c(
      "{.arg capitulo} solo aplica al CPV-2024.",
      "i" = "Los cuestionarios de {anio} tienen otra estructura y otra numeraci\u00f3n; el eje comparable entre censos es {.arg tema}.",
      "i" = "La estructura oficial de {anio} est\u00e1 en la columna {.field grupo_ine}."
    ))
  }
  caps <- unique(stats::na.omit(meta$capitulo))
  etiquetas <- censo_temas_meta$capitulo_etiqueta[
    match(caps, censo_temas_meta$capitulo)]
  pedidos <- trimws(capitulo)

  # Acepta la letra ("C") o parte del nombre del capítulo ("vivienda").
  elegidos <- unlist(lapply(pedidos, function(p) {
    if (toupper(p) %in% caps) return(toupper(p))
    hit <- caps[!is.na(etiquetas) & grepl(p, etiquetas, ignore.case = TRUE)]
    if (length(hit)) return(hit)
    cli::cli_abort(c(
      "Cap\u00edtulo no reconocido: {.val {p}}",
      "i" = "Usa la letra ({.val {caps}}) o parte de su nombre.",
      "i" = "Los cap\u00edtulos son los del cuestionario del CPV-2024; m\u00edralos con {.code censo_temas()}."
    ))
  }))
  meta[!is.na(meta$capitulo) & meta$capitulo %in% elegidos, ]
}

.filtrar_origen <- function(meta, origen, anio) {
  .exigir_taxonomia(anio, "origen")
  validos <- c("cuestionario", "derivada", "geografia", "identificador", "indicador")
  pedidos <- tolower(trimws(origen))
  desconocidos <- setdiff(pedidos, validos)
  if (length(desconocidos) > 0) {
    cli::cli_abort(c(
      "Origen no reconocido: {.val {desconocidos}}",
      "i" = "Valores v\u00e1lidos: {.val {validos}}."
    ))
  }
  meta[!is.na(meta$origen) & meta$origen %in% pedidos, ]
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
#' # Los diccionarios vienen dentro del paquete: esto no descarga nada.
#' codebook_valores("p25_sexo")
#' codebook_valores("P23", anio = 2012)
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
      "La variable {.var {variable}} ({meta$etiqueta[1]}) es {meta$tipo[1]}, sin categor\u00edas."
    )
    return(invisible(NULL))
  }
  vals
}

# ==============================================================================
# Impresión
# ==============================================================================

#' @export
print.censosbo_codebook <- function(x, ...) {
  df <- x
  class(df) <- "data.frame"

  if (nrow(df) == 0) {
    cat("Ninguna variable coincide con esos criterios.\n")
    return(invisible(x))
  }

  # `valores_codigos` es una list-column de data.frames: imprimirla vuelca todas
  # las categorías de todas las filas y tapa el resto de la salida. Se resume por
  # su número de categorías, que es lo que se quiere saber de un vistazo;
  # codebook_valores() da el detalle.
  if ("valores_codigos" %in% names(df)) {
    n <- vapply(df$valores_codigos,
                function(v) if (is.null(v)) 0L else nrow(v), integer(1))
    df$valores_codigos <- ifelse(n == 0L, "", paste0(n, " categor\u00edas"))
    names(df)[names(df) == "valores_codigos"] <- "categorias"
  }

  # Ocultar las columnas que no aportan nada en este subconjunto. Consultar la
  # tabla `persona` deja cuatro columnas enteramente vacías (`grupo_ine`,
  # `bloque`, `denominador`, `valores_fuente`), y con quince columnas la salida en
  # consola se vuelve ilegible. El data.frame las conserva todas.
  vacia <- vapply(df, function(col) {
    if (is.list(col)) return(FALSE)
    all(is.na(col) | (is.character(col) & !nzchar(col)))
  }, logical(1))
  ocultas <- names(df)[vacia]
  if (length(ocultas) > 0) df <- df[, !vacia, drop = FALSE]

  print(df, ...)
  if (length(ocultas) > 0) {
    cat(sprintf("\n%d columna%s sin datos aqu\u00ed: %s\n",
                length(ocultas), if (length(ocultas) == 1) "" else "s",
                paste(ocultas, collapse = ", ")))
  }
  invisible(x)
}

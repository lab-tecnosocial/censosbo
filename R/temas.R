#' Catálogo de temas de los censos de Bolivia
#'
#' Los 21 temas con los que `censosbo` agrupa las variables censales. Diecisiete
#' son los `topics` oficiales que el INE declara en el catálogo ANDA del CPV-2024;
#' los otros cuatro (`ubicacion_geografica`, `identificacion`,
#' `materiales_construccion` y `religion`) son extensiones del paquete, marcadas
#' en la columna `fuente`.
#'
#' El mismo vocabulario se aplica a los cinco censos, de modo que
#' `codebook(tema = "educacion", anio = ...)` sea comparable entre ellos. Los
#' ocho temas del vocabulario antiguo del INE (idénticos en 2012, 2001, 1992 y
#' 1976) se mapearon a estos veintiuno: seis literales coinciden y dos son
#' renombrados (`Hogar y/o Vivienda` y `Empleo, Ocupación y Actividad Económica`).
#'
#' @section Capítulo y tema son dos facetas independientes:
#' Cada variable tiene exactamente un `capitulo` y un `tema`, pero el tema **no**
#' está anidado en el capítulo: `v01_tipoviv` está en el capítulo B y
#' `v17_tenencia` en el C, y los dos son `vivienda_hogar`. En esta tabla,
#' `capitulo` es el capítulo principal del tema (donde vive la mayoría de sus
#' variables) y `capitulos` lista todos aquellos en los que aparece.
#'
#' Los capítulos son los del cuestionario del CPV-2024 y solo se aplican a ese
#' censo; en los censos anteriores la columna `capitulo` del codebook queda a `NA`
#' y la estructura oficial de cada año vive en `grupo_ine`.
#'
#' @format Un data.frame de 21 filas:
#' \describe{
#'   \item{tema}{Identificador en snake_case; es la clave que acepta
#'     `codebook(tema = )` y [vars_tema()]}
#'   \item{etiqueta}{Nombre legible del tema}
#'   \item{capitulo}{Capítulo principal del cuestionario CPV-2024 (`"A"`–`"G"`)}
#'   \item{capitulo_etiqueta}{Nombre del capítulo}
#'   \item{capitulos}{Todos los capítulos en que aparece el tema, separados por coma}
#'   \item{anios}{Censos en los que el tema tiene variables}
#'   \item{fuente}{`"INE-ANDA"` si es un topic oficial, `"censosbo"` si es una
#'     extensión del paquete}
#'   \item{orden}{Orden de presentación: por capítulo y luego por cuestionario}
#'   \item{descripcion}{Qué incluye el tema y, cuando la asignación es
#'     discutible, por qué se decidió así}
#' }
#' @source INE Bolivia — catálogo ANDA, estudios 132 (CPV-2024), 8 (CPV-2012),
#'   10 (CNPV-2001), 47 (CNPV-1992) y 46 (CNPV-1976), elemento `topcClas` del DDI.
#' @seealso [censo_temas()] para consultarlo con conteos de variables.
"censo_temas_meta"

#' Bloques temáticos de los indicadores de manzano y comunidad
#'
#' Los 15 bloques con que el INE organiza las fichas censales del CPV-2024 en su
#' geoportal. Es un desglose más fino que el tema: `salud_lugar` y `salud_seguro`
#' son dos bloques dentro del tema `salud_seguridad_social`.
#'
#' Se publica porque hasta ahora esta agrupación vivía duplicada a mano en los
#' proyectos que consumen el paquete. La fuente única son
#' `data-raw/fichas/campos.csv` y `campos_vivienda.csv`.
#'
#' @format Un data.frame de 15 filas con columnas `bloque`, `etiqueta`, `tema`,
#'   `capitulo` y `orden`.
#' @source INE Bolivia, fichas censales del geoportal del CPV-2024.
"censo_bloques_meta"

#' Documentación conceptual de las variables censales
#'
#' Textos oficiales del INE para cada variable: qué mide, a quién se le preguntó,
#' la pregunta tal como se leyó en campo, las instrucciones que recibió el
#' censista y —para las variables que el INE construyó— cómo se calcularon.
#'
#' Va en una tabla aparte de [codebook_meta] a propósito: algunos de estos textos
#' pasan de los 4.000 caracteres y harían ilegible la salida de [codebook()].
#' Consúltese con [codebook_docs()].
#'
#' Cubre las variables de los cinco censos que existen en el paquete (445 de las
#' 539 que documenta el ANDA; el resto son campos de texto abierto e
#' identificadores que los microdatos publicados no incluyen).
#'
#' @format Un data.frame de 445 filas:
#' \describe{
#'   \item{anio}{Censo: 2024, 2012, 2001, 1992 o 1976}
#'   \item{variable, tabla}{Clave; coinciden con [codebook_meta]}
#'   \item{variable_ddi}{Nombre en el diccionario del ANDA, que no siempre es el
#'     de los microdatos (en 2012 el ANDA usa `P23_PARENTES` y los datos `P23`)}
#'   \item{definicion}{Definición conceptual de la variable}
#'   \item{universo_literal}{Población de referencia, en las palabras del INE.
#'     La versión normalizada y comparable está en `codebook_meta$universo`}
#'   \item{pregunta_literal}{La pregunta como se formuló, con sus opciones y saltos}
#'   \item{regla_derivacion}{Cómo construyó el INE la variable; solo en las
#'     derivadas de 2024 y 1992}
#'   \item{notas}{Advertencias del INE, como el significado de los códigos de
#'     omisión. Solo disponible en 2024}
#'   \item{informante}{Quién respondía: `"jefe_hogar"`, `"persona_misma"`,
#'     `"empadronador"` u `"observacion"`}
#'   \item{instruccion}{Instrucciones al censista. Es donde el INE define en
#'     términos operativos conceptos como hogar o residencia habitual}
#' }
#' @source INE Bolivia — catálogo ANDA, DDI de los estudios 132 (CPV-2024), 8
#'   (CPV-2012), 10 (CNPV-2001), 47 (CNPV-1992) y 46 (CNPV-1976). El atributo
#'   `"ddi"` del objeto registra las URL, fechas de descarga y sha256 de los
#'   archivos usados. Los textos se reproducen literalmente; el INE los publica
#'   bajo la condición «Uso público».
"codebook_docs_meta"


#' Consulta los temas de un censo, con el número de variables de cada uno
#'
#' Devuelve el catálogo de [censo_temas_meta] contando, en vivo, cuántas variables
#' tiene cada tema en el censo y la tabla que se pidan. El conteo se calcula sobre
#' el codebook en el momento de la llamada, así que nunca se desincroniza.
#'
#' @param tema Caracteres. Filtra a uno o varios temas por su slug.
#' @param capitulo Caracteres. Filtra por capítulo del cuestionario del CPV-2024:
#'   la letra (`"C"`) o parte de su nombre (`"vivienda"`).
#' @param tabla Caracteres. Restringe el conteo a una tabla (e.g. `"persona"`).
#'   Con este argumento se omiten los temas que no tienen ninguna variable ahí.
#' @param anio Entero. `2024` (defecto), `2012`, `2001`, `1992` o `1976`.
#'
#' @return Un data.frame con `tema`, `etiqueta`, `capitulo`, `capitulo_etiqueta`,
#'   `fuente`, `n_variables` y `descripcion`, ordenado por capítulo y cuestionario.
#'
#' @seealso [vars_tema()] para obtener los nombres de las variables de un tema, y
#'   [codebook()] para sus etiquetas y categorías.
#'
#' @export
#' @examples
#' # Los 20 temas del CPV-2024, con cuántas variables tiene cada uno
#' censo_temas()
#'
#' # Solo los temas presentes en la tabla de vivienda
#' censo_temas(tabla = "vivienda")
#'
#' # Qué temas cubre el censo 2001
#' censo_temas(anio = 2001)
censo_temas <- function(tema = NULL, capitulo = NULL, tabla = NULL, anio = 2024) {
  anio <- as.integer(anio)
  .exigir_taxonomia(anio, "censo_temas()")

  meta <- .get_codebook_for_anio(anio)
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

  out <- censo_temas_meta
  out$n_variables <- as.integer(table(factor(meta$tema, levels = out$tema)))

  # Sin filtro de tabla se listan todos los temas del año; con filtro, solo los
  # que efectivamente tienen variables ahí (un catálogo lleno de ceros no informa).
  del_anio <- vapply(strsplit(out$anios, ","), function(a) as.character(anio) %in% a, logical(1))
  out <- out[del_anio & (is.null(tabla) | out$n_variables > 0), ]

  if (!is.null(tema)) {
    pedidos <- tolower(trimws(tema))
    desconocidos <- setdiff(pedidos, tolower(censo_temas_meta$tema))
    if (length(desconocidos) > 0) {
      cli::cli_abort(c(
        "Tema no reconocido: {.val {desconocidos}}",
        "i" = "Usa {.code censo_temas()} sin argumentos para ver los disponibles."
      ))
    }
    out <- out[tolower(out$tema) %in% pedidos, ]
  }
  if (!is.null(capitulo)) {
    pedidos <- trimws(capitulo)
    elegidos <- unlist(lapply(pedidos, function(p) {
      if (toupper(p) %in% out$capitulo) return(toupper(p))
      hit <- out$capitulo[grepl(p, out$capitulo_etiqueta, ignore.case = TRUE)]
      if (length(hit)) return(unique(hit))
      cli::cli_abort(c(
        "Cap\u00edtulo no reconocido: {.val {p}}",
        "i" = "Usa la letra ({.val {unique(out$capitulo)}}) o parte de su nombre."
      ))
    }))
    out <- out[out$capitulo %in% elegidos, ]
  }

  out <- out[order(out$orden),
             c("tema", "etiqueta", "capitulo", "capitulo_etiqueta", "fuente",
               "n_variables", "descripcion")]
  rownames(out) <- NULL
  out
}

#' Nombres de las variables de un tema
#'
#' Devuelve un vector de caracteres listo para pasar al argumento `variables` de
#' las funciones `get_*()`, o a `dplyr::select(dplyr::all_of())`.
#'
#' Las variables salen en el orden del cuestionario (capítulo, luego número de
#' pregunta) y las derivadas al final, para que la selección se lea igual que el
#' formulario original.
#'
#' @param tema Caracteres. Uno o varios temas, con los slugs de [censo_temas_meta].
#' @param tabla Caracteres. Restringe a una tabla. Conviene indicarla cuando el
#'   tema abarca varias, porque pasar variables de `vivienda` a
#'   [get_personas_2024()] no devuelve nada útil.
#' @param tipo Caracteres. Filtra por tipo de dato: `"categorica"`, `"numerica"`
#'   o `"texto"`.
#' @param origen Caracteres. Filtra por procedencia: `"cuestionario"`,
#'   `"derivada"`, `"geografia"`, `"identificador"` o `"indicador"`.
#' @param capitulo Caracteres. Filtra por capítulo del cuestionario (solo 2024).
#' @param anio Entero. `2024` (defecto), `2012`, `2001`, `1992` o `1976`.
#'
#' @return Un vector de caracteres, sin duplicados.
#'
#' @seealso [censo_temas()] para ver qué temas existen.
#'
#' @export
#' @examples
#' vars_tema("educacion", tabla = "persona")
#'
#' # Solo las preguntas directas, sin las derivadas del INE
#' vars_tema("caracteristicas_economicas", tabla = "persona", origen = "cuestionario")
#'
#' \dontrun{
#' # Descargar solo las variables de un tema
#' get_personas_2024(
#'   departamento = "Cochabamba",
#'   variables = vars_tema("educacion", tabla = "persona")
#' )
#' }
vars_tema <- function(tema, tabla = NULL, tipo = NULL, origen = NULL,
                      capitulo = NULL, anio = 2024) {
  anio <- as.integer(anio)
  meta <- codebook(tabla = tabla, anio = anio, tema = tema,
                   capitulo = capitulo, origen = origen)

  if (!is.null(tipo)) {
    tipos_validos <- c("categorica", "numerica", "texto")
    desconocidos <- setdiff(tolower(tipo), tipos_validos)
    if (length(desconocidos) > 0) {
      cli::cli_abort(c(
        "Tipo no reconocido: {.val {desconocidos}}",
        "i" = "Valores v\u00e1lidos: {.val {tipos_validos}}."
      ))
    }
    meta <- meta[tolower(meta$tipo) %in% tolower(tipo), ]
  }

  if (nrow(meta) == 0) {
    cli::cli_inform("No hay variables con esos criterios en el censo {anio}.")
    return(character(0))
  }

  # Avisar si el resultado mezcla tablas: es el error más probable al usarlo con
  # las funciones get_*(), que solo leen una tabla.
  if (is.null(tabla) && length(unique(meta$tabla)) > 1) {
    reparto <- table(meta$tabla)
    detalle <- paste(sprintf("%d en %s", reparto, names(reparto)), collapse = ", ")
    cli::cli_inform(c(
      "i" = "{.val {tema}} abarca varias tablas ({detalle}).",
      " " = "Usa {.arg tabla} para quedarte con una sola."
    ))
  }

  # Orden de cuestionario: primero las preguntas directas por capítulo y número,
  # y al final lo que el INE construyó o añadió. Se ordena por `origen` y no por
  # `is.na(pregunta_num)` porque algunas derivadas conservan el número de la
  # pregunta de la que salen (p41a_nivel_act, ocu_1d_13) y aun así deben ir
  # después de las preguntas.
  cap <- if ("capitulo" %in% names(meta)) meta$capitulo else rep(NA_character_, nrow(meta))
  meta <- meta[order(meta$origen != "cuestionario", cap, meta$pregunta_num,
                     meta$variable, na.last = TRUE), ]

  unique(meta$variable)
}

#' Definición, universo y pregunta literal de una variable
#'
#' Accesor de [codebook_docs_meta]: los textos oficiales del INE sobre una
#' variable. Útil para resolver qué mide exactamente, a quién se le preguntó, o
#' cómo se construyó una variable derivada.
#'
#' @param variable Caracteres. Nombre(s) de variable.
#' @param tabla Caracteres. Desambigua cuando la variable existe en varias tablas.
#' @param campos Caracteres. Devuelve solo estas columnas de documentación
#'   (e.g. `"definicion"`, `"pregunta_literal"`, `"regla_derivacion"`).
#' @param anio Entero. Censo o censos: `2024` (defecto), `2012`, `2001`, `1992` o
#'   `1976`. Acepta varios, que es la forma de comparar cómo cambió una definición
#'   entre censos.
#'
#' @return Un data.frame con una fila por variable y año encontrados.
#'
#' @seealso [codebook()] para las etiquetas y categorías, y [codebook_valores()]
#'   para los códigos de una variable categórica.
#'
#' @export
#' @examples
#' # ¿Qué mide exactamente y a quién se le preguntó?
#' codebook_docs("p40_lee", campos = c("definicion", "universo_literal"))
#'
#' # ¿Cómo construyó el INE esta variable derivada?
#' codebook_docs("nivel_edu", campos = "regla_derivacion")
codebook_docs <- function(variable, tabla = NULL, campos = NULL, anio = 2024) {
  anio <- as.integer(anio)
  desconocidos <- setdiff(anio, .ANIOS_CON_TAXONOMIA)
  if (length(desconocidos) > 0) {
    disponibles <- .ANIOS_CON_TAXONOMIA
    cli::cli_abort(c(
      "No hay documentaci\u00f3n del ANDA para el censo {.val {desconocidos}}.",
      "i" = "Disponible en {.val {disponibles}}."
    ))
  }

  docs <- codebook_docs_meta[codebook_docs_meta$anio %in% anio, ]
  docs <- docs[tolower(docs$variable) %in% tolower(variable), ]
  if (!is.null(tabla)) {
    docs <- docs[tolower(docs$tabla) %in% tolower(tabla), ]
  } else if (length(unique(docs$tabla)) > 1) {
    cli::cli_inform(c(
      "i" = "La variable existe en varias tablas ({.val {unique(docs$tabla)}}); se devuelven todas.",
      " " = "Usa {.arg tabla} para quedarte con una."
    ))
  }

  if (nrow(docs) == 0) {
    cli::cli_inform(c(
      "Sin documentaci\u00f3n para {.var {variable}} en {.val {anio}}.",
      "i" = "El ANDA no documenta todas las variables; prueba {.code codebook({.str {variable}})}."
    ))
    return(invisible(docs))
  }

  if (!is.null(campos)) {
    fijas <- c("anio", "variable", "tabla")
    validos <- setdiff(names(codebook_docs_meta), c(fijas, "variable_ddi"))
    desconocidos <- setdiff(campos, validos)
    if (length(desconocidos) > 0) {
      cli::cli_abort(c(
        "Campo de documentaci\u00f3n no reconocido: {.val {desconocidos}}",
        "i" = "Campos disponibles: {.val {validos}}."
      ))
    }
    docs <- docs[, c(fijas, campos), drop = FALSE]
  }
  rownames(docs) <- NULL
  docs
}

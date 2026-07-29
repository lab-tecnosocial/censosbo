## Lector de los DDI/XML del ANDA (INE Bolivia).
##
## Este archivo NO tiene efectos secundarios: solo define funciones. Lo usan
## `data-raw/add_taxonomia_to_codebook.R` y
## `data-raw/taxonomia/semilla_variable_tema.R`.
##
## Un solo lector sirve para los 3 estudios (132/2024, 8/2012, 10/2001): mismo
## namespace, misma estructura //var. Lo que cambia entre años es la cobertura de
## cada elemento y el vocabulario de `universe`, resuelto por los normalizadores.
##
## GOTCHA CENTRAL: el namespace del DDI es `http://www.icpsr.umich.edu/DDI`, no
## `ddi:codebook:2_5`. Sin xml_ns_strip() cualquier XPath devuelve 0 nodos.

library(xml2)

DDI_DIR <- "data-raw/ddi"

# fileDscr/@ID -> nombre de tabla del paquete. Se VERIFICA en cada corrida
# contra el fileName del XML (ver .verificar_file_map): si el INE republica con
# otros IDs, abortamos en vez de mezclar tablas silenciosamente, que es el fallo
# más peligroso de todo el pipeline.
DDI_FILE_MAP <- list(
  `2024` = c(F15 = "persona", F10 = "vivienda", F14 = "mortalidad", F12 = "emigracion"),
  `2012` = c(F1 = "persona", F2 = "vivienda", F6 = "emigracion",
             F7 = "mortalidad", F8 = "discapacidad"),
  `2001` = c(F1 = "persona", F2 = "vivienda"),
  `1992` = c(F1 = "persona", F2 = "vivienda"),
  # En 1976 la tabla de personas se llama `poblacion` en el paquete, no `persona`.
  `1976` = c(F1 = "poblacion", F2 = "vivienda")
)

# Fragmento del fileName que debe aparecer para aceptar el mapeo de arriba.
DDI_FILE_CHECK <- list(
  `2024` = c(F15 = "PERSONA", F10 = "VIVIENDA", F14 = "MORTALIDAD", F12 = "EMIGRACION"),
  `2012` = c(F1 = "Poblacion", F2 = "Vivienda", F6 = "Emigraci",
             F7 = "Mortalidad", F8 = "Discapacidad"),
  `2001` = c(F1 = "Poblaci", F2 = "Vivienda"),
  `1992` = c(F1 = "POBLACION1992", F2 = "VIVIENDA1992"),
  `1976` = c(F1 = "BOLPOB1976", F2 = "BOLIVIV1976")
)

# Colapsa whitespace: los textos del DDI vienen con saltos de línea e
# indentación del pretty-print del XML.
.limpiar <- function(x) {
  x <- gsub("[[:space:]]+", " ", x)
  x <- trimws(x)
  x[x == ""] <- NA_character_
  x
}

# Devuelve NA_character_ en vez de fallar cuando el nodo no existe.
.g <- function(nodos, xpath) {
  .limpiar(vapply(nodos, function(n) {
    hit <- xml2::xml_find_first(n, xpath)
    if (inherits(hit, "xml_missing")) NA_character_ else xml2::xml_text(hit)
  }, character(1)))
}

.verificar_file_map <- function(x, anio) {
  key <- as.character(anio)
  esperado <- DDI_FILE_CHECK[[key]]
  fd <- xml2::xml_find_all(x, "//fileDscr")
  ids <- xml2::xml_attr(fd, "ID")
  nms <- .limpiar(xml2::xml_text(xml2::xml_find_first(fd, ".//fileName")))
  names(nms) <- ids

  faltan <- setdiff(names(esperado), ids)
  if (length(faltan) > 0) {
    stop(sprintf(
      "DDI %s: faltan los fileDscr %s. El INE cambió la estructura; revisa DDI_FILE_MAP.",
      anio, paste(faltan, collapse = ", ")
    ))
  }
  for (id in names(esperado)) {
    if (!grepl(esperado[[id]], nms[[id]], fixed = TRUE)) {
      stop(sprintf(
        "DDI %s: el fichero %s dice '%s' pero se esperaba que contuviera '%s'. Revisa DDI_FILE_MAP.",
        anio, id, nms[[id]], esperado[[id]]
      ))
    }
  }
  invisible(TRUE)
}

# Ruta del snapshot más reciente de un año, según MANIFEST.csv.
ddi_snapshot_de <- function(anio) {
  man <- utils::read.csv(file.path(DDI_DIR, "MANIFEST.csv"), stringsAsFactors = FALSE)
  fila <- man[man$anio == as.integer(anio), ]
  if (nrow(fila) == 0) {
    stop(sprintf("No hay snapshot DDI para %s. Corre data-raw/ddi/descargar_ddi.R", anio))
  }
  file.path(DDI_DIR, fila$archivo[which.max(as.Date(fila$fecha))])
}

#' Lee un DDI del ANDA y devuelve un data.frame de variables
#'
#' @param anio 2024, 2012 o 2001
#' @param path ruta al XML; por defecto el snapshot del MANIFEST
#' @return data.frame con una fila por //var y los metadatos crudos (sin
#'   normalizar). `tabla` ya viene traducida al vocabulario del paquete.
leer_ddi <- function(anio, path = ddi_snapshot_de(anio)) {
  key <- as.character(anio)
  if (is.null(DDI_FILE_MAP[[key]])) {
    stop(sprintf("No hay DDI del ANDA para el censo %s.", anio))
  }

  x <- xml2::read_xml(path)
  xml2::xml_ns_strip(x)
  .verificar_file_map(x, anio)

  vs <- xml2::xml_find_all(x, "//var")
  if (length(vs) == 0) {
    stop(sprintf("DDI %s: 0 nodos //var. ¿Se olvidó xml_ns_strip()?", anio))
  }

  file_id <- xml2::xml_attr(vs, "files")
  tabla <- unname(DDI_FILE_MAP[[key]][file_id])

  out <- data.frame(
    anio             = as.integer(anio),
    var_id           = xml2::xml_attr(vs, "ID"),
    variable_ddi     = xml2::xml_attr(vs, "name"),
    file_id          = file_id,
    tabla            = tabla,
    intrvl           = xml2::xml_attr(vs, "intrvl"),
    labl             = .g(vs, "./labl"),
    definicion       = .g(vs, "./txt"),
    universo_literal = .g(vs, "./universe[@clusion='I']"),
    pregunta_literal = .g(vs, "./qstn/qstnLit"),
    instruccion      = .g(vs, "./qstn/ivuInstr"),
    informante       = .g(vs, "./respUnit"),
    notas            = .g(vs, "./notes"),
    regla_derivacion = .g(vs, "./codInstr"),
    formato          = .g(vs, "./varFormat/@type"),
    stringsAsFactors = FALSE
  )

  # `universe` sin @clusion también aparece en algunos estudios.
  sin_univ <- is.na(out$universo_literal)
  if (any(sin_univ)) {
    out$universo_literal[sin_univ] <- .g(vs[sin_univ], "./universe")
  }

  if (anyNA(out$tabla)) {
    ids <- unique(out$file_id[is.na(out$tabla)])
    stop(sprintf("DDI %s: fileDscr sin mapear a tabla: %s",
                 anio, paste(ids, collapse = ", ")))
  }
  out
}

#' Lee las etiquetas de valor (catgry/catValu) de un DDI
#'
#' 2012 y 2001 las traen (312 y 277 categorías); 2024 no trae ninguna. Sirven
#' para completar los `valores_codigos` que open-redatam no recuperó.
#'
#' @return data.frame largo: anio, variable_ddi, tabla, codigo, etiqueta
leer_ddi_categorias <- function(anio, path = ddi_snapshot_de(anio)) {
  key <- as.character(anio)
  x <- xml2::read_xml(path)
  xml2::xml_ns_strip(x)

  vs <- xml2::xml_find_all(x, "//var")
  filas <- lapply(vs, function(v) {
    cats <- xml2::xml_find_all(v, "./catgry")
    if (length(cats) == 0) return(NULL)
    cod <- .limpiar(xml2::xml_text(xml2::xml_find_first(cats, "./catValu")))
    eti <- .limpiar(xml2::xml_text(xml2::xml_find_first(cats, "./labl")))
    keep <- !is.na(cod) & !is.na(eti)
    if (!any(keep)) return(NULL)
    data.frame(
      anio         = as.integer(anio),
      variable_ddi = xml2::xml_attr(v, "name"),
      tabla        = unname(DDI_FILE_MAP[[key]][xml2::xml_attr(v, "files")]),
      codigo       = cod[keep],
      etiqueta     = eti[keep],
      stringsAsFactors = FALSE
    )
  })
  filas <- filas[!vapply(filas, is.null, logical(1))]
  if (length(filas) == 0) {
    return(data.frame(anio = integer(), variable_ddi = character(),
                      tabla = character(), codigo = character(),
                      etiqueta = character(), stringsAsFactors = FALSE))
  }
  do.call(rbind, filas)
}

#' Lee los grupos de variables (varGrp) de un DDI
#'
#' 2001 tiene 9 grupos temáticos y 2012 tiene 2; 2024 no tiene ninguno. Es la
#' estructura oficial que esos años sí traen, y alimenta la columna `grupo_ine`.
#'
#' GOTCHA: varGrp/@var referencia var/@ID (V13, V93...), NO var/@name. Hace
#' falta el lookup ID -> name.
leer_ddi_grupos <- function(anio, path = ddi_snapshot_de(anio)) {
  x <- xml2::read_xml(path)
  xml2::xml_ns_strip(x)

  vs <- xml2::xml_find_all(x, "//var")
  id2name <- stats::setNames(xml2::xml_attr(vs, "name"), xml2::xml_attr(vs, "ID"))

  gs <- xml2::xml_find_all(x, "//varGrp")
  if (length(gs) == 0) {
    return(data.frame(anio = integer(), variable_ddi = character(),
                      grupo_ine = character(), stringsAsFactors = FALSE))
  }
  filas <- lapply(gs, function(g) {
    etiqueta <- .limpiar(xml2::xml_text(xml2::xml_find_first(g, "./labl")))
    if (is.na(etiqueta)) etiqueta <- .limpiar(xml2::xml_attr(g, "name"))
    ids <- strsplit(trimws(xml2::xml_attr(g, "var")), "[[:space:]]+")[[1]]
    ids <- ids[nzchar(ids)]
    if (length(ids) == 0) return(NULL)
    data.frame(
      anio         = as.integer(anio),
      variable_ddi = unname(id2name[ids]),
      grupo_ine    = etiqueta,
      stringsAsFactors = FALSE
    )
  })
  filas <- filas[!vapply(filas, is.null, logical(1))]
  out <- do.call(rbind, filas)
  out[!is.na(out$variable_ddi), ]
}

#' Topics del estudio (topcClas)
leer_ddi_topics <- function(anio, path = ddi_snapshot_de(anio)) {
  x <- xml2::read_xml(path)
  xml2::xml_ns_strip(x)
  unique(.limpiar(xml2::xml_text(xml2::xml_find_all(x, "//topcClas"))))
}

# ==============================================================================
# Normalizadores
# ==============================================================================

# Vocabulario controlado de `universo`. Los literales del DDI incluyen erratas
# ("Persibas de 12 años", "Todos las provincias") y varias redacciones del mismo
# universo, así que filtrar por texto libre sería inútil. El verbatim se conserva
# en codebook_docs_meta$universo_literal para que la normalización sea auditable.
UNIVERSO_VOCAB <- c(
  "todas_personas", "personas_4_mas", "personas_5_mas", "personas_6_mas",
  "personas_7_mas", "personas_12_mas", "personas_15_mas", "personas_19_mas",
  "mujeres_12_mas", "mujeres_15_49",
  "todas_viviendas", "viviendas_particulares", "viviendas_presentes", "hogares",
  "personas_emigrantes", "personas_fallecidas",
  # Niveles de la jerarquía geográfica de REDATAM. Los censos de 1976 y 1992
  # declaran universos para cada uno de sus niveles, que son más que los actuales.
  "departamentos", "provincias", "secciones", "localidades", "cantones",
  "ciudades", "distritos", "zonas", "manzanas", "sectores", "segmentos", "areas"
)

# Tabla de equivalencias LITERAL y EXHAUSTIVA (no regex): si el INE republica un
# DDI con un universo nuevo, normalizar_universo() aborta en vez de asignarlo mal.
UNIVERSO_MAP <- c(
  # --- 2024 (24 literales) ---
  "Mujeres de 12 años o más de edad."                                = "mujeres_12_mas",
  "Todas las mujeres de 12 años o más."                              = "mujeres_12_mas",
  "Persibas de 12 años o más de edad."                               = "personas_12_mas",  # errata del INE
  "Mujeres de 15 a 49 años de edad."                                 = "mujeres_15_49",
  "Mujeres de 15 a 49 años de edad. No incluye a la población de mujeres que residen habitualmente en el exterior y/o las que no declararon hijas(os) ni declararon la pregunta." = "mujeres_15_49",
  "Todas las personas."                                              = "todas_personas",
  "Para todas las personas. No incluye a la población que reside habitualmente en el exterior y no declararon en la(s) pregunta(s)." = "todas_personas",
  "Todas las personas. No incluye a la población que reside habitualmente en el exterior y no declararon en la pregunta 31." = "todas_personas",
  "Personas de 5 años o más de edad."                                = "personas_5_mas",
  "Solo para personas de 5 años o más de edad."                      = "personas_5_mas",
  "Personas de 5 años o más de edad. No incluye a la población que reside habitualmente en el exterior y no declararon en la pregunta 42." = "personas_5_mas",
  "Personas de 7 años o más de edad."                                = "personas_7_mas",
  "Solo para personas de 7 años o más."                              = "personas_7_mas",
  "Solo para personas de 7 años o más de edad."                      = "personas_7_mas",
  "Personas de 7 años o más de edad. No incluye a la población que reside habitualmente en el exterior y no declararon en las preguntas de condición de actividad." = "personas_7_mas",
  "Solo para personas de 7 años o más No incluye a las personas que residen habitualmente en el exterior y que no declararon en las preguntas de residencia habitual ni condición de actividad" = "personas_7_mas",
  "Solo para personas de 7 años o más. No incluye a las personas que residen habitualmente en el exterior y que no declararon en las preguntas de residencia habitual ni condición de actividad." = "personas_7_mas",
  "Personas de 19 años o más de edad. No incluye a la población que reside habitualmente en el exterior y no declararon en la(s) pregunta(s)." = "personas_19_mas",
  "Personas que vivian en el hogar, pero que actualmente viven en otro país de forma temporal o permanente." = "personas_emigrantes",
  "Todas las personas que actualmente viven en otro país de forma temporal o permanente que antes vivían en el territorio nacional en viviendas particulares con personas presentes." = "personas_emigrantes",
  "Todas las personas fallecidas entre los años 2019 y 2024 que vivían en viviendas particulares con personas presentes" = "personas_fallecidas",
  "Todas las viviendas de Bolivia."                                  = "todas_viviendas",
  "Todas las viviendas particulares de Bolivia."                     = "viviendas_particulares",
  "Todas las viviendas particulares con personas presentes."         = "viviendas_presentes",

  # --- 2012 (9 literales; ojo a las erratas de concordancia del INE) ---
  "El hogar"                                                         = "hogares",
  "Todos los hogares de Bolivia"                                     = "hogares",
  "Las viviendas de Bolivia"                                         = "todas_viviendas",
  "Viviendas"                                                        = "todas_viviendas",
  "Los miembros del hogar"                                           = "todas_personas",
  "Todos los miembros del hogar"                                     = "todas_personas",
  "Todos los departamentos de Bolivia"                               = "departamentos",
  "Todos las provincias de Bolivia"                                  = "provincias",       # errata del INE
  "Todos las secciones de Bolivia"                                   = "secciones",        # errata del INE

  # --- 2001 (11 literales; el único año con filtros de edad reales) ---
  "Para personas de 4 años o más de edad."                           = "personas_4_mas",
  "Para personas de 7 años o más de edad."                           = "personas_7_mas",
  "Personas de 15 años o más de edad."                               = "personas_15_mas",
  "Todos los hogares"                                                = "hogares",
  "Todas las provincias de Bolivia"                                  = "provincias",
  "Todas las secciones municipales de Bolivia"                       = "secciones",
  "Todas las localidades de Bolivia"                                  = "localidades",
  "Todas las viviendas particulares y colectivas que se encuentran en el país." = "todas_viviendas",
  "Todas las viviendas particulares, ocupadas, con habitantes presentes, que existen en el país." = "viviendas_presentes",

  # --- 1992 (18 literales) ---
  "Para personas de 5 años y más de edad."                           = "personas_5_mas",
  "Para personas de 6 años y más de edad."                           = "personas_6_mas",
  "Para personas de 7 años y más de edad."                           = "personas_7_mas",
  "Para mujeres de 12 años y más de edad."                           = "mujeres_12_mas",
  "Todas las personas miembros del hogar empadronado. El hogar es una unidad conformada por personas con relación de parentesco o sin él, que habitan una misma vivienda y que al menos para su alimentación dependen de un fondo común al que las personas aportan en dinero y/o especie. Una persona sola también constituye un hogar." = "todas_personas",
  "Todos los hogares"                                                = "hogares",
  "Todos los hogares establecidos en las viviendas empadronadas (particulares y colectivas)." = "hogares",
  "Todos los departamentos de Bolivia."                              = "departamentos",
  "Todas las provincias de Bolivia."                                 = "provincias",
  "Todas las secciones de Bolivia."                                  = "secciones",
  "Todos los cantones de Bolivia."                                   = "cantones",
  "Todas las ciudades de Bolivia."                                   = "ciudades",
  "Todos los distritos de Bolivia."                                  = "distritos",
  "Todas las zonas censales de Bolivia."                             = "zonas",
  "Todos las manzanas de Bolivia."                                   = "manzanas",   # errata del INE
  "Todos los sectores de Bolivia."                                   = "sectores",
  "Todos los segmentos de Bolivia."                                  = "segmentos",

  # --- 1976 (16 literales) ---
  "Persomas de 5 años y más edad"                                   = "personas_5_mas",  # errata del INE
  "Personas de 7 años y más edad"                                   = "personas_7_mas",
  "Personas de 12 años y más edad"                                  = "personas_12_mas",
  "Mujeres de 12 años y más de edad"                                = "mujeres_12_mas",
  "Todas las personas en el territorio nacional, que pasaron la noche anterior al día del censo." = "todas_personas",
  "Los integrantes del hogar"                                        = "todas_personas",
  "Las viviendas"                                                    = "todas_viviendas",
  "Todas los hogares que se realizó el censo."                       = "hogares",         # errata del INE
  "Todos los departamentos de la República de Bolivia"               = "departamentos",
  "Todas las provincias del territorio nacional (República de Bolivia)." = "provincias",
  "Todos los cantones de las provincias de la república de Bolivia." = "cantones",
  "Todas las ciudades de la república de Bolivia"                    = "ciudades",
  "Todas las Zonas abarcadas por el censo."                          = "zonas",
  "Todas las manzanas enmarcadas en las zonas de censo."             = "manzanas",
  "Todas las areas abarcadas por el censo."                          = "areas",
  "Todas las áreas geográficas abarcadas por el censo."              = "areas"
)

#' Normaliza el universo literal del DDI al vocabulario controlado
#'
#' Aborta ante un literal desconocido: preferimos enterarnos de que el INE
#' cambió el metadato antes que asignar un universo equivocado en silencio.
normalizar_universo <- function(x) {
  faltan <- setdiff(unique(na.omit(x)), names(UNIVERSO_MAP))
  if (length(faltan) > 0) {
    stop(sprintf(
      "Universo(s) del DDI sin mapear en UNIVERSO_MAP:\n  - %s",
      paste(faltan, collapse = "\n  - ")
    ))
  }
  out <- unname(UNIVERSO_MAP[x])
  out[is.na(x)] <- NA_character_
  out
}

# El `respUnit` del DDI mezcla quién responde con notas metodológicas sueltas.
# Se reduce a 4 categorías; lo que no es un informante queda NA (el verbatim
# sigue en codebook_docs_meta$informante).
INFORMANTE_VOCAB <- c("jefe_hogar", "persona_misma", "empadronador", "observacion")

normalizar_informante <- function(x) {
  # Reglas en orden de prioridad: la primera que coincide gana. Se evalúan sobre
  # el vector completo (nada de indexar `x[pend]`, que descoloca las posiciones).
  reglas <- list(
    observacion   = "por observaci",
    empadronador  = "empadronad|encuestador",
    jefe_hogar    = "jefa|jefe",
    persona_misma = "^-?[[:space:]]*(todas las )?(personas|mujeres)"
  )
  out <- rep(NA_character_, length(x))
  for (cat in names(reglas)) {
    hit <- is.na(out) & !is.na(x) & grepl(reglas[[cat]], x, ignore.case = TRUE)
    out[hit] <- cat
  }
  out
}

#' Extrae el identificador de pregunta del `labl` del DDI
#'
#' Formatos observados: "24. ...", "30.A. ...", "33.1. ...", "35.2.A. ...",
#' "42.A ..." (sin punto final) en 2024; "1. ..." y "17.A. ..." en 2012. En 2001
#' ningún labl va numerado (el texto real está en qstnLit), así que devuelve NA.
#'
#' @return list(pregunta = chr, pregunta_num = int)
parsear_pregunta <- function(labl) {
  # Solo cuenta como pregunta si tras el número viene un separador (". " o " "),
  # para no capturar etiquetas que empiecen por un año o una cifra suelta. El
  # segmento tras cada punto se limita a 1-2 dígitos o una letra suelta, porque
  # si no "26.inscrición al registro civil" (2012, sin espacio tras el punto) se
  # tragaría la palabra entera como parte del identificador.
  SEG <- "(\\.([0-9]{1,2}|[A-Za-z][0-9]?))*"
  RE <- paste0("^[0-9]{1,2}[A-Za-z]?", SEG)
  sep_ok <- !is.na(labl) & grepl(paste0(RE, "[.[:space:]]"), labl)

  pregunta <- rep(NA_character_, length(labl))
  crudo <- regmatches(labl[sep_ok], regexpr(RE, labl[sep_ok]))
  pregunta[sep_ok] <- toupper(sub("\\.$", "", crudo))

  num <- suppressWarnings(as.integer(sub("[^0-9].*$", "", pregunta)))
  list(pregunta = pregunta, pregunta_num = num)
}

#' Deriva el identificador de pregunta del NOMBRE de la variable
#'
#' Los nombres son mucho más regulares que los `labl`, y son la única fuente en
#' 2001 (donde ningún `labl` va numerado) y en las tablas
#' emigracion/mortalidad/discapacidad de 2012 (cuyos `labl` son "Sexo", "Edad").
#'
#' Patrones, con ejemplos reales:
#'   p24_parentes -> 24     p30a_public -> 30.A    p331_idiohab1_cod -> 33.1
#'   v18a_bici    -> 18.A   e203_sexo   -> 20.3    m212a_mes         -> 21.2A
#'   P20E_SEXO    -> 20.E   P22F1_VER   -> 22.F1   p28 (2001)        -> 28
#'   v04 (2001)   -> 4      p39niv      -> 39      v201              -> 20.1
pregunta_desde_nombre <- function(variable) {
  v <- tolower(variable)
  out <- rep(NA_character_, length(v))

  # e/m del CPV-2024 comprimen el número de pregunta y la subpregunta sin
  # separador: e203 = pregunta 20, subpregunta 3; m212a = 21, 2A.
  em <- grepl("^[em][0-9]{3}[a-z]?_", v)
  if (any(em)) {
    cap <- regmatches(v[em], regexpr("^[em]([0-9]{3})([a-z]?)", v[em]))
    dig <- sub("^[em]([0-9]{3})([a-z]?)$", "\\1", cap)
    suf <- sub("^[em]([0-9]{3})([a-z]?)$", "\\2", cap)
    out[em] <- paste0(substr(dig, 1, 2), ".", substr(dig, 3, 3),
                      ifelse(nzchar(suf), toupper(suf), ""))
  }

  # p/v con underscore: 2024 y 2012.
  RE_U <- "^[pv]([0-9]{1,2})([a-z][0-9]*)?_"
  con_u <- is.na(out) & grepl(RE_U, v)
  if (any(con_u)) {
    cap <- regmatches(v[con_u], regexpr(RE_U, v[con_u]))
    base <- sub(RE_U, "\\1", cap)
    suf  <- sub(RE_U, "\\2", cap)
    out[con_u] <- ifelse(nzchar(suf), paste0(base, ".", toupper(suf)), base)
  }

  # p/v sin underscore: 2001 (p28, v04, p39niv, p321, v201, p53m). También cubre
  # los nombres cuyo stem ya es un identificador completo de subpregunta y el
  # sufijo tras el "_" es solo un mnemónico (V172B2_EDADMUJ2 -> 17).
  RE_S <- "^[pv]([0-9]{1,2})([a-z0-9]*)$"
  v <- ifelse(is.na(out) & !grepl(RE_S, v) & grepl("_", v), sub("_.*$", "", v), v)
  sin_u <- is.na(out) & grepl(RE_S, v)
  if (any(sin_u)) {
    base <- sub(RE_S, "\\1", v[sin_u])
    suf  <- sub(RE_S, "\\2", v[sin_u])
    # Un sufijo puramente numérico es una subpregunta (p321 -> 32.1); uno
    # alfabético puede ser subpregunta (p53m -> 53.M) o un mnemónico de la misma
    # pregunta (p39niv -> 39), así que solo se conserva si es una letra sola.
    sufijo <- ifelse(grepl("^[0-9]+$", suf) | grepl("^[a-z]$", suf), toupper(suf), "")
    out[sin_u] <- ifelse(nzchar(sufijo), paste0(base, ".", sufijo), base)
  }

  out
}

#' Combina las dos fuentes de `pregunta`: primero el labl, luego el nombre
#'
#' El `labl` es la fuente canónica cuando existe (es el texto del INE). El nombre
#' rellena lo que el labl no numera, que es casi todo en 2001.
resolver_pregunta <- function(labl, variable) {
  pregunta <- parsear_pregunta(labl)$pregunta
  desde_nombre <- pregunta_desde_nombre(variable)
  pregunta[is.na(pregunta)] <- desde_nombre[is.na(pregunta)]
  num <- suppressWarnings(as.integer(sub("[^0-9].*$", "", pregunta)))
  list(pregunta = pregunta, pregunta_num = num)
}

# ==============================================================================
# origen
# ==============================================================================

ORIGEN_VOCAB <- c("cuestionario", "derivada", "geografia", "indicador", "identificador")

# Identificadores de registro: folios, ids de boleta, números de orden. No son
# preguntas ni tienen universo analítico.
ORIGEN_IDENTIFICADOR <- c(
  "i00", "i00_folio", "folio", "i_bc_viv", "i21_nroviv", "ref_id",
  "id_bc_pers", "id_bc_emig", "id_bc_disc", "id_bc_mort",
  "p23_nuevo_nroper", "p20a_nro", "p21a_nro", "p22a_nro",
  "codigo", "nombre", "ficha",
  # 1992 y 1976: número de vivienda, de hogar y de boleta censal.
  "i10", "i13", "i10p", "i13p",
  # Número de orden de la persona dentro del hogar (1976 y 1992).
  "p00"
)

# Claves geográficas y de área. Incluye tanto los nombres del DDI como los que
# open-redatam produce en los codebooks históricos.
ORIGEN_GEOGRAFIA <- c(
  "idep", "iprov", "imun", "area", "urbrur", "turur",
  "i01_depto", "i02_depto", "i03_prov", "i04_secc", "prov", "mun",
  # Claves REDATAM de las entidades geográficas (tablas depto/provin/munic de
  # los censos históricos), donde el id va suelto sin sufijo descriptivo.
  "i01", "i02", "i03", "i04",
  "ipro", "isec", "iloc",
  "ndepto", "cod_depto", "nprov", "nmun", "nmunic", "redcoden",
  # 1976 y 1992 desagregan la geografía en más niveles que los censos actuales:
  # cantón, ciudad, distrito, zona, sector, segmento y manzana.
  "dep", "pro", "can", "ciu", "zona", "zon", "turrur", "turur",
  "ican", "iciu", "idis", "izon", "isect", "iseg", "imaz",
  "i12", "i02_prov", "ise_seccion",
  # 1976: la manzana censal va como v00 en la tabla de vivienda.
  "v00"
)

# Las 45 derivadas del CPV-2024 traen <codInstr> en el DDI, así que se detectan
# solas. Estas son las que NO lo traen y hay que declarar a mano.
ORIGEN_DERIVADA_EXTRA <- c(
  "tot_pers", "tip_hog", "v19e_f", "v19h_d",          # 2024, tabla vivienda
  "pea", "pet", "pei",                                 # 2012, derivadas REDATAM
  "totp", "toth", "totm", "eshogar",                   # 2001, derivadas REDATAM
  "totpers_viv", "tot_hombres_viv", "tot_mujeres_viv", # 2012, totales de vivienda
  # 1976: totales que REDATAM calcula por vivienda (personas y hogares).
  "i10v", "i13v",
  # 1992: categoría de la vivienda, sin pregunta asociada en el DDI.
  "i122"
)

#' Deriva el `origen` de una variable
#'
#' Prioridad: identificador > geografia > derivada > cuestionario. Lo que no
#' encaja en ninguna queda como "cuestionario" si tiene número de pregunta, y si
#' no, se marca NA para que el CSV curado lo resuelva explícitamente.
#'
#' Nota sobre `pregunta` y `origen`: dos derivadas del CPV-2024 (`ocu_1d_13` y
#' `act_eco_2d_13`) traen `codInstr` Y el número de la pregunta de la que
#' derivan (49 y 51) porque el INE reutiliza el texto de la pregunta base en el
#' `labl`. Gana `origen = "derivada"`, pero se conserva el número: saber de qué
#' pregunta sale una derivada es información útil. Por eso la relación entre
#' ambas columnas es una implicación en un solo sentido —
#' `origen == "cuestionario"` implica tener `pregunta`, no al revés.
derivar_origen <- function(variable, labl, regla_derivacion, pregunta = NULL) {
  v <- tolower(variable)
  out <- rep(NA_character_, length(v))

  out[v %in% ORIGEN_IDENTIFICADOR] <- "identificador"
  out[is.na(out) & v %in% ORIGEN_GEOGRAFIA] <- "geografia"
  out[is.na(out) & !is.na(regla_derivacion)] <- "derivada"
  out[is.na(out) & v %in% ORIGEN_DERIVADA_EXTRA] <- "derivada"

  # Con número de pregunta en el labl, es del cuestionario.
  if (is.null(pregunta)) pregunta <- parsear_pregunta(labl)$pregunta
  out[is.na(out) & !is.na(pregunta)] <- "cuestionario"

  out
}

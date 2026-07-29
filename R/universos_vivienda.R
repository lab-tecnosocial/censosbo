# ===========================================================================
# Universo de vivienda: qué registros de la entidad `vivienda` son viviendas
# ===========================================================================
#
# La entidad `vivienda` de REDATAM no contiene solo viviendas. Su variable de
# tipo de vivienda incluye categorías que NO son unidades habitacionales, sino
# situaciones de las personas censadas fuera de una vivienda: «persona que vive
# en la calle» y «en tránsito» (terminal, aeropuerto, puerto). Esos registros
# existen porque a esas personas hay que colgarlas de algún registro de la
# entidad, pero el INE no las cuenta como viviendas en ningún tabulado.
#
# En el CPV-2024 la diferencia está comprobada al registro:
#
#   4.490.488  registros de la entidad (todos)
#     - 3.311  v01_tipoviv = 15, persona que vive en la calle
#     - 6.976  v01_tipoviv = 16, en tránsito
#   = 4.480.201  viviendas   <- total oficial del INE
#
# Y no solo en el total: agregando por municipio, restringir a los códigos 1-14
# reproduce las viviendas del geoportal en los 343 municipios (con el total
# crudo solo coincidían 20). Ver tests/testthat/test-reconciliacion-oficial.R.
#
# Cada censo nombra sus categorías de otra forma, así que la tabla mapea, por
# año: la variable de tipo de vivienda, los códigos de vivienda particular, los
# de vivienda colectiva y los que no son vivienda. 1976 no preguntó por calle ni
# tránsito, así que ahí `no_vivienda` está vacío y el universo oficial coincide
# con la entidad completa.
#
# `viviendas` se define por EXCLUSIÓN (todo menos `no_vivienda`) y no como la
# unión de particulares y colectivas, para no descartar en silencio los códigos
# que aparecen en los microdatos pero no en el diccionario del censo: el 88 de
# 1976 (287 registros) y el 0 de 1992 (27). Se listan en `sin_clasificar` para
# que tipos_vivienda() los muestre en vez de fingir que no existen.
.TIPO_VIVIENDA <- list(
  "1976" = list(var = "v01",         particulares = 11:17, colectivas = 21:27, no_vivienda = integer(), sin_clasificar = 88L),
  "1992" = list(var = "V01",         particulares = 1:6,   colectivas = 7:12,  no_vivienda = 13L,       sin_clasificar = 0L),
  "2001" = list(var = "V04",         particulares = 11:15, colectivas = 16:23, no_vivienda = 24L,       sin_clasificar = integer()),
  "2012" = list(var = "P01",         particulares = 1:5,   colectivas = 6L,    no_vivienda = 7:8,       sin_clasificar = integer()),
  "2024" = list(var = "v01_tipoviv", particulares = 1:6,   colectivas = 7:14,  no_vivienda = 15:16,     sin_clasificar = integer())
)

.UNIVERSOS_VIVIENDA <- c("viviendas", "particulares", "colectivas", "todos")

# Entorno interno para avisos que solo tienen sentido una vez por sesión.
.censosbo_avisos <- new.env(parent = emptyenv())

.aviso_una_vez <- function(clave, ...) {
  if (isTRUE(.censosbo_avisos[[clave]])) return(invisible(FALSE))
  assign(clave, TRUE, envir = .censosbo_avisos)
  cli::cli_inform(c(...))
  invisible(TRUE)
}

# Códigos a conservar para un universo y año dados. NULL = no filtrar.
.codigos_universo_vivienda <- function(anio, universo) {
  spec <- .TIPO_VIVIENDA[[as.character(anio)]]
  if (is.null(spec)) return(NULL)
  todos <- sort(unique(c(spec$particulares, spec$colectivas, spec$no_vivienda,
                         spec$sin_clasificar)))
  switch(
    universo,
    "todos"        = NULL,
    "viviendas"    = if (length(spec$no_vivienda) == 0) NULL else
                       setdiff(todos, spec$no_vivienda),
    "particulares" = spec$particulares,
    "colectivas"   = spec$colectivas
  )
}

# Aplica el universo de vivienda a un Dataset de arrow.
#
# `universo` ya viene validado por match.arg() en la función pública. Devuelve el
# dataset sin tocar cuando el universo es "todos" o cuando el censo no permite
# distinguir (1976 con `universo = "viviendas"`).
.filtrar_universo_vivienda <- function(ds, anio, universo, verbose = TRUE) {
  if (identical(universo, "todos")) return(ds)

  spec <- .TIPO_VIVIENDA[[as.character(anio)]]
  if (is.null(spec)) {
    cli::cli_abort(c(
      "No hay tabla de tipos de vivienda para el censo {.val {anio}}.",
      "i" = "Usa {.code universo = \"todos\"}."
    ))
  }
  codigos <- .codigos_universo_vivienda(anio, universo)
  if (is.null(codigos)) {
    # Solo pasa en 1976 con universo = "viviendas": no hubo categorías de calle
    # ni tránsito, así que la entidad completa ya es el universo oficial. Se sale
    # antes de exigir la columna, que en ese caso no hace falta.
    return(ds)
  }

  if (!spec$var %in% names(ds)) {
    cli::cli_abort(c(
      "La columna {.field {spec$var}} no est\u00e1 en el resultado, as\u00ed que no se puede aplicar {.arg universo}.",
      "i" = "A\u00f1ade {.val {spec$var}} a {.arg variables}, o usa {.code universo = \"todos\"}."
    ))
  }

  if (verbose && identical(universo, "viviendas")) {
    .aviso_una_vez(
      "universo_vivienda",
      "i" = "Universo {.val viviendas}: se excluyen los registros de personas en la calle o en tr\u00e1nsito, que el INE no cuenta como viviendas.",
      "i" = "Con {.code universo = \"todos\"} obtienes la entidad completa de REDATAM."
    )
  }

  dplyr::filter(ds, .data[[spec$var]] %in% !!codigos)
}

# Asegura que la columna de tipo de vivienda sobreviva a una selección explícita
# de `variables`: sin ella no se puede aplicar el universo. Devuelve `variables`
# sin tocar cuando es NULL (todas las columnas) o cuando no hace falta filtrar.
.con_columna_universo <- function(variables, anio, universo) {
  if (is.null(variables) || identical(universo, "todos")) return(variables)
  if (is.null(.codigos_universo_vivienda(anio, universo))) return(variables)
  spec <- .TIPO_VIVIENDA[[as.character(anio)]]
  if (is.null(spec)) return(variables)
  unique(c(variables, spec$var))
}

# Valida que `universo` solo se use donde tiene sentido: la tabla de vivienda.
.check_universo_tabla <- function(universo, tabla) {
  if (identical(universo, "todos")) return(invisible(TRUE))
  if (tabla %in% c("vivienda", "viviendas")) return(invisible(TRUE))
  cli::cli_abort(c(
    "{.arg universo} solo aplica a la tabla {.val vivienda}, no a {.val {tabla}}.",
    "i" = "Quita {.arg universo} o p\u00e1sale {.val todos}."
  ))
}

#' Tipos de vivienda de un censo y su grupo
#'
#' Devuelve los códigos de la variable de tipo de vivienda de un censo, con su
#' etiqueta y el grupo al que pertenecen. Sirve para auditar qué registros entran
#' y salen con cada valor de `universo` en [get_viviendas_2024()] y [get_censo()].
#'
#' @param anio Entero. Año del censo: `1976`, `1992`, `2001`, `2012` o `2024`.
#'
#' @return Un `data.frame` con las columnas:
#'   \describe{
#'     \item{`codigo`}{Código de la variable de tipo de vivienda.}
#'     \item{`etiqueta`}{Etiqueta del diccionario del censo.}
#'     \item{`grupo`}{`"particular"`, `"colectiva"`, `"no_vivienda"` (persona en
#'       la calle o en tránsito) o `"sin_clasificar"` (código que aparece en los
#'       microdatos pero no en el diccionario del censo).}
#'     \item{`en_universo_viviendas`}{`TRUE` si el registro cuenta como vivienda
#'       para el INE, es decir si `universo = "viviendas"` lo conserva.}
#'   }
#'
#' @details
#' El grupo `no_vivienda` es la razón de que la entidad `vivienda` de REDATAM
#' tenga más registros que el total oficial de viviendas: son personas censadas
#' fuera de una vivienda. En el CPV-2024 son 10.287 registros (3.311 en la calle
#' y 6.976 en tránsito) de 4.490.488, y descontarlos da los 4.480.201 del INE.
#'
#' El censo 1976 no tuvo categorías de calle ni tránsito: ahí ningún código es
#' `no_vivienda` y el universo oficial coincide con la entidad completa.
#'
#' Los códigos `sin_clasificar` (el 88 de 1976 y el 0 de 1992) **se conservan**
#' en `universo = "viviendas"`: no consta que sean calle ni tránsito, así que
#' descartarlos sería una decisión sin respaldo en el diccionario. Sí quedan fuera
#' de `"particulares"` y `"colectivas"`, que son selecciones positivas.
#'
#' @seealso [get_viviendas_2024()] y [get_censo()] para el argumento `universo`.
#'
#' @export
#' @examples
#' tipos_vivienda(2024)
#'
#' # Los códigos que no son vivienda en cada censo
#' for (a in c(1976, 1992, 2001, 2012, 2024)) {
#'   t <- tipos_vivienda(a)
#'   cat(a, ":", paste(t$etiqueta[t$grupo == "no_vivienda"], collapse = "; "), "\n")
#' }
tipos_vivienda <- function(anio = 2024) {
  anio <- as.integer(anio)
  spec <- .TIPO_VIVIENDA[[as.character(anio)]]
  if (is.null(spec)) {
    cli::cli_abort(c(
      "A\u00f1o de censo no reconocido: {.val {anio}}",
      "i" = "A\u00f1os disponibles: {.val {names(.TIPO_VIVIENDA)}}."
    ))
  }

  etiquetas <- .etiquetas_tipo_vivienda(anio, spec$var)
  codigos <- sort(unique(c(spec$particulares, spec$colectivas, spec$no_vivienda,
                           spec$sin_clasificar, as.integer(names(etiquetas)))))

  grupo <- ifelse(codigos %in% spec$no_vivienda, "no_vivienda",
           ifelse(codigos %in% spec$particulares, "particular",
           ifelse(codigos %in% spec$colectivas,   "colectiva", "sin_clasificar")))

  data.frame(
    codigo   = codigos,
    etiqueta = {
      i <- match(as.character(codigos), names(etiquetas))
      ifelse(is.na(i), "(sin etiqueta en el diccionario)", unname(etiquetas)[i])
    },
    grupo    = grupo,
    en_universo_viviendas = grupo != "no_vivienda",
    stringsAsFactors = FALSE
  )
}

# Etiquetas de la variable de tipo de vivienda, del codebook del año.
# Devuelve un vector con nombres = código; vacío si no se encuentran.
.etiquetas_tipo_vivienda <- function(anio, var) {
  cb <- .get_codebook_for_anio(as.integer(anio))
  if (is.null(cb)) return(stats::setNames(character(), character()))
  j <- which(toupper(cb$variable) == toupper(var) & cb$tabla == "vivienda")
  if (length(j) == 0) return(stats::setNames(character(), character()))

  vc <- cb$valores_codigos[[j[1]]]
  if (is.null(vc) || length(vc) == 0) return(stats::setNames(character(), character()))
  vc <- unlist(vc)
  cod <- vc[grepl("^codigo", names(vc))]
  eti <- vc[grepl("^etiqueta", names(vc))]
  n <- min(length(cod), length(eti))
  if (n == 0) return(stats::setNames(character(), character()))
  stats::setNames(as.character(eti[seq_len(n)]),
                  as.character(as.integer(cod[seq_len(n)])))
}

## Completa y contrasta `valores_codigos` con las etiquetas de valor del DDI.
##
## Los DDI de 2012 y 2001 traen `catgry`/`catValu` (312 y 277 categorías) que el
## de 2024 no tiene. Se usan para dos cosas DISTINTAS:
##
##   1. COMPLETAR los `valores_codigos` que hoy son NULL porque open-redatam no
##      los recuperó. Efecto directo: etiquetar_valores() empieza a funcionar en
##      variables donde hoy no hace nada.
##
##   2. CONTRASTAR, sin sobrescribir, los que ya existen. Las discrepancias van a
##      un reporte para revisión manual; el dato de REDATAM no se toca. Resolver
##      esas discrepancias es trabajo posterior: el entregable es el reporte.
##
## La promesa "nada preexistente se sobrescribe" está respaldada por el fixture
## dorado de tests/testthat/test-valores.R.

## Normaliza una etiqueta para comparar: minúsculas, sin acentos, sin puntuación,
## sin espacios redundantes. Sin esto el reporte se llenaría de ruido, porque
## REDATAM escribe en MAYÚSCULAS y el DDI en capitalización normal.
.norm_etiqueta <- function(x) {
  x <- tolower(trimws(as.character(x)))
  x <- iconv(x, to = "ASCII//TRANSLIT")
  x <- gsub("[^a-z0-9 ]", " ", x)
  trimws(gsub("[[:space:]]+", " ", x))
}

.norm_codigo <- function(x) {
  x <- trimws(as.character(x))
  # "01" y "1" son el mismo código; REDATAM y el DDI no siempre coinciden en el
  # relleno con ceros.
  ifelse(grepl("^[0-9]+$", x), as.character(as.integer(x)), x)
}

## Clasifica una discrepancia para que el reporte sea accionable en vez de una
## lista plana de 55 entradas. Las categorías, de peor a menos importante:
##
##   GRAVE          la mayoría de los códigos comunes tienen etiquetas que no se
##                  parecen en nada -> el DDI probablemente le pegó a esta
##                  variable las categorías de OTRA pregunta. Caso real: en 2012,
##                  P45_ESTADOCIVIL trae las categorías de condición de
##                  inactividad ("buscó trabajo", "estuvo estudiando") aunque su
##                  labl y su txt hablen de estado civil. Es un error del INE.
##   CODIFICACION   los dos catálogos describen lo mismo pero con códigos
##                  distintos (el DDI usa letras A-W y REDATAM números 1-23 para
##                  la CAEB). Usar las etiquetas del DDI con datos de REDATAM
##                  produciría un cruce silenciosamente equivocado.
##   CENTINELA      difieren solo en los códigos de no respuesta ("Sin
##                  especificar" vs "Ignorado") o falta uno de ellos.
##   REDACCION      truncamiento del DDI, tildes, "Sí" vs "Si". Ruido.
## Numerales escritos -> dígito. REDATAM escribe "UNO", "TRES Y MAS" donde el DDI
## pone "1", "3 o más": el mismo valor con otro formato, no una discrepancia.
.NUMERALES <- c(ninguno = "0", ninguna = "0", cero = "0", uno = "1", una = "1",
                dos = "2", tres = "3", cuatro = "4", cinco = "5", seis = "6",
                siete = "7", ocho = "8", nueve = "9", diez = "10")

.tokens <- function(x) {
  t <- strsplit(x, " ", fixed = TRUE)[[1]]
  t <- t[nzchar(t) & !t %in% c("de", "la", "el", "los", "las", "en", "y", "o",
                               "del", "al", "un", "una", "por", "con", "su")]
  t <- ifelse(t %in% names(.NUMERALES), unname(.NUMERALES[t]), t)
  # Stemming pobre pero suficiente: las abreviaciones de REDATAM recortan
  # palabras ("CAÑERIA" vs "cañería", "VIVIENDA" vs "vivienda").
  ifelse(nchar(t) > 4, substr(t, 1, 4), t)
}

## Similitud de Jaccard entre los tokens de dos etiquetas.
.jaccard <- function(a, b) {
  ta <- .tokens(a); tb <- .tokens(b)
  if (length(ta) == 0 || length(tb) == 0) return(0)
  length(intersect(ta, tb)) / length(union(ta, tb))
}

.severidad <- function(comunes, difieren, solo_redatam, solo_ddi,
                       a_eti, a_cod, d_eti, d_cod) {
  SENTINELA <- "sin especificar|sin dato|ignorado|no sabe|no responde|omisi|no corresponde|no aplica"

  if (length(comunes) > 0 && length(difieren) / length(comunes) > 0.5) {
    # Distinguir un desalineamiento real de categorías (el DDI le pegó a esta
    # variable las de otra pregunta) de la mera diferencia de redacción, que en
    # REDATAM significa MAYÚSCULAS y abreviaciones.
    ea <- a_eti[match(difieren, a_cod)]
    ed <- d_eti[match(difieren, d_cod)]
    sim <- vapply(seq_along(ea), function(k) .jaccard(ea[k], ed[k]), numeric(1))
    if (mean(sim) < 0.25) return("GRAVE")
  }
  # Códigos disjuntos y de naturaleza distinta (letras vs números).
  if (length(solo_ddi) > 2 && length(solo_redatam) > 2) {
    letras_ddi <- mean(grepl("^[A-Za-z]$", solo_ddi))
    num_red <- mean(grepl("^[0-9]+$", solo_redatam))
    if (letras_ddi > 0.5 && num_red > 0.5) return("CODIFICACION")
  }
  restantes <- c(solo_redatam, solo_ddi)
  if (length(restantes) > 0) {
    eti_rest <- c(a_eti[match(solo_redatam, a_cod)], d_eti[match(solo_ddi, d_cod)])
    if (all(grepl(SENTINELA, eti_rest))) return("CENTINELA")
  }
  if (length(difieren) > 0 && length(restantes) == 0) return("REDACCION")
  if (length(restantes) > 0) return("CODIGOS")
  "REDACCION"
}

#' Completa valores_codigos desde el DDI y produce un reporte de discrepancias
#'
#' @param historico la lista codebook_historico_meta
#' @return list(codebook, reporte, n_completadas, n_discrepancias)
completar_valores_codigos <- function(historico, anios = c(2012, 2001)) {
  lineas <- c(
    "# Contraste de `valores_codigos`: REDATAM vs DDI del ANDA",
    "",
    "Generado por `data-raw/taxonomia/completar_valores.R` (vía",
    "`add_taxonomia_to_codebook.R`). **No modifica ningún valor preexistente**:",
    "las variables que ya tenían códigos se comparan y se reportan aquí; solo se",
    "rellenan las que estaban vacías.",
    "",
    "Los códigos y etiquetas se comparan normalizados (minúsculas, sin acentos,",
    "sin puntuación, ceros a la izquierda irrelevantes), así que lo que aparece",
    "abajo son diferencias reales de contenido, no de formato.",
    "",
    "## Severidad",
    "",
    "- **GRAVE** — la mayoría de los códigos comunes tienen etiquetas que no se",
    "  parecen: el DDI probablemente le pegó a esa variable las categorías de otra",
    "  pregunta. Es un error del metadato del INE, no del paquete.",
    "- **CODIFICACION** — los dos catálogos describen lo mismo con códigos",
    "  distintos (el DDI usa letras y REDATAM números para la misma clasificación).",
    "  Usar las etiquetas del DDI sobre datos de REDATAM daría un cruce equivocado.",
    "- **CODIGOS** — a uno de los dos le faltan categorías que el otro sí tiene.",
    "- **CENTINELA** — difieren solo en los códigos de no respuesta.",
    "- **REDACCION** — truncamiento del DDI, tildes, «Sí» vs «Si». Ruido.",
    "",
    "## Por qué se completan tan pocas",
    "",
    "Las variables categóricas sin `valores_codigos` en 2012 y 2001 son, casi",
    "todas, claves geográficas (`idep`, `iprov`, `imun`) y códigos de",
    "clasificación ocupacional o de actividad económica. Ni unas ni otros llevan",
    "etiquetas de valor enumerables en el DDI: las geográficas se resuelven con",
    "`etiquetar_geografia()` y los códigos COB/CAEB son catálogos de cientos de",
    "entradas que el ANDA no publica. En la práctica, REDATAM ya trae todas las",
    "etiquetas de valor que existen, así que el aporte del DDI en este frente es",
    "marginal; su valor real está en `codebook_docs_meta` (definición, universo,",
    "pregunta literal e instrucciones al censista).",
    ""
  )
  n_completadas <- 0L
  n_discrepancias <- 0L

  for (anio in anios) {
    cb <- historico[[as.character(anio)]]
    if (is.null(cb)) next

    cats <- leer_ddi_categorias(anio)
    if (nrow(cats) == 0) next

    # Emparejar las categorías del DDI con las variables del codebook usando la
    # misma estrategia de join que el resto del pipeline.
    ddi <- leer_ddi(anio)
    k_ddi <- clave_ddi(ddi, anio)
    names(k_ddi) <- paste(ddi$tabla, ddi$variable_ddi)
    cats$clave <- unname(k_ddi[paste(cats$tabla, cats$variable_ddi)])
    cats <- cats[!is.na(cats$clave), ]

    k_cb <- clave_codebook(cb, anio)

    if (!"valores_fuente" %in% names(cb)) {
      cb$valores_fuente <- ifelse(
        vapply(cb$valores_codigos, function(v) !is.null(v) && NROW(v) > 0, logical(1)),
        "redatam", NA_character_
      )
    }

    lineas <- c(lineas, sprintf("## Censo %d", anio), "")
    completadas_anio <- character()
    disc_anio <- list()

    for (i in seq_len(nrow(cb))) {
      sub <- cats[cats$clave == k_cb[i], c("codigo", "etiqueta")]
      if (nrow(sub) == 0) next
      sub <- sub[!duplicated(.norm_codigo(sub$codigo)), ]
      rownames(sub) <- NULL

      actual <- cb$valores_codigos[[i]]
      vacio <- is.null(actual) || NROW(actual) == 0

      if (vacio) {
        # Solo tiene sentido dar etiquetas de valor a variables categóricas.
        if (!identical(cb$tipo[i], "categorica")) next
        cb$valores_codigos[[i]] <- sub
        cb$valores_fuente[i] <- "ddi"
        n_completadas <- n_completadas + 1L
        completadas_anio <- c(completadas_anio, sprintf(
          "- `%s` / %s — %d categorías (%s)", cb$variable[i], cb$tabla[i], nrow(sub),
          paste(utils::head(sub$etiqueta, 4), collapse = "; ")
        ))
        next
      }

      # Contraste sin tocar el dato.
      a_cod <- .norm_codigo(actual$codigo); a_eti <- .norm_etiqueta(actual$etiqueta)
      d_cod <- .norm_codigo(sub$codigo);    d_eti <- .norm_etiqueta(sub$etiqueta)

      solo_redatam <- setdiff(a_cod, d_cod)
      solo_ddi <- setdiff(d_cod, a_cod)
      comunes <- intersect(a_cod, d_cod)
      difieren <- comunes[a_eti[match(comunes, a_cod)] != d_eti[match(comunes, d_cod)]]

      if (length(solo_redatam) || length(solo_ddi) || length(difieren)) {
        n_discrepancias <- n_discrepancias + 1L
        sev <- .severidad(comunes, difieren, solo_redatam, solo_ddi,
                          a_eti, a_cod, d_eti, d_cod)
        det <- sprintf("### [%s] `%s` / %s — %s", sev, cb$variable[i], cb$tabla[i],
                       substr(cb$etiqueta[i], 1, 70))
        if (length(solo_ddi)) {
          det <- c(det, sprintf("- solo en el DDI: %s", paste(sprintf(
            "`%s` = %s", solo_ddi, sub$etiqueta[match(solo_ddi, d_cod)]), collapse = ", ")))
        }
        if (length(solo_redatam)) {
          det <- c(det, sprintf("- solo en REDATAM: %s", paste(sprintf(
            "`%s` = %s", solo_redatam, actual$etiqueta[match(solo_redatam, a_cod)]),
            collapse = ", ")))
        }
        if (length(difieren)) {
          det <- c(det, sprintf("- etiqueta distinta: %s", paste(sprintf(
            "`%s` REDATAM=\"%s\" vs DDI=\"%s\"", difieren,
            actual$etiqueta[match(difieren, a_cod)],
            sub$etiqueta[match(difieren, d_cod)]), collapse = "; ")))
        }
        disc_anio[[length(disc_anio) + 1L]] <- list(sev = sev, texto = c(det, ""))
      }
    }

    # Ordenar por severidad, para que lo accionable quede arriba.
    ORDEN_SEV <- c("GRAVE", "CODIFICACION", "CODIGOS", "CENTINELA", "REDACCION")
    if (length(disc_anio) > 0) {
      sevs <- vapply(disc_anio, function(d) d$sev, character(1))
      disc_anio <- disc_anio[order(match(sevs, ORDEN_SEV))]
      resumen <- paste(sprintf("%s: %d", names(table(sevs)[ORDEN_SEV[ORDEN_SEV %in% sevs]]),
                               table(sevs)[ORDEN_SEV[ORDEN_SEV %in% sevs]]), collapse = " · ")
      texto_disc <- unlist(lapply(disc_anio, function(d) d$texto))
    } else {
      resumen <- ""
      texto_disc <- "_ninguna: REDATAM y el DDI coinciden_"
    }

    lineas <- c(lineas,
      sprintf("### Completadas desde el DDI (%d)", length(completadas_anio)), "",
      if (length(completadas_anio)) completadas_anio else "_ninguna_", "",
      sprintf("### Discrepancias en las que ya tenían códigos (%d)", length(disc_anio)), "",
      if (nzchar(resumen)) paste0("Severidad — ", resumen, ".") else "", "",
      texto_disc, ""
    )

    historico[[as.character(anio)]] <- cb
  }

  list(codebook = historico, reporte = lineas,
       n_completadas = n_completadas, n_discrepancias = n_discrepancias)
}

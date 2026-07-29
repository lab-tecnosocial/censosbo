## Une los metadatos del DDI del ANDA con el codebook del paquete.
##
## Cada año tiene su propia estrategia de emparejamiento, porque los nombres de
## variable del ANDA y los de open-redatam no coinciden igual en los tres:
##
##   2024  clave (tabla, tolower(variable)) directa. 180/181 filas; las únicas
##         discrepancias son `i00` en 4 tablas (solo DDI) y `persona area`
##         (solo codebook). Se assertean: cualquier otra diferencia aborta.
##   2001  toupper(). El DDI usa minúsculas (p28, v04) y el codebook mayúsculas.
##         68 de 85 nombres del DDI casan; el resto son texto abierto que REDATAM
##         sustituye por códigos.
##   2012  tabla de correspondencia manual (nombres_ddi_2012.csv), porque el DDI
##         usa nombre largo STEM_SUFIJO (P23_PARENTES) y el codebook solo el stem.
##         El join exacto es 0.
##
## Lo usan semilla_variable_tema.R y add_taxonomia_to_codebook.R.

## Discrepancias esperadas del join de 2024. Si aparece cualquier otra, es que el
## INE republicó el DDI o que el codebook cambió: abortamos en vez de seguir con
## un emparejamiento silenciosamente incompleto.
JOIN_2024_SOLO_DDI <- paste(c("persona", "vivienda", "mortalidad", "emigracion"), "i00")
JOIN_2024_SOLO_CB <- "persona area"

#' Clave de emparejamiento del codebook, por año
clave_codebook <- function(cb, anio) {
  if (as.integer(anio) == 2024L) {
    paste(cb$tabla, tolower(cb$variable))
  } else {
    paste(cb$tabla, toupper(cb$variable))
  }
}

#' Clave de emparejamiento del DDI, por año
#'
#' En 2012 pasa por la tabla de correspondencia manual; las filas del DDI sin par
#' reciben NA y por tanto no se unen a nada.
clave_ddi <- function(ddi, anio, tax_dir = "data-raw/taxonomia") {
  anio <- as.integer(anio)
  if (anio == 2024L) {
    paste(ddi$tabla, tolower(ddi$variable_ddi))
  } else if (anio %in% c(2001L, 1992L, 1976L)) {
    # Estos tres casan con solo normalizar la caja: el DDI usa minúsculas o
    # capitalización mixta y el codebook mayúsculas. 1976 casa 50/50 y 1992 86/102
    # (las 16 restantes son claves geográficas de REDATAM sin par).
    paste(ddi$tabla, toupper(ddi$variable_ddi))
  } else if (anio == 2012L) {
    corr <- utils::read.csv(file.path(tax_dir, "nombres_ddi_2012.csv"),
                            stringsAsFactors = FALSE, na.strings = c("", "NA"))
    v_cb <- corr$variable_cb[match(
      paste(ddi$tabla, ddi$variable_ddi), paste(corr$tabla, corr$variable_ddi)
    )]
    ifelse(is.na(v_cb), NA_character_, paste(ddi$tabla, toupper(v_cb)))
  } else {
    stop(sprintf("No hay estrategia de join DDI para el censo %d.", anio))
  }
}

#' DDI de un año con `universo`, `origen` y `pregunta` ya derivados
ddi_preparado <- function(anio) {
  d <- leer_ddi(anio)
  p <- resolver_pregunta(d$labl, d$variable_ddi)
  d$pregunta <- p$pregunta
  d$pregunta_num <- p$pregunta_num
  d$origen <- derivar_origen(d$variable_ddi, d$labl, d$regla_derivacion, d$pregunta)
  d$universo <- normalizar_universo(d$universo_literal)
  d$informante_norm <- normalizar_informante(d$informante)

  # grupo_ine: los varGrp del DDI (9 grupos en 2001, 2 en 2012, ninguno en 2024).
  gr <- leer_ddi_grupos(anio)
  if (nrow(gr) > 0) {
    # Una variable puede estar en más de un grupo; se colapsan separados por " | ".
    agg <- stats::aggregate(grupo_ine ~ variable_ddi, data = gr,
                            FUN = function(x) paste(unique(x), collapse = " | "))
    d$grupo_ine <- agg$grupo_ine[match(d$variable_ddi, agg$variable_ddi)]
  } else {
    d$grupo_ine <- NA_character_
  }
  d
}

#' Verifica las discrepancias del join de 2024 contra lo esperado
verificar_join_2024 <- function(cb_micro, ddi) {
  k_cb <- clave_codebook(cb_micro, 2024)
  k_ddi <- clave_ddi(ddi, 2024)

  solo_ddi <- sort(setdiff(k_ddi, k_cb))
  solo_cb <- sort(setdiff(k_cb, k_ddi))

  if (!identical(solo_ddi, sort(JOIN_2024_SOLO_DDI))) {
    stop("Join 2024: las variables solo en el DDI cambiaron.\n  esperado: ",
         paste(sort(JOIN_2024_SOLO_DDI), collapse = ", "),
         "\n  obtenido: ", paste(solo_ddi, collapse = ", "),
         "\nRevisa si el INE republicó el DDI o si cambió codebook_meta.", call. = FALSE)
  }
  if (!identical(solo_cb, sort(JOIN_2024_SOLO_CB))) {
    stop("Join 2024: las variables solo en el codebook cambiaron.\n  esperado: ",
         paste(sort(JOIN_2024_SOLO_CB), collapse = ", "),
         "\n  obtenido: ", paste(solo_cb, collapse = ", "), call. = FALSE)
  }
  invisible(TRUE)
}

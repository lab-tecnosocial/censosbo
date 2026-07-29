## Valida la taxonomía antes de escribirla a los .rda.
##
## Aborta ante cualquier inconsistencia: es preferible romper el build a publicar
## un codebook con una variable sin tema o con un vocabulario abierto por error.
##
## Las comprobaciones estructurales se repiten en tests/testthat/test-temas.R
## sobre el dato ya instalado, para que un .rda desincronizado rompa CI y no solo
## el build local.
##
## No tiene efectos secundarios: define validar_taxonomia() y, si se ejecuta
## directamente, la corre sobre los CSV curados.

TAX_DIR <- "data-raw/taxonomia"

ANIOS_TAXONOMIA <- c(2024L, 2012L, 2001L, 1992L, 1976L)

# `capitulo` solo aplica al CPV-2024: los cuestionarios de 2012 y 2001 tienen
# otra estructura y 2001 no numera nada en sus etiquetas.
ANIO_CON_CAPITULO <- 2024L

validar_taxonomia <- function(mapas, temas, capitulos, bloques, verbose = TRUE) {
  problemas <- character()
  avisos <- character()
  falla <- function(...) problemas <<- c(problemas, sprintf(...))
  avisa <- function(...) avisos <<- c(avisos, sprintf(...))

  # --- 1. cobertura total: ninguna variable sin tema --------------------------
  for (anio in names(mapas)) {
    m <- mapas[[anio]]
    huerfanas <- m[is.na(m$tema), ]
    if (nrow(huerfanas) > 0) {
      falla("%s: %d variable(s) sin tema:\n%s", anio, nrow(huerfanas),
            paste(sprintf("    - %s / %s: %s", huerfanas$tabla, huerfanas$variable,
                          substr(huerfanas$etiqueta, 1, 60)), collapse = "\n"))
    }
  }

  # --- 2. biyección con temas.csv, en ambas direcciones ----------------------
  usados <- unique(unlist(lapply(mapas, function(m) na.omit(m$tema))))
  fantasma <- setdiff(usados, temas$tema)
  if (length(fantasma) > 0) {
    falla("tema(s) usados que no están en temas.csv: %s", paste(fantasma, collapse = ", "))
  }
  vacios <- setdiff(temas$tema, usados)
  if (length(vacios) > 0) {
    falla("tema(s) declarados en temas.csv que ninguna variable usa: %s",
          paste(vacios, collapse = ", "))
  }

  # --- 3. vocabularios cerrados ---------------------------------------------
  for (anio in names(mapas)) {
    m <- mapas[[anio]]
    mal_origen <- setdiff(na.omit(m$origen), ORIGEN_VOCAB)
    if (length(mal_origen) > 0) {
      falla("%s: origen fuera del vocabulario: %s", anio, paste(mal_origen, collapse = ", "))
    }
    if (anyNA(m$origen)) {
      falla("%s: %d variable(s) sin origen: %s", anio, sum(is.na(m$origen)),
            paste(m$variable[is.na(m$origen)], collapse = ", "))
    }
    mal_univ <- setdiff(na.omit(m$universo), UNIVERSO_VOCAB)
    if (length(mal_univ) > 0) {
      falla("%s: universo fuera del vocabulario: %s", anio, paste(mal_univ, collapse = ", "))
    }
    if ("capitulo" %in% names(m)) {
      mal_cap <- setdiff(na.omit(m$capitulo), capitulos$capitulo)
      if (length(mal_cap) > 0) {
        falla("%s: capitulo fuera de capitulos.csv: %s", anio, paste(mal_cap, collapse = ", "))
      }
    }
    if ("bloque" %in% names(m)) {
      mal_bl <- setdiff(na.omit(m$bloque), bloques$bloque)
      if (length(mal_bl) > 0) {
        falla("%s: bloque fuera de bloque_tema.csv: %s", anio, paste(mal_bl, collapse = ", "))
      }
    }
  }

  # --- 4. capitulo solo en 2024 --------------------------------------------
  for (anio in names(mapas)) {
    m <- mapas[[anio]]
    if (!"capitulo" %in% names(m)) next
    tiene <- sum(!is.na(m$capitulo))
    if (as.integer(anio) == ANIO_CON_CAPITULO) {
      if (tiene != nrow(m)) {
        falla("%s: %d variable(s) sin capitulo (en 2024 todas deben tenerlo)",
              anio, nrow(m) - tiene)
      }
    } else if (tiene > 0) {
      falla("%s: %d variable(s) con capitulo, pero los capítulos son solo del cuestionario 2024",
            anio, tiene)
    }
  }

  # --- 5. pregunta_num en rango, y coherente con origen --------------------
  for (anio in names(mapas)) {
    m <- mapas[[anio]]
    if (!"pregunta_num" %in% names(m)) next
    fuera <- !is.na(m$pregunta_num) & (m$pregunta_num < 1 | m$pregunta_num > 59)
    if (any(fuera)) {
      falla("%s: pregunta_num fuera de 1:59 en %s", anio,
            paste(m$variable[fuera], collapse = ", "))
    }
    # Implicación en un solo sentido: del cuestionario => tiene pregunta. No al
    # revés, porque dos derivadas del CPV-2024 conservan el número de la pregunta
    # de la que derivan (ocu_1d_13 -> 49, act_eco_2d_13 -> 51).
    sin_p <- m$origen == "cuestionario" & is.na(m$pregunta_num)
    if (any(sin_p, na.rm = TRUE)) {
      falla("%s: origen 'cuestionario' sin pregunta_num en %s", anio,
            paste(m$variable[which(sin_p)], collapse = ", "))
    }
  }

  # --- 6. denominador y bloque solo donde corresponde ----------------------
  m24 <- mapas[["2024"]]
  if (!is.null(m24) && "denominador" %in% names(m24)) {
    fuera <- !is.na(m24$denominador) & !m24$tabla %in% c("ficha", "unidad")
    if (any(fuera)) {
      falla("2024: denominador en tablas que no son ficha/unidad: %s",
            paste(m24$variable[fuera], collapse = ", "))
    }
    # Cada denominador debe apuntar a una variable existente de la misma tabla, o
    # ser una expresión (a + b) con ambos miembros existentes.
    den <- m24[!is.na(m24$denominador) & nzchar(m24$denominador), ]
    for (i in seq_len(nrow(den))) {
      d <- den$denominador[i]
      disponibles <- m24$variable[m24$tabla == den$tabla[i]]
      refs <- if (grepl("^\\(.*\\+.*\\)$", d)) {
        trimws(strsplit(gsub("[()]", "", d), "\\+")[[1]])
      } else d
      faltan <- setdiff(refs, disponibles)
      if (length(faltan) > 0) {
        falla("2024: %s tiene denominador '%s' que referencia variable(s) inexistente(s): %s",
              den$variable[i], d, paste(faltan, collapse = ", "))
      }
    }
  }
  if (!is.null(m24) && "bloque" %in% names(m24)) {
    fuera <- !is.na(m24$bloque) & !m24$tabla %in% c("ficha", "unidad")
    if (any(fuera)) {
      falla("2024: bloque en tablas que no son ficha/unidad: %s",
            paste(m24$variable[fuera], collapse = ", "))
    }
  }
  for (anio in setdiff(names(mapas), "2024")) {
    m <- mapas[[anio]]
    for (col in c("bloque", "denominador")) {
      if (col %in% names(m) && any(!is.na(m[[col]]))) {
        falla("%s: la columna %s solo aplica a los indicadores de ficha del CPV-2024",
              anio, col)
      }
    }
  }

  # --- 7. grupo_ine solo en 2012/2001 -------------------------------------
  for (anio in names(mapas)) {
    m <- mapas[[anio]]
    if (!"grupo_ine" %in% names(m)) next
    if (as.integer(anio) == 2024L && any(!is.na(m$grupo_ine))) {
      falla("2024: grupo_ine no debería existir (el DDI de 2024 no tiene varGrp)")
    }
  }

  # --- 8. aviso: ningún tema debería abarcar más de 2 capítulos -----------
  if (!is.null(m24) && "capitulo" %in% names(m24)) {
    por_tema <- tapply(m24$capitulo, m24$tema, function(x) length(unique(na.omit(x))))
    anchos <- names(por_tema)[por_tema > 2]
    if (length(anchos) > 0) {
      avisa("tema(s) que abarcan más de 2 capítulos (revisa si son un tema o dos): %s",
            paste(anchos, collapse = ", "))
    }
  }

  if (verbose) {
    for (a in avisos) message("! ", a)
  }
  if (length(problemas) > 0) {
    stop("La taxonomía no valida:\n", paste0("  - ", problemas, collapse = "\n"), call. = FALSE)
  }
  if (verbose) {
    message(sprintf("Taxonomía válida: %d años, %d variables, %d temas.",
                    length(mapas), sum(vapply(mapas, nrow, integer(1))), nrow(temas)))
  }
  invisible(TRUE)
}

# --- ejecución directa: valida los CSV curados -------------------------------
if (sys.nframe() == 0L) {
  source("data-raw/ddi/parse_ddi.R")
  temas <- utils::read.csv(file.path(TAX_DIR, "temas.csv"), stringsAsFactors = FALSE)
  capitulos <- utils::read.csv(file.path(TAX_DIR, "capitulos.csv"), stringsAsFactors = FALSE)
  bloques <- utils::read.csv(file.path(TAX_DIR, "bloque_tema.csv"),
                             stringsAsFactors = FALSE, na.strings = c("", "NA"))
  mapas <- lapply(ANIOS_TAXONOMIA, function(a) {
    utils::read.csv(file.path(TAX_DIR, sprintf("variable_tema_%d.csv", a)),
                    stringsAsFactors = FALSE, na.strings = c("", "NA"))
  })
  names(mapas) <- as.character(ANIOS_TAXONOMIA)
  # Los CSV curados no llevan capitulo/universo (los añade el patch al .rda);
  # aquí se valida lo que sí contienen.
  validar_taxonomia(mapas, temas, capitulos, bloques)
}

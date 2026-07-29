## Semi-genera el mapeo variable -> tema y lo compara con el CSV curado.
##
## La fuente de verdad son los `variable_tema_<anio>.csv`, curados a mano. Este
## script NUNCA los sobrescribe: escribe una propuesta aparte (gitignored) y
## reporta tres listas — filas nuevas, filas huérfanas y filas donde la regla
## discrepa de la curación.
##
## Flujo cuando el INE amplíe un censo o las fichas:
##   1. correr este script
##   2. leer las filas nuevas que reporta
##   3. pegarlas al CSV curado, revisando el tema propuesto
##   4. correr validar_taxonomia.R
##
## Uso:  Rscript data-raw/taxonomia/semilla_variable_tema.R

source("data-raw/ddi/parse_ddi.R")

TAX_DIR <- "data-raw/taxonomia"
ANIOS <- c(2024, 2012, 2001, 1992, 1976)

load("data/codebook_meta.rda")
load("data/codebook_historico_meta.rda")

temas_ref <- utils::read.csv(file.path(TAX_DIR, "temas.csv"), stringsAsFactors = FALSE)
bloque_ref <- utils::read.csv(file.path(TAX_DIR, "bloque_tema.csv"),
                              stringsAsFactors = FALSE, na.strings = c("", "NA"))

codebook_de <- function(anio) {
  if (anio == 2024) codebook_meta else codebook_historico_meta[[as.character(anio)]]
}

# ==============================================================================
# Reglas de propuesta
# ==============================================================================

# Rangos de pregunta -> tema, por censo. Es la señal más fuerte: el cuestionario
# agrupa las preguntas por tema, así que el número basta para la mayoría.
#
# En 2024, 2012 y 2001 la numeración es corrida entre secciones, así que el número
# de pregunta identifica el tema por sí solo. En 1976 y 1992 NO: vivienda y persona
# se numeran en paralelo (`v03` = paredes y `p03` = sexo son ambos "pregunta 3"), y
# los rangos tienen que ir por tabla. Para esos dos años se usa RANGOS_POR_TABLA.
RANGOS <- list(
  `2024` = list(
    vivienda_hogar          = c(1, 2, 12, 13, 14, 17),
    materiales_construccion = 3:6,
    servicios_basicos       = c(7:11, 15, 16),
    equipamiento_hogar      = 18,
    tic                     = 19,
    emigracion_internacional = 20,
    mortalidad              = 21,
    poblacion               = c(24:27, 53),
    ciudadania              = 28:29,
    salud_seguridad_social  = 30:31,
    autoidentificacion      = 32,
    idiomas                 = 33:34,
    migracion               = 35:37,
    educacion               = c(38:41),
    discapacidad            = 42,
    caracteristicas_economicas = 43:51,
    movilidad_trabajo       = 52,
    fecundidad              = 54:59
  ),
  # El cuestionario de 2012 numera distinto: vivienda 1-22, persona 23-49.
  `2012` = list(
    vivienda_hogar          = c(1, 2, 13, 14, 15, 19),
    materiales_construccion = 3:6,
    servicios_basicos       = c(7:12, 16),
    tic                     = 17,
    equipamiento_hogar      = 18,
    emigracion_internacional = 20,
    mortalidad              = 21,
    discapacidad            = 22,
    poblacion               = c(23:25, 45),
    ciudadania              = 26:27,
    salud_seguridad_social  = 28,
    autoidentificacion      = 29,
    idiomas                 = 30:31,
    migracion               = 32:34,
    educacion               = c(35:38),
    caracteristicas_economicas = 39:44,
    fecundidad              = 46:49
  ),
  # 2001: vivienda 4-26, persona 28-55.
  `2001` = list(
    vivienda_hogar          = c(4, 5, 17, 18, 19, 21),
    materiales_construccion = 6:9,
    servicios_basicos       = c(10:16),
    equipamiento_hogar      = 20,
    mortalidad              = 22:26,
    poblacion               = c(28, 29, 31, 48),
    ciudadania              = 30,
    idiomas                 = c(32, 35),
    migracion               = c(33, 34, 41),
    educacion               = 36:40,
    caracteristicas_economicas = c(42:47),
    autoidentificacion      = 49,
    fecundidad              = 50:55
  )
)

# 1976 y 1992: rangos por tabla, porque vivienda y persona comparten numeración.
RANGOS_POR_TABLA <- list(
  `1992` = list(
    vivienda = list(
      vivienda_hogar          = c(1, 2, 10, 11, 12, 14, 20, 21),
      materiales_construccion = 3:5,
      servicios_basicos       = c(6:9, 13),
      salud_seguridad_social  = 15,
      religion                = 16,
      mortalidad              = 17,
      poblacion               = 18
    ),
    persona = list(
      ciudadania              = 1,
      poblacion               = c(2:5),
      migracion               = 6:8,
      idiomas                 = 9,
      educacion               = 10:14,
      caracteristicas_economicas = 15:19,
      fecundidad              = 20:23
    ),
    mortalidad = list(mortalidad = 17)
  ),
  `1976` = list(
    vivienda = list(
      vivienda_hogar          = c(1, 2, 10, 11, 12, 14),
      materiales_construccion = 3:5,
      servicios_basicos       = c(6:9),
      idiomas                 = 15,
      poblacion               = 18
    ),
    poblacion = list(
      poblacion               = c(2:5),
      migracion               = 6:8,
      idiomas                 = 9,
      educacion               = c(10, 11, 14),
      caracteristicas_economicas = 15:18,
      fecundidad              = c(20, 21, 23)
    )
  )
)

# Derivadas y variables sin número de pregunta, enumeradas por censo. Cuando el
# nombre no dice nada, la etiqueta del INE sí, pero preferimos una lista
# explícita y auditable a una heurística sobre texto libre.
ENUMERADAS <- list(
  `2024` = c(
    edad_qui = "poblacion", g_edad = "poblacion", g_edad_bol = "poblacion",
    tot_pers = "vivienda_hogar", tip_hog = "vivienda_hogar",
    v19e_f = "tic", v19h_d = "tic",
    nivel_edu = "educacion", aestudio = "educacion", asiste = "educacion",
    gedadedu = "educacion",
    idioma_mayor_uso = "idiomas", idioma_mat = "idiomas",
    hulta = "fecundidad",
    pet_19 = "caracteristicas_economicas", condact_19 = "caracteristicas_economicas",
    ft_19 = "caracteristicas_economicas", fft_19 = "caracteristicas_economicas",
    ocu_1d_19 = "caracteristicas_economicas", act_eco_2d_19 = "caracteristicas_economicas",
    ocu_1d_13 = "caracteristicas_economicas", act_eco_2d_13 = "caracteristicas_economicas",
    pet_13 = "caracteristicas_economicas", condact_13 = "caracteristicas_economicas",
    pea_13 = "caracteristicas_economicas", pei_13 = "caracteristicas_economicas"
  ),
  `2012` = c(
    pea = "caracteristicas_economicas", pet = "caracteristicas_economicas",
    pei = "caracteristicas_economicas"
  ),
  `2001` = c(
    totp = "poblacion", toth = "poblacion", totm = "poblacion",
    eshogar = "vivienda_hogar"
  ),
  `1992` = c(
    urbrur = "ubicacion_geografica", v22 = "ubicacion_geografica",
    i12 = "ubicacion_geografica", i122 = "ubicacion_geografica",
    v18t = "poblacion",
    # Necesidades Básicas Insatisfechas: indicador de pobreza que REDATAM
    # construye a partir de materiales, servicios y hacinamiento de la vivienda.
    nbi_grup_v = "vivienda_hogar", nbi_pobres_v = "vivienda_hogar",
    p25 = "idiomas",
    gedad = "poblacion", edadagru = "poblacion",
    npet = "caracteristicas_economicas", npea = "caracteristicas_economicas",
    npei = "caracteristicas_economicas"
  ),
  `1976` = c(
    turrur = "ubicacion_geografica", area = "ubicacion_geografica",
    v00 = "ubicacion_geografica",
    v011 = "vivienda_hogar", v18h = "poblacion", v18m = "poblacion",
    i10v = "vivienda_hogar", i13v = "vivienda_hogar",
    edad5 = "poblacion", edadg = "poblacion", edade = "poblacion",
    # Derivadas de REDATAM sobre lugar de residencia y nacimiento.
    reshab = "migracion", lugnac = "migracion", resh5 = "migracion",
    p06nue = "migracion", p07nue = "migracion", p08nue = "migracion",
    p06bm = "migracion", p07bm = "migracion", p08bm = "migracion",
    anioes1 = "educacion", nivela = "educacion",
    pet = "caracteristicas_economicas", pea = "caracteristicas_economicas",
    pei = "caracteristicas_economicas", uf15 = "caracteristicas_economicas"
  )
)

# Sufijos de nombre que delatan el tema de las derivadas geográficas de
# migración y movilidad (dep_nac_cod, mun_res5_cod, prov_lab_cod...).
SUFIJOS_MIGRACION <- c("_nac_cod", "_res_cod", "_res5_cod")
SUFIJOS_MOVILIDAD <- c("_lab_cod")

proponer_tema <- function(variable, tabla, pregunta_num, origen, anio, bloque = NA) {
  v <- tolower(variable)
  key <- as.character(anio)
  n <- length(v)
  out <- rep(NA_character_, n)

  # 1. Geografía e identificadores, por origen. Va ANTES del bloque: las claves
  #    geográficas de las tablas de fichas llevan bloque `unidad` por conveniencia
  #    del selector, pero su tema es `ubicacion_geografica`, no `identificacion`.
  out[is.na(out) & !is.na(origen) & origen == "geografia"] <- "ubicacion_geografica"
  out[is.na(out) & !is.na(origen) & origen == "identificador"] <- "identificacion"

  # 2. Fichas e indicadores: el bloque manda.
  con_bloque <- is.na(out) & !is.na(bloque)
  if (any(con_bloque)) {
    out[con_bloque] <- bloque_ref$tema[match(bloque[con_bloque], bloque_ref$bloque)]
  }

  # 3. Derivadas geográficas de migración / movilidad.
  for (s in SUFIJOS_MIGRACION) out[is.na(out) & endsWith(v, s)] <- "migracion"
  for (s in SUFIJOS_MOVILIDAD) out[is.na(out) & endsWith(v, s)] <- "movilidad_trabajo"

  # 3b. Desagregación geográfica de REDATAM en 2001: DEP33, PRO33, SEC33, CAN33,
  #     CIU33, ZON33 son el lugar de la pregunta 33, y así con 34 y 41. El número
  #     de pregunta va embebido en el nombre, así que se resuelve por el rango.
  RE_REDATAM_GEO <- "^(dep|pro|sec|can|ciu|zon)([0-9]{2})$"
  geo_preg <- is.na(out) & grepl(RE_REDATAM_GEO, v)
  if (any(geo_preg)) {
    n_emb <- as.integer(sub(RE_REDATAM_GEO, "\\2", v[geo_preg]))
    rangos_key <- RANGOS[[key]]
    tema_emb <- rep(NA_character_, length(n_emb))
    if (!is.null(rangos_key)) {
      for (tm in names(rangos_key)) {
        tema_emb[is.na(tema_emb) & n_emb %in% rangos_key[[tm]]] <- tm
      }
    }
    out[geo_preg] <- tema_emb
  }

  # 4. Lista enumerada del censo.
  enum <- ENUMERADAS[[key]]
  if (!is.null(enum)) {
    hit <- is.na(out) & v %in% names(enum)
    out[hit] <- unname(enum[v[hit]])
  }

  # 5. Rango de pregunta. Primero los rangos por tabla (1976 y 1992), luego los
  #    rangos globales (2024, 2012, 2001).
  por_tabla <- RANGOS_POR_TABLA[[key]]
  if (!is.null(por_tabla)) {
    for (tb in names(por_tabla)) {
      for (tm in names(por_tabla[[tb]])) {
        hit <- is.na(out) & tabla == tb & !is.na(pregunta_num) &
          pregunta_num %in% por_tabla[[tb]][[tm]]
        out[hit] <- tm
      }
    }
  }
  rangos <- RANGOS[[key]]
  if (!is.null(rangos)) {
    for (tm in names(rangos)) {
      hit <- is.na(out) & !is.na(pregunta_num) & pregunta_num %in% rangos[[tm]]
      out[hit] <- tm
    }
  }

  # 6. La tabla como último recurso: en emigracion/mortalidad/discapacidad el
  #    tema coincide con la tabla, sea cual sea la pregunta.
  out[is.na(out) & tabla == "emigracion"] <- "emigracion_internacional"
  out[is.na(out) & tabla == "mortalidad"] <- "mortalidad"
  out[is.na(out) & tabla == "discapacidad"] <- "discapacidad"

  out
}

# ==============================================================================
# Bloques de las fichas (solo 2024)
# ==============================================================================

bloques_de_fichas <- function() {
  f1 <- utils::read.csv("data-raw/fichas/campos.csv", stringsAsFactors = FALSE)
  f2 <- utils::read.csv("data-raw/fichas/campos_vivienda.csv", stringsAsFactors = FALSE)
  rbind(
    data.frame(variable = f1$variable, bloque = f1$bloque, stringsAsFactors = FALSE),
    data.frame(variable = f2$variable, bloque = f2$bloque, stringsAsFactors = FALSE)
  )
}

# ==============================================================================
# Propuesta por año
# ==============================================================================

propuesta_de <- function(anio) {
  cb <- codebook_de(anio)
  key <- as.character(anio)

  # Metadatos del DDI, unidos según la estrategia de cada año.
  ddi <- leer_ddi(anio)
  ddi$pregunta <- resolver_pregunta(ddi$labl, ddi$variable_ddi)$pregunta
  ddi$origen <- derivar_origen(ddi$variable_ddi, ddi$labl, ddi$regla_derivacion, ddi$pregunta)
  ddi$pregunta_num <- suppressWarnings(as.integer(sub("[^0-9].*$", "", ddi$pregunta)))

  if (anio == 2024) {
    ddi$clave <- paste(ddi$tabla, tolower(ddi$variable_ddi))
  } else if (anio == 2001) {
    ddi$clave <- paste(ddi$tabla, toupper(ddi$variable_ddi))
  } else {
    corr <- utils::read.csv(file.path(TAX_DIR, "nombres_ddi_2012.csv"),
                            stringsAsFactors = FALSE, na.strings = c("", "NA"))
    ddi$variable_cb <- corr$variable_cb[match(
      paste(ddi$tabla, ddi$variable_ddi), paste(corr$tabla, corr$variable_ddi)
    )]
    ddi$clave <- ifelse(is.na(ddi$variable_cb), NA_character_,
                        paste(ddi$tabla, toupper(ddi$variable_cb)))
  }

  cb$clave <- if (anio == 2024) {
    paste(cb$tabla, tolower(cb$variable))
  } else {
    paste(cb$tabla, toupper(cb$variable))
  }

  i <- match(cb$clave, ddi$clave)
  cb$pregunta <- ddi$pregunta[i]
  cb$pregunta_num <- ddi$pregunta_num[i]
  cb$origen <- ddi$origen[i]

  # Sin fila en el DDI: derivar el origen a partir del nombre del codebook.
  falta <- is.na(cb$origen)
  if (any(falta)) {
    p_local <- resolver_pregunta(cb$etiqueta[falta], cb$variable[falta])
    cb$origen[falta] <- derivar_origen(
      cb$variable[falta], cb$etiqueta[falta], rep(NA_character_, sum(falta)),
      p_local$pregunta
    )
    cb$pregunta[falta] <- p_local$pregunta
    cb$pregunta_num[falta] <- p_local$pregunta_num
  }

  # La desagregación geográfica de REDATAM (DEP33, ZON41...) no está en el DDI ni
  # tiene número de pregunta reconocible por sí misma: es una derivada.
  sin_origen <- is.na(cb$origen) & grepl("^(dep|pro|sec|can|ciu|zon)[0-9]{2}$",
                                         tolower(cb$variable))
  cb$origen[sin_origen] <- "derivada"

  # Las fichas y unidades censales solo existen en 2024 y son indicadores. Esto va
  # ANTES de la regla general de `derivada`, o los 194 indicadores del geoportal
  # caerían en ella por no tener número de pregunta.
  cb$bloque <- NA_character_
  if (anio == 2024) {
    bl <- bloques_de_fichas()
    es_ind <- cb$tabla %in% c("ficha", "unidad")
    cb$bloque[es_ind] <- bl$bloque[match(cb$variable[es_ind], bl$variable)]
    # Las comunes de esas tablas (codigo, nombre, area, geo) no están en
    # campos.csv: se les asigna el bloque `unidad`.
    cb$bloque[es_ind & is.na(cb$bloque)] <- "unidad"
    cb$origen[es_ind & cb$tabla == "ficha" & is.na(cb$origen)] <- "indicador"
    cb$origen[es_ind & is.na(cb$origen)] <- "indicador"
    # Geo e identificadores de esas tablas mantienen su origen real.
    cb$origen[es_ind & tolower(cb$variable) %in% ORIGEN_GEOGRAFIA] <- "geografia"
    cb$origen[es_ind & tolower(cb$variable) %in% ORIGEN_IDENTIFICADOR] <- "identificador"
    cb$bloque[es_ind & cb$origen %in% c("geografia", "identificador")] <- "unidad"
  }

  # Lo que el codebook trae y el DDI no documenta, sin número de pregunta
  # reconocible, es una variable que construyó open-redatam: grupos de edad,
  # PEA/PET/PEI, índices de NBI, recodificaciones de residencia.
  cb$origen[is.na(cb$origen) & is.na(cb$pregunta)] <- "derivada"

  # Una clave geográfica, un identificador de registro o un indicador agregado no
  # provienen de ninguna pregunta del formulario, aunque su nombre lleve dígitos
  # (v00 = manzana, p00 = número de orden de la persona). Anular la pregunta evita
  # además que `pregunta_num` valga 0, fuera del rango 1:59 del cuestionario.
  sin_pregunta <- !is.na(cb$origen) &
    cb$origen %in% c("geografia", "identificador", "indicador")
  cb$pregunta[sin_pregunta] <- NA_character_
  cb$pregunta_num[sin_pregunta] <- NA_integer_

  cb$tema <- proponer_tema(cb$variable, cb$tabla, cb$pregunta_num, cb$origen, anio, cb$bloque)

  data.frame(
    anio = as.integer(anio), tabla = cb$tabla, variable = cb$variable,
    tema = cb$tema, origen = cb$origen, pregunta = cb$pregunta,
    bloque = cb$bloque, etiqueta = cb$etiqueta, nota = "",
    stringsAsFactors = FALSE
  )
}

# ==============================================================================
# Diff contra el curado
# ==============================================================================

for (anio in ANIOS) {
  prop <- propuesta_de(anio)
  f_curado <- file.path(TAX_DIR, sprintf("variable_tema_%d.csv", anio))
  f_prop <- file.path(TAX_DIR, sprintf("semilla_propuesta_%d.csv", anio))
  utils::write.csv(prop, f_prop, row.names = FALSE, na = "")

  cat(sprintf("\n===== %d: %d filas =====\n", anio, nrow(prop)))
  sin_tema <- prop[is.na(prop$tema), ]
  cat("sin tema propuesto:", nrow(sin_tema), "\n")
  if (nrow(sin_tema)) {
    print(sin_tema[, c("tabla", "variable", "origen", "pregunta", "etiqueta")],
          row.names = FALSE, right = FALSE)
  }
  sin_origen <- prop[is.na(prop$origen), ]
  cat("sin origen propuesto:", nrow(sin_origen), "\n")
  if (nrow(sin_origen)) {
    print(sin_origen[, c("tabla", "variable", "tema", "etiqueta")],
          row.names = FALSE, right = FALSE)
  }
  malos <- setdiff(na.omit(prop$tema), temas_ref$tema)
  if (length(malos)) cat("! temas fuera de temas.csv:", paste(malos, collapse = ", "), "\n")

  if (!file.exists(f_curado)) {
    cat("No existe", basename(f_curado), "- revisa la propuesta y guárdala con ese nombre.\n")
    next
  }

  cur <- utils::read.csv(f_curado, stringsAsFactors = FALSE, na.strings = c("", "NA"))
  k_p <- paste(prop$tabla, prop$variable)
  k_c <- paste(cur$tabla, cur$variable)

  nuevas <- prop[!k_p %in% k_c, ]
  cat("filas nuevas (no están en el curado):", nrow(nuevas), "\n")
  if (nrow(nuevas)) print(nuevas[, c("tabla", "variable", "tema", "etiqueta")],
                          row.names = FALSE, right = FALSE)

  huerfanas <- cur[!k_c %in% k_p, ]
  cat("filas huérfanas (en el curado pero no en el codebook):", nrow(huerfanas), "\n")
  if (nrow(huerfanas)) print(huerfanas[, c("tabla", "variable", "tema")],
                             row.names = FALSE, right = FALSE)

  comun <- intersect(k_p, k_c)
  disc <- data.frame(
    clave = comun,
    propuesto = prop$tema[match(comun, k_p)],
    curado = cur$tema[match(comun, k_c)],
    stringsAsFactors = FALSE
  )
  disc <- disc[!is.na(disc$curado) & (is.na(disc$propuesto) | disc$propuesto != disc$curado), ]
  cat("discrepancias regla vs curación:", nrow(disc),
      "(esperable: son las decisiones de frontera)\n")
  if (nrow(disc)) print(disc, row.names = FALSE, right = FALSE)
}

cat("\nPropuestas escritas como semilla_propuesta_<anio>.csv (no se versionan).\n")

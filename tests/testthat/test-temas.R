## Taxonomía temática: cobertura, vocabularios cerrados y casos anclados.
##
## Las comprobaciones estructurales duplican a propósito las de
## data-raw/taxonomia/validar_taxonomia.R: allí protegen el build, aquí protegen
## el dato ya instalado, para que un .rda desincronizado rompa CI y no solo el
## build local.

ANIOS_TAX <- c(2024, 2012, 2001, 1992, 1976)

cb_de <- function(anio) {
  if (anio == 2024) codebook_meta else codebook_historico_meta[[as.character(anio)]]
}

test_that("ninguna variable se queda sin tema", {
  for (anio in ANIOS_TAX) {
    cb <- cb_de(anio)
    huerfanas <- cb$variable[is.na(cb$tema)]
    expect_identical(
      huerfanas, character(0),
      info = paste("censo", anio, "- sin tema:", paste(huerfanas, collapse = ", "))
    )
  }
})

test_that("el número de variables por censo es el esperado", {
  # Cambiar estos números debe ser deliberado: si el INE amplía un censo, hay que
  # curar el CSV de taxonomía antes (data-raw/taxonomia/semilla_variable_tema.R).
  expect_equal(nrow(codebook_meta), 393)
  expect_equal(nrow(codebook_historico_meta[["2012"]]), 97)
  expect_equal(nrow(codebook_historico_meta[["2001"]]), 117)
  expect_equal(nrow(codebook_historico_meta[["1992"]]), 125)
  expect_equal(nrow(codebook_historico_meta[["1976"]]), 77)
})

test_that("los temas usados y los declarados se corresponden en ambas direcciones", {
  usados <- unique(unlist(lapply(ANIOS_TAX, function(a) stats::na.omit(cb_de(a)$tema))))
  expect_identical(setdiff(usados, censo_temas_meta$tema), character(0))
  expect_identical(setdiff(censo_temas_meta$tema, usados), character(0))
})

test_that("censo_temas_meta$anios refleja en qué censos existe cada tema", {
  for (i in seq_len(nrow(censo_temas_meta))) {
    tm <- censo_temas_meta$tema[i]
    declarados <- strsplit(censo_temas_meta$anios[i], ",")[[1]]
    reales <- as.character(ANIOS_TAX)[vapply(ANIOS_TAX, function(a) tm %in% cb_de(a)$tema, logical(1))]
    expect_setequal(declarados, reales)
  }
})

test_that("los vocabularios están cerrados", {
  origen_ok <- c("cuestionario", "derivada", "geografia", "identificador", "indicador")
  universo_ok <- c(
    "todas_personas", "personas_4_mas", "personas_5_mas", "personas_6_mas",
    "personas_7_mas", "personas_12_mas", "personas_15_mas", "personas_19_mas",
    "mujeres_12_mas", "mujeres_15_49",
    "todas_viviendas", "viviendas_particulares", "viviendas_presentes", "hogares",
    "personas_emigrantes", "personas_fallecidas",
    # 1976 y 1992 declaran universos para cada nivel de la jerarquía REDATAM.
    "departamentos", "provincias", "secciones", "localidades", "cantones",
    "ciudades", "distritos", "zonas", "manzanas", "sectores", "segmentos", "areas"
  )
  for (anio in ANIOS_TAX) {
    cb <- cb_de(anio)
    expect_false(anyNA(cb$origen), info = paste("censo", anio))
    expect_identical(setdiff(cb$origen, origen_ok), character(0), info = paste("censo", anio))
    expect_identical(setdiff(stats::na.omit(cb$universo), universo_ok), character(0),
                     info = paste("censo", anio))
  }
})

test_that("el capítulo es solo del cuestionario 2024", {
  expect_false(anyNA(codebook_meta$capitulo))
  expect_identical(setdiff(codebook_meta$capitulo, LETTERS[1:7]), character(0))
  # Los censos anteriores sí tienen tema, pero no capítulo: sus cuestionarios
  # tienen otra estructura y varios numeran vivienda y persona en paralelo.
  for (anio in c("1976", "1992", "2001", "2012")) {
    cb <- codebook_historico_meta[[anio]]
    expect_true(all(is.na(cb$capitulo)), info = paste("censo", anio))
    expect_false(anyNA(cb$tema), info = paste("censo", anio))
  }
})

test_that("grupo_ine existe solo en los censos cuyo DDI trae varGrp", {
  # El DDI de 2024 no tiene varGrp; los cuatro anteriores sí.
  expect_true(all(is.na(codebook_meta$grupo_ine)))
  for (anio in c("2012", "2001", "1992", "1976")) {
    expect_gt(sum(!is.na(codebook_historico_meta[[anio]]$grupo_ine)), 0, label = anio)
  }
})

test_that("pregunta_num está en rango y es coherente con origen", {
  for (anio in ANIOS_TAX) {
    cb <- cb_de(anio)
    nums <- stats::na.omit(cb$pregunta_num)
    expect_true(all(nums >= 1 & nums <= 59), info = paste("censo", anio))
    # Implicación en un solo sentido: del cuestionario => tiene pregunta. No al
    # revés, porque ocu_1d_13 y act_eco_2d_13 son derivadas que conservan el
    # número de la pregunta de la que salen.
    del_cuestionario <- cb$origen == "cuestionario"
    expect_false(any(del_cuestionario & is.na(cb$pregunta_num)),
                 info = paste("censo", anio))
  }
})

test_that("bloque solo aparece en los indicadores de ficha del CPV-2024", {
  con_bloque <- !is.na(codebook_meta$bloque)
  expect_true(all(codebook_meta$tabla[con_bloque] %in% c("ficha", "unidad")))
  expect_identical(setdiff(codebook_meta$bloque[con_bloque], censo_bloques_meta$bloque),
                   character(0))
  for (anio in c("1976", "1992", "2001", "2012")) {
    expect_true(all(is.na(codebook_historico_meta[[anio]]$bloque)), info = anio)
  }
})

# --- casos anclados ----------------------------------------------------------
# Rompen si alguien renumera la taxonomía sin pensarlo. Cambiarlos debe ser una
# decisión, no un efecto colateral.

test_that("variables de referencia caen en el tema esperado", {
  expect_equal(codebook("p41a_nivel")$tema, "educacion")
  expect_equal(codebook("v07_aguapro")$tema, "servicios_basicos")
  expect_equal(codebook("v03_pared")$tema, "materiales_construccion")
  expect_equal(codebook("p52_mov")$tema, "movilidad_trabajo")
  # Decisiones de frontera documentadas en censo_temas_meta$descripcion.
  expect_equal(codebook("p59_atparto")$tema, "fecundidad")
  expect_equal(codebook("p24_parentes")$tema, "poblacion")
  expect_equal(codebook("p53_ecivil")$tema, "poblacion")
  # Históricos.
  expect_equal(codebook("P24", tabla = "persona", anio = 2012)$tema, "poblacion")
  expect_equal(codebook("P28", tabla = "persona", anio = 2001)$tema, "poblacion")
})

test_that("el capítulo se deriva del número de pregunta", {
  expect_equal(codebook("v07_aguapro")$capitulo, "C")   # pregunta 7
  expect_equal(codebook("p25_sexo")$capitulo, "G")      # pregunta 25
  expect_equal(codebook("v01_tipoviv")$capitulo, "B")   # pregunta 1
  # v17_tenencia está en el capítulo C aunque su tema (vivienda_hogar) tenga el B:
  # capítulo y tema son dos facetas independientes.
  expect_equal(codebook("v17_tenencia")$capitulo, "C")
  expect_equal(codebook("v17_tenencia")$tema, "vivienda_hogar")
})

test_that("origen distingue preguntas de derivadas del INE", {
  expect_equal(codebook("nivel_edu")$origen, "derivada")
  expect_equal(codebook("condact_19")$origen, "derivada")
  expect_equal(codebook("p40_lee")$origen, "cuestionario")
  expect_equal(codebook("idep", tabla = "persona")$origen, "geografia")
  expect_equal(codebook("i00", tabla = "persona")$origen, "identificador")
  expect_equal(codebook("pob_total_h", tabla = "ficha")$origen, "indicador")
})

test_that("los universos reproducen los filtros impresos en el cuestionario 2024", {
  # Los cuatro filtros de edad y sexo del formulario. Son la razón principal de
  # que exista la columna: sin ellos se calculan tasas sobre el denominador
  # equivocado sin ningún aviso.
  expect_equal(codebook("p40_lee")$universo, "personas_5_mas")
  expect_equal(codebook("p43_pago")$universo, "personas_7_mas")
  expect_equal(codebook("p53_ecivil")$universo, "personas_12_mas")
  expect_equal(codebook("p54_hvtot")$universo, "mujeres_12_mas")
  # nivel_edu está calculada sobre 19 o más años: compararla con una población
  # distinta es el error clásico que esta columna permite detectar.
  expect_equal(codebook("nivel_edu")$universo, "personas_19_mas")
})

test_that("los cuatro censos anteriores declaran filtros de edad en su DDI", {
  # Es la información que hace comparable una serie temporal: sin ella no se sabe
  # si dos censos preguntaron lo mismo a la misma población.
  expect_true(all(c("personas_4_mas", "personas_7_mas", "personas_15_mas") %in%
                    codebook(anio = 2001)$universo))
  expect_true(all(c("personas_5_mas", "personas_6_mas", "personas_7_mas") %in%
                    codebook(anio = 1992)$universo))
  expect_true(all(c("personas_5_mas", "personas_7_mas", "personas_12_mas") %in%
                    codebook(anio = 1976)$universo))
})

# --- censo_temas() -----------------------------------------------------------

test_that("censo_temas() cuenta todas las variables del censo", {
  ct <- censo_temas()
  expect_equal(nrow(ct), 20)
  expect_equal(sum(ct$n_variables), nrow(codebook_meta))
  for (anio in setdiff(ANIOS_TAX, 2024)) {
    expect_equal(sum(censo_temas(anio = anio)$n_variables), nrow(cb_de(anio)))
  }
})

test_that("censo_temas() filtra y no devuelve temas vacíos con tabla=", {
  viv <- censo_temas(tabla = "vivienda")
  expect_true(all(viv$n_variables > 0))
  expect_true(nrow(viv) < 20)

  cap_c <- censo_temas(capitulo = "C")
  expect_true(all(cap_c$capitulo == "C"))
  # También acepta parte del nombre del capítulo, y el término tiene que ser
  # inequívoco: "vivienda" a secas aparece en el nombre del capítulo B ("Tipo de
  # vivienda") y del C ("Características de la vivienda"), y devolver los dos es
  # el comportamiento correcto.
  expect_identical(censo_temas(capitulo = "de la vivienda")$tema, cap_c$tema)
  expect_setequal(censo_temas(capitulo = "vivienda")$capitulo, c("B", "C"))

  expect_equal(nrow(censo_temas(tema = "educacion")), 1)
  expect_error(censo_temas(tema = "no_existe"), "no reconocido")
})

test_that("censo_temas() cubre los cinco censos", {
  # El INE publica DDI de los cinco estudios (132, 8, 10, 47 y 46).
  for (anio in ANIOS_TAX) {
    ct <- censo_temas(anio = anio)
    expect_gt(nrow(ct), 0, label = paste("censo", anio))
    expect_equal(sum(ct$n_variables), nrow(cb_de(anio)))
  }
  expect_error(censo_temas(anio = 1900), "diccionario")
})

# --- vars_tema() -------------------------------------------------------------

test_that("vars_tema() devuelve un vector de caracteres limpio", {
  v <- vars_tema("educacion", tabla = "persona")
  expect_type(v, "character")
  expect_null(attributes(v))
  expect_false(anyDuplicated(v) > 0)
  expect_true(all(v %in% codebook(tabla = "persona")$variable))
})

test_that("vars_tema() ordena por cuestionario y deja las derivadas al final", {
  v <- vars_tema("educacion", tabla = "persona")
  cb <- codebook(tabla = "persona")
  origen <- cb$origen[match(v, cb$variable)]
  # Ninguna variable del cuestionario después de una derivada.
  expect_false(any(diff(origen == "derivada") < 0))
})

test_that("vars_tema() acepta varios temas y filtra por origen y tipo", {
  v <- vars_tema(c("educacion", "idiomas"), tabla = "persona")
  expect_gt(length(v), length(vars_tema("idiomas", tabla = "persona")))

  solo_preg <- vars_tema("caracteristicas_economicas", tabla = "persona",
                         origen = "cuestionario")
  cb <- codebook(tabla = "persona")
  expect_true(all(cb$origen[match(solo_preg, cb$variable)] == "cuestionario"))

  cats <- vars_tema("educacion", tabla = "persona", tipo = "categorica")
  expect_true(all(cb$tipo[match(cats, cb$variable)] == "categorica"))
})

test_that("vars_tema() avisa cuando el tema abarca varias tablas", {
  expect_message(vars_tema("migracion"), "varias tablas")
})

test_that("vars_tema() sugiere el slug correcto ante un error de tecleo", {
  expect_error(vars_tema("educacon", tabla = "persona"), "educacion")
  expect_error(vars_tema("no_existe_nada"), "no reconocido")
})

test_that("vars_tema() funciona en los cinco censos", {
  for (anio in ANIOS_TAX) {
    # En 1976 la tabla de personas se llama `poblacion`, no `persona`.
    tabla <- if (anio == 1976) "poblacion" else "persona"
    v <- vars_tema("educacion", tabla = tabla, anio = anio)
    expect_gt(length(v), 0, label = paste("censo", anio))
  }
})

test_that("`religion` solo existe en el censo 1992", {
  # Es el único de los cinco que preguntó por pertenencia religiosa.
  rel <- censo_temas_meta[censo_temas_meta$tema == "religion", ]
  expect_equal(rel$anios, "1992")
  expect_equal(rel$fuente, "censosbo")
  expect_gt(nrow(codebook(tema = "religion", anio = 1992)), 0)
  expect_false("religion" %in% codebook_meta$tema)
})

test_that("los universos de 1976 y 1992 traen los filtros de edad del cuestionario", {
  u92 <- codebook(anio = 1992)$universo
  expect_true(all(c("personas_5_mas", "personas_6_mas", "personas_7_mas",
                    "mujeres_12_mas") %in% u92))
  u76 <- codebook(anio = 1976)$universo
  expect_true(all(c("personas_5_mas", "personas_7_mas", "personas_12_mas",
                    "mujeres_12_mas") %in% u76))
})

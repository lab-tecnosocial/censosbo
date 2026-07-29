## get_temporal() avisa cuando una variable no se preguntó a la misma población.
##
## Es lo que convierte el metadato de universo en una salvaguarda: la advertencia
## salta en el punto de uso, no solo en la documentación. Ocho de las 27 variables
## armonizadas cambian de universo entre censos.

test_that(".universo_armonizada lee el universo del codebook de cada censo", {
  # sabe_leer cambia cuatro veces entre los cinco censos.
  expect_equal(censosbo:::.universo_armonizada("sabe_leer", 1976L), "personas_5_mas")
  expect_equal(censosbo:::.universo_armonizada("sabe_leer", 1992L), "personas_6_mas")
  expect_equal(censosbo:::.universo_armonizada("sabe_leer", 2001L), "personas_4_mas")
  expect_equal(censosbo:::.universo_armonizada("sabe_leer", 2024L), "personas_5_mas")
  # nivel_edu es el caso más extremo: de 6 años en 1992 a 19 en 2024.
  expect_equal(censosbo:::.universo_armonizada("nivel_edu", 1992L), "personas_6_mas")
  expect_equal(censosbo:::.universo_armonizada("nivel_edu", 2024L), "personas_19_mas")
})

test_that("en 1976 busca la tabla `poblacion`, que es como se llama ahí", {
  expect_false(is.na(censosbo:::.universo_armonizada("sexo", 1976L)))
})

test_that(".avisar_universos avisa solo cuando el universo difiere de verdad", {
  expect_warning(censosbo:::.avisar_universos("sabe_leer", c(1992L, 2001L, 2024L)),
                 "no se preguntó a la misma población")
  expect_warning(censosbo:::.avisar_universos("nivel_edu", c(1992L, 2024L)), "19")
  # Un solo censo nunca puede divergir.
  expect_silent(censosbo:::.avisar_universos("sabe_leer", 2024L))
  # `sexo` se preguntó a todas las personas en todos los censos.
  expect_silent(censosbo:::.avisar_universos("sexo", c(1976L, 1992L, 2001L, 2012L, 2024L)))
})

test_that("el aviso sugiere la edad mínima que iguala los universos", {
  # Con 4+, 6+ y 5+ en juego, el filtro comparable es el más restrictivo: 6.
  expect_warning(censosbo:::.avisar_universos("sabe_leer", c(1992L, 2001L, 2024L)),
                 "edad >= 6")
})

test_that("el aviso pide añadir `edad` si no está entre las variables", {
  # get_temporal() solo devuelve las variables pedidas, así que sugerir
  # `filter(edad >= 6)` a secas produce «object 'edad' not found».
  expect_warning(censosbo:::.avisar_universos("sabe_leer", c(1992L, 2001L, 2024L)),
                 "Añade")
  # Cuando ya la pidió, el consejo es directo y no repite la instrucción.
  w <- tryCatch(censosbo:::.avisar_universos(c("sabe_leer", "edad"),
                                            c(1992L, 2001L, 2024L)),
                warning = function(x) conditionMessage(x))
  expect_match(w, "Filtra")
  expect_false(grepl("Añade", w))
})

test_that("las ocho variables con universo divergente están cubiertas", {
  divergentes <- c("estado_civil", "sabe_leer", "nivel_edu", "asistencia_escolar",
                   "idioma_materno", "hijos_nacidos_vivos", "hijos_sobrevivientes")
  anios <- c(1976L, 1992L, 2001L, 2012L, 2024L)
  for (v in divergentes) {
    expect_warning(censosbo:::.avisar_universos(v, anios),
                   "no se preguntó a la misma población", label = v)
  }
})

# --- puente entre los dos vocabularios temáticos -----------------------------

test_that("get_temporal(grupo=) sigue aceptando los seis grupos originales", {
  # Son API pública desde antes de que existiera la taxonomía: alias permanentes.
  for (g in names(grupos_variables())) {
    expect_type(censosbo:::.resolver_grupo(g), "character")
  }
})

test_that("get_temporal(grupo=) acepta también los slugs de censo_temas()", {
  expect_message(v <- censosbo:::.resolver_grupo("poblacion"), "equivale al grupo")
  expect_identical(v, grupos_variables()$demografico)
  expect_message(v <- censosbo:::.resolver_grupo("fecundidad"), "fertilidad")
  expect_identical(v, grupos_variables()$fertilidad)
  # `cultural` cubre dos temas del vocabulario nuevo.
  expect_message(a <- censosbo:::.resolver_grupo("idiomas"), "cultural")
  expect_message(b <- censosbo:::.resolver_grupo("autoidentificacion"), "cultural")
  expect_identical(a, b)
})

test_that("un grupo inexistente lista los dos vocabularios", {
  err <- tryCatch(censosbo:::.resolver_grupo("no_existe"), error = function(e) conditionMessage(e))
  expect_match(err, "Grupos armonizados")
  expect_match(err, "censo_temas")
})

test_that("estado_civil se armoniza a 4 categorías comparables entre censos", {
  h <- censosbo:::.harmonize_estado_civil
  # 1976: 1=Soltero,2=Casado,3=Viudo,4=Divorciado
  expect_equal(h(c(1, 2, 3, 4), 1976L), c(1L, 2L, 4L, 3L))
  # 1992: 1=Casado/conv,2=Viudo,3=Sep/div,4=Soltero
  expect_equal(h(c(1, 2, 3, 4), 1992L), c(2L, 4L, 3L, 1L))
  # 2001/2012: 1=Solt,2=Cas,3=Conv,4=Sep,5=Div,6=Viu
  expect_equal(h(1:6, 2012L), c(1L, 2L, 2L, 3L, 3L, 4L))
  # 2024: 1=Cas,2=Conv,3=Sep,4=Div,5=Viu,6=Solt,9=Sin esp
  expect_equal(h(c(1, 2, 3, 4, 5, 6, 9), 2024L), c(2L, 2L, 3L, 3L, 4L, 1L, NA))
})

test_that("pet se armoniza a binario 1=Sí, 2=No", {
  h <- censosbo:::.harmonize_pet
  expect_equal(h(c(1, 2), 1976L), c(1L, 2L))
  expect_equal(h(c(1, 0), 1992L), c(1L, 2L))
  expect_equal(h(c(1, 0), 2012L), c(1L, 2L))
  expect_equal(h(c(1, 2, 9), 2024L), c(1L, 2L, NA))
  expect_true(all(is.na(h(c(1, 2), 2001L))))  # no disponible en 2001
})

test_that("pea conserva 1=Ocupado, 2=Cesante, 3=Aspirante en todos los años", {
  h <- censosbo:::.harmonize_pea
  for (a in c(1976L, 1992L, 2012L, 2024L)) {
    expect_equal(h(c(1, 2, 3), a), c(1L, 2L, 3L))
  }
  expect_true(all(is.na(h(c(1, 2, 3), 2001L))))
})

test_that("las etiquetas armonizadas cubren los códigos que producen las funciones", {
  # Garantía de no-drift: todo código no-NA producido debe tener etiqueta.
  labs <- censosbo:::.HARMONIZED_VALUE_LABELS
  checks <- list(
    estado_civil = censosbo:::.harmonize_estado_civil(1:6, 2012L),
    pea          = censosbo:::.harmonize_pea(1:3, 2024L),
    pet          = censosbo:::.harmonize_pet(c(1, 2), 2024L),
    nivel_edu    = censosbo:::.harmonize_nivel_edu(1:4, 2024L)
  )
  for (v in names(checks)) {
    codigos <- unique(stats::na.omit(checks[[v]]))
    expect_true(all(as.character(codigos) %in% names(labs[[v]])),
                info = paste("variable", v))
  }
})

test_that("grupo_edad se calcula desde edad individual y es idéntico entre censos (bug A1)", {
  h <- function(x, a) censosbo:::.harmonize_col(x, "grupo_edad", a)
  esperado <- c(0L, 0L, 5L, 5L, 20L, NA)
  entrada  <- c(0, 4, 5, 9, 23, NA)
  # El binning quinquenal debe ser idéntico en TODOS los años (incl. 1976 y 1992,
  # que antes usaban variables ya agrupadas y rompían la comparación).
  for (a in c(1976L, 1992L, 2001L, 2012L, 2024L)) {
    expect_equal(h(entrada, a), esperado, info = paste("año", a))
  }
})

test_that("grupo_edad apunta a la edad individual en el mapa (no a edad5/GEDAD)", {
  e <- new.env()
  utils::data("variable_temporal_map", package = "censosbo", envir = e)
  vtm <- get("variable_temporal_map", envir = e)
  fila <- vtm[vtm$variable == "grupo_edad", ]
  expect_equal(fila$v1976, "p04")   # antes "edad5"
  expect_equal(fila$v1992, "P04")   # antes "GEDAD"
})

test_that("sexo se armoniza a 1=Mujer, 2=Hombre (invertido en 1976/1992/2001)", {
  h <- censosbo:::.harmonize_sexo
  expect_equal(h(c(1, 2), 1992L), c(2L, 1L))  # invierte
  expect_equal(h(c(1, 2), 2024L), c(1L, 2L))  # ya correcto
})

test_that("nivel_edu se armoniza a 0=Sin instrucción .. 3=Superior por año", {
  h <- censosbo:::.harmonize_nivel_edu
  expect_equal(h(c(1, 2, 3, 4), 2024L), c(0L, 1L, 2L, 3L))
  expect_equal(h(c(1, 2, 3), 1976L), c(0L, 1L, 2L))
  expect_equal(h(c(11, 13, 15, 18), 2001L), c(0L, 1L, 2L, 3L))
})

test_that("sabe_leer y asistencia_escolar respetan las codificaciones invertidas", {
  expect_equal(censosbo:::.harmonize_sabe_leer(c(7, 8), 1992L), c(1L, 2L))
  # 2001 P37 invertido: 1=NO asiste -> 2 ; 2/3=SÍ -> 1
  expect_equal(censosbo:::.harmonize_asistencia_escolar(c(1, 2, 3), 2001L), c(2L, 1L, 1L))
})

test_that("categoria_ocupacion mapea empleado/obrero a 1 en todos los años", {
  h <- censosbo:::.harmonize_categoria_ocupacion
  expect_equal(h(2, 2024L), 1L)  # 2024: 2=Empleado/obrero -> 1
  expect_equal(h(1, 2012L), 1L)  # 2012: 1=Obrero/empleado -> 1
  expect_equal(h(3, 2001L), 1L)  # 2001: 3=Obrero/empleado -> 1
})

test_that("idioma_materno mapea castellano a 1 en 2001/2012/2024", {
  h <- censosbo:::.harmonize_idioma_materno
  expect_equal(h(3, 2001L), 1L)   # 2001: 3=Castellano
  expect_equal(h(6, 2012L), 1L)   # 2012/2024: 6=Castellano
  expect_equal(h(27, 2024L), 2L)  # 27=Quechua
})

test_that("armonizadores de vivienda mapean a las categorías comunes", {
  # agua: cañería/red -> 1 en su codificación por año
  expect_equal(censosbo:::.harmonize_agua(1, 2001L), 1L)
  # energía 2001 usa 5=Sí, 6=No
  expect_equal(censosbo:::.harmonize_energia(c(5, 6), 2001L), c(1L, 2L))
  # tenencia 2024: 1/2=Propia -> 1, 4=Alquilada -> 2
  expect_equal(censosbo:::.harmonize_tenencia(c(1, 2, 4), 2024L), c(1L, 1L, 2L))
})

test_that("parentesco está marcada como no armonizada en el mapa", {
  e <- new.env()
  utils::data("variable_temporal_map", package = "censosbo", envir = e)
  vtm <- get("variable_temporal_map", envir = e)
  expect_false(vtm$armonizada[vtm$variable == "parentesco"])
  expect_true(vtm$armonizada[vtm$variable == "estado_civil"])
})

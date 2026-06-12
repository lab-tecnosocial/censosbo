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

test_that("parentesco está marcada como no armonizada en el mapa", {
  e <- new.env()
  utils::data("variable_temporal_map", package = "censosbo", envir = e)
  vtm <- get("variable_temporal_map", envir = e)
  expect_false(vtm$armonizada[vtm$variable == "parentesco"])
  expect_true(vtm$armonizada[vtm$variable == "estado_civil"])
})

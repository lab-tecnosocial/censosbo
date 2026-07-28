test_that("etiquetar_valores() usa etiquetas armonizadas en datos de get_temporal()", {
  # Datos como los que produce get_temporal(): columna `anio` + variable armonizada.
  # nivel_edu armonizado usa 0=Sin instrucción .. 3=Superior, distinto del codebook 2024.
  df <- data.frame(
    anio      = c(2012L, 2012L, 2024L, 2024L),
    nivel_edu = c(0L, 3L, 0L, 3L),
    n         = c(10L, 20L, 30L, 40L)
  )
  res <- etiquetar_valores(df)
  expect_s3_class(res$nivel_edu, "factor")
  expect_equal(as.character(res$nivel_edu), c("Sin instrucción", "Superior",
                                              "Sin instrucción", "Superior"))
})

test_that("etiquetar_valores() etiqueta estado_civil/pea/pet armonizados", {
  df <- data.frame(
    anio         = c(1992L, 2024L),
    estado_civil = c(1L, 1L),   # armonizado: 1 = Soltero/a
    pet          = c(1L, 2L),   # 1 = Sí, 2 = No
    n            = c(5L, 5L)
  )
  res <- etiquetar_valores(df)
  expect_equal(as.character(res$estado_civil), c("Soltero/a", "Soltero/a"))
  expect_equal(as.character(res$pet), c("Sí", "No"))
})

test_that("etiquetar_valores() detecta datos temporales sin columna anio", {
  # estado_civil es un nombre armonizado que no colisiona con columnas crudas:
  # debe etiquetarse aunque se haya descartado la columna `anio`.
  df <- data.frame(estado_civil = c(1L, 4L), n = c(5L, 5L))
  res <- etiquetar_valores(df)
  expect_equal(as.character(res$estado_civil), c("Soltero/a", "Viudo/a"))
})

test_that("etiquetar_valores() no toca variables passthrough en datos temporales", {
  # parentesco es passthrough (códigos varían por censo): no debe etiquetarse.
  df <- data.frame(anio = c(1992L, 2024L), parentesco = c(1L, 1L), n = c(5L, 5L))
  res <- etiquetar_valores(df)
  expect_type(res$parentesco, "integer")
})

test_that("etiquetar_valores() sigue usando el diccionario por censo en datos crudos", {
  # Sin columna `anio`: debe detectar el censo y usar el codebook correspondiente.
  df <- data.frame(p25_sexo = c(1L, 2L))
  res <- etiquetar_valores(df)
  expect_s3_class(res$p25_sexo, "factor")
  expect_equal(as.character(res$p25_sexo), c("Mujer", "Hombre"))
})

test_that("etiquetar_valores() etiqueta `area` de forma determinista (bug #1)", {
  # `area` (persona) debe etiquetarse igual sin importar qué otra columna
  # acompañe: antes dependía de la detección del censo (área solo estaba en 1976).
  r1 <- etiquetar_valores(data.frame(area = c(1L, 2L), n = c(10L, 20L)))
  r2 <- etiquetar_valores(data.frame(area = c(1L, 2L), p26_edad = c(30L, 40L)))
  expect_s3_class(r1$area, "factor")
  expect_s3_class(r2$area, "factor")
  expect_equal(as.character(r1$area), c("Urbana", "Rural"))
  expect_equal(as.character(r2$area), as.character(r1$area))
})

test_that("etiquetar_valores() avisa y deja cruda una columna que no matchea el censo", {
  # p25_sexo es de 2024 pero 7/8 no son códigos válidos -> aviso + columna cruda.
  df <- data.frame(p25_sexo = c(7L, 8L))
  expect_warning(res <- etiquetar_valores(df), "no coinciden")
  expect_type(res$p25_sexo, "integer")  # se conserva cruda, no toda-NA
})

test_that("las etiquetas armonizadas cubren las variables armonizadas categóricas", {
  # Toda variable con etiquetas debe existir en variable_temporal_map.
  e <- new.env()
  utils::data("variable_temporal_map", package = "censosbo", envir = e)
  vtm <- get("variable_temporal_map", envir = e)
  expect_true(all(names(censosbo:::.HARMONIZED_VALUE_LABELS) %in% vtm$variable))
})

test_that("etiquetar_variables() conserva el nombre cuando la etiqueta está vacía", {
  # 11 variables derivadas del censo 1976 no traen descripción en el diccionario
  # del INE; renombrarlas a "" dejaría columnas sin nombre (y duplicadas).
  df <- data.frame(nivela = 1:3, pea = c(1L, 2L, 3L), p03 = c(1L, 2L, 1L))
  res <- etiquetar_variables(df, anio = 1976)
  expect_true(all(nzchar(names(res))))
  expect_equal(names(res)[1:2], c("nivela", "pea"))
  expect_equal(names(res)[3], "SEXO")   # esta sí tiene etiqueta
})

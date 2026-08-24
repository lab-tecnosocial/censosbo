# El universo de los tabulados oficiales: residencia habitual + edad mínima.
#
# Contexto: los cuadros temáticos del INE llevan al pie «No incluye personas que
# residen habitualmente en el exterior». Sin esa exclusión, un conteo correcto
# sobre los microdatos no cuadra con el cuadro equivalente y no hay forma de
# saber por qué: la diferencia es difusa (~1% repartido por todos los municipios
# y todos los grupos de edad), no se concentra en ningún sitio.
#
# Estos tests son sintéticos y rápidos. El cuadre real contra las cifras
# publicadas está en test-reconciliacion-oficial.R.

muestra_2024 <- function() {
  data.frame(
    p26_edad   = c(2L, 4L, 5L, 30L, 30L, 70L),
    p36_lugres = c(1L, 1L, 2L, 3L,  9L,  1L),
    idioma_mat = c(6L, 6L, 27L, 6L, 2L,  27L)
  )
}

test_that("excluye a quienes residen habitualmente en el exterior", {
  # De las seis filas se van dos: la del código 3 (otro país) y la del 9
  # (sin especificar), que en 2024 el INE también deja fuera.
  out <- universo_ine(muestra_2024(), 2024)
  expect_equal(nrow(out), 4L)
  expect_false(any(out$p36_lugres %in% c(3L, 9L)))
})

test_that("edad_min recorta por edad cumplida, no por grupo", {
  out <- universo_ine(muestra_2024(), 2024, edad_min = 4)
  expect_equal(nrow(out), 3L)          # se va además la persona de 2 años
  expect_true(all(out$p26_edad >= 4))

  # 6 es el universo de idioma de mayor uso y de idiomas hablados: de las tres
  # que quedaban se va también la de 5 años.
  expect_equal(nrow(universo_ine(muestra_2024(), 2024, edad_min = 6)), 1L)
})

test_that("sin edad_min no filtra por edad", {
  out <- universo_ine(muestra_2024(), 2024)
  expect_true(2L %in% out$p26_edad)
})

test_that("2012 y 2001 usan sus propios nombres de columna", {
  # En los dos censos la pregunta es P33A y no tiene categoría «sin especificar»:
  # solo se excluye el 3 (en el exterior).
  d12 <- data.frame(P25 = c(3L, 8L, 40L), P33A = c(1L, 3L, 2L))
  expect_equal(nrow(universo_ine(d12, 2012)), 2L)
  expect_equal(nrow(universo_ine(d12, 2012, edad_min = 6)), 1L)

  d01 <- data.frame(P29 = c(3L, 8L, 40L), P33A = c(1L, 3L, 2L))
  expect_equal(nrow(universo_ine(d01, 2001)), 2L)
})

test_that("el error por columnas ausentes dice cuáles pedir", {
  # El consejo del mensaje tiene que poder copiarse y ejecutarse: nombra las
  # variables que faltan y la función con la que se piden.
  sin_residencia <- data.frame(p26_edad = 30L, idioma_mat = 6L)
  expect_error(universo_ine(sin_residencia, 2024), "p36_lugres")
  expect_error(universo_ine(sin_residencia, 2024), "get_personas_2024")

  # La edad solo hace falta si se pide edad_min.
  sin_edad <- data.frame(p36_lugres = 1L, idioma_mat = 6L)
  expect_no_error(universo_ine(sin_edad, 2024))
  expect_error(universo_ine(sin_edad, 2024, edad_min = 4), "p26_edad")
})

test_that("los censos sin equivalencia verificada abortan con el motivo", {
  d <- data.frame(p06 = 1L)
  expect_error(universo_ine(d, 1976), "2001")   # lista los años disponibles
  expect_error(universo_ine(d, 1992), "verificada")
  expect_error(universo_ine(d, "dos mil"), "anio")
})

test_that("edad_min se valida", {
  expect_error(universo_ine(muestra_2024(), 2024, edad_min = -1), "edad_min")
  expect_error(universo_ine(muestra_2024(), 2024, edad_min = "cuatro"), "edad_min")
})

test_that("conserva el tipo de objeto con Arrow", {
  skip_if_not_installed("arrow")
  ds <- arrow::as_arrow_table(muestra_2024())
  out <- universo_ine(ds, 2024, edad_min = 4)
  # Sigue siendo perezoso: hay que hacer collect() para ver las filas.
  expect_s3_class(out, "arrow_dplyr_query")
  expect_equal(nrow(dplyr::collect(out)), 3L)
})

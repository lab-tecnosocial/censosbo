# Tests del universo de vivienda: qué registros de la entidad `vivienda` cuentan
# como viviendas. Todos offline: se filtra un dataset arrow sintético con el
# mismo esquema que los releases.

skip_if_not_installed("arrow")

# Un registro por cada código de tipo de vivienda del CPV-2024 (1-16), más las
# columnas geográficas y una variable cualquiera para probar `variables`.
.ds_viv_2024 <- function() {
  arrow::arrow_table(data.frame(
    idep        = rep("01", 16),
    iprov       = rep("01", 16),
    imun        = rep("01", 16),
    i00         = sprintf("%05d", 1:16),
    urbrur      = rep(1L, 16),
    v01_tipoviv = 1:16,
    v07_aguapro = rep(1L, 16),
    stringsAsFactors = FALSE
  ))
}

test_that("tipos_vivienda() clasifica los códigos de los cinco censos", {
  t24 <- tipos_vivienda(2024)
  expect_equal(nrow(t24), 16L)
  expect_equal(t24$codigo[t24$grupo == "no_vivienda"], 15:16)
  expect_equal(sum(t24$grupo == "particular"), 6L)
  expect_equal(sum(t24$grupo == "colectiva"), 8L)
  expect_true(all(t24$en_universo_viviendas == (t24$grupo != "no_vivienda")))
  expect_match(t24$etiqueta[t24$codigo == 15], "calle")
  expect_match(t24$etiqueta[t24$codigo == 16], "tránsito")

  # Los censos anteriores tienen las mismas categorías con otros códigos.
  expect_equal(tipos_vivienda(1992)$codigo[tipos_vivienda(1992)$grupo == "no_vivienda"], 13L)
  expect_equal(tipos_vivienda(2001)$codigo[tipos_vivienda(2001)$grupo == "no_vivienda"], 24L)
  expect_equal(tipos_vivienda(2012)$codigo[tipos_vivienda(2012)$grupo == "no_vivienda"], 7:8)

  # 1976 no preguntó por calle ni tránsito.
  expect_equal(sum(tipos_vivienda(1976)$grupo == "no_vivienda"), 0L)

  # Los códigos que están en los microdatos pero no en el diccionario se
  # muestran como sin_clasificar, y se conservan en el universo de viviendas.
  s76 <- tipos_vivienda(1976)
  expect_equal(s76$codigo[s76$grupo == "sin_clasificar"], 88L)
  expect_true(s76$en_universo_viviendas[s76$codigo == 88])

  expect_error(tipos_vivienda(2020), "no reconocido")
})

test_that(".codigos_universo_vivienda() traduce cada universo a códigos", {
  expect_null(censosbo:::.codigos_universo_vivienda(2024, "todos"))
  expect_equal(censosbo:::.codigos_universo_vivienda(2024, "viviendas"), 1:14)
  expect_equal(censosbo:::.codigos_universo_vivienda(2024, "particulares"), 1:6)
  expect_equal(censosbo:::.codigos_universo_vivienda(2024, "colectivas"), 7:14)

  # 1976: sin categorías de calle/tránsito, "viviendas" no filtra nada.
  expect_null(censosbo:::.codigos_universo_vivienda(1976, "viviendas"))
  expect_equal(censosbo:::.codigos_universo_vivienda(1976, "particulares"), 11:17)

  # 1992 conserva el código 0, que no está en el diccionario, en "viviendas"
  # pero no en las selecciones positivas.
  expect_true(0L %in% censosbo:::.codigos_universo_vivienda(1992, "viviendas"))
  expect_false(0L %in% censosbo:::.codigos_universo_vivienda(1992, "particulares"))
})

test_that(".filtrar_universo_vivienda() deja pasar los registros correctos", {
  ds <- .ds_viv_2024()
  f <- function(u) {
    dplyr::collect(censosbo:::.filtrar_universo_vivienda(ds, 2024L, u, verbose = FALSE))
  }
  expect_equal(nrow(f("todos")), 16L)
  expect_equal(sort(f("viviendas")$v01_tipoviv), 1:14)
  expect_equal(sort(f("particulares")$v01_tipoviv), 1:6)
  expect_equal(sort(f("colectivas")$v01_tipoviv), 7:14)

  # 1976 con "viviendas" no filtra, y no exige la columna de tipo.
  ds76 <- arrow::arrow_table(data.frame(idep = "01", turrur = 1L))
  expect_equal(
    nrow(dplyr::collect(censosbo:::.filtrar_universo_vivienda(ds76, 1976L, "viviendas", verbose = FALSE))),
    1L
  )
})

test_that("aplicar un universo sin la columna de tipo aborta con una pista", {
  ds <- dplyr::select(.ds_viv_2024(), "idep", "urbrur")
  expect_error(
    censosbo:::.filtrar_universo_vivienda(ds, 2024L, "viviendas", verbose = FALSE),
    "v01_tipoviv"
  )
})

test_that(".con_columna_universo() conserva la columna de tipo cuando hace falta", {
  # NULL = todas las columnas: no hay nada que conservar.
  expect_null(censosbo:::.con_columna_universo(NULL, 2024L, "viviendas"))
  # Con selección explícita, se añade la columna del filtro.
  expect_equal(
    censosbo:::.con_columna_universo(c("urbrur"), 2024L, "viviendas"),
    c("urbrur", "v01_tipoviv")
  )
  # Sin filtro que aplicar, la selección queda intacta.
  expect_equal(censosbo:::.con_columna_universo("urbrur", 2024L, "todos"), "urbrur")
  expect_equal(censosbo:::.con_columna_universo("v01", 1976L, "viviendas"), "v01")
  # Si el usuario ya la pidió, no se duplica.
  expect_equal(
    censosbo:::.con_columna_universo(c("v01_tipoviv", "urbrur"), 2024L, "colectivas"),
    c("v01_tipoviv", "urbrur")
  )
})

test_that("`universo` solo se acepta en la tabla de vivienda", {
  expect_error(censosbo:::.check_universo_tabla("colectivas", "persona"), "solo aplica")
  expect_silent(censosbo:::.check_universo_tabla("todos", "persona"))
  expect_silent(censosbo:::.check_universo_tabla("colectivas", "vivienda"))

  # get_censo() no debe abortar por el DEFECTO de `universo` en otras tablas:
  # solo cuando el usuario lo pide de forma explícita.
  expect_error(get_censo(2012, "persona", universo = "colectivas"), "solo aplica")
})

test_that("el aviso del universo se emite una sola vez por sesión", {
  ds <- .ds_viv_2024()
  rm(list = ls(envir = censosbo:::.censosbo_avisos), envir = censosbo:::.censosbo_avisos)
  expect_message(
    censosbo:::.filtrar_universo_vivienda(ds, 2024L, "viviendas", verbose = TRUE),
    "calle"
  )
  expect_no_message(
    censosbo:::.filtrar_universo_vivienda(ds, 2024L, "viviendas", verbose = TRUE)
  )
})

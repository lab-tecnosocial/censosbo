# Tests de las tablas agregadas por manzano y comunidad (CPV-2024).
# Todos offline: se construye un dataset arrow sintético con el mismo esquema
# que el release, en vez de tocar la red.

skip_if_not_installed("arrow")

.ds_unidades <- function() {
  arrow::arrow_table(data.frame(
    codigo    = c("00000000001-A", "00000000002-A", "00000000003-D", "00000000004-D"),
    area      = c(1L, 1L, 2L, 2L),  # 1 = Urbana, 2 = Rural (igual que en microdatos)
    idep      = c("01", "03", "01", "05"),
    iprov     = c("01", "01", "01", "01"),
    imun      = c("01", "01", "02", "01"),
    nombre    = c("MZ 1", "MZ 2", "COM 1", "COM 2"),
    personas  = c(100L, 200L, 30L, 40L),
    viviendas = c(40L, 80L, 12L, 15L),
    ficha     = c(TRUE, TRUE, FALSE, TRUE),
    stringsAsFactors = FALSE
  ))
}

test_that(".apply_area filtra por área y valida el argumento", {
  ds <- .ds_unidades()

  expect_equal(nrow(dplyr::collect(censosbo:::.apply_area(ds, NULL))), 4L)
  expect_equal(nrow(dplyr::collect(censosbo:::.apply_area(ds, "urbano"))), 2L)
  expect_equal(nrow(dplyr::collect(censosbo:::.apply_area(ds, "rural"))), 2L)
  expect_equal(nrow(dplyr::collect(censosbo:::.apply_area(ds, c("urbano", "rural")))), 4L)

  # Mayúsculas y minúsculas dan igual; los códigos crudos también valen.
  expect_equal(nrow(dplyr::collect(censosbo:::.apply_area(ds, "URBANO"))), 2L)
  expect_equal(nrow(dplyr::collect(censosbo:::.apply_area(ds, 2))), 2L)
  expect_error(censosbo:::.apply_area(ds, "periurbano"), "no reconocido")
})

test_that("el filtro geográfico funciona sobre el esquema de unidades", {
  ds  <- .ds_unidades()
  geo <- censosbo:::.resolve_geo(departamento = "Chuquisaca", municipio = "Sucre")
  out <- dplyr::collect(censosbo:::.apply_geo(ds, geo))

  expect_equal(nrow(out), 1L)
  expect_equal(out$codigo, "00000000001-A")
})

test_that("area y geografía se combinan", {
  ds  <- .ds_unidades()
  geo <- censosbo:::.resolve_geo(departamento = "Chuquisaca")
  out <- dplyr::collect(censosbo:::.apply_area(censosbo:::.apply_geo(ds, geo), "rural"))

  expect_equal(nrow(out), 1L)
  expect_equal(out$area, 2L)
})

test_that("el filtro por departamento se aplica a un archivo nacional", {
  # Las comunidades rurales van en un solo Parquet para todo el país, así que
  # el filtro por departamento tiene que aplicarse sobre los datos y no puede
  # delegarse en la selección de archivos como en los manzanos.
  ds <- .ds_unidades()
  geo <- censosbo:::.resolve_geo(departamento = "Chuquisaca")
  out <- dplyr::collect(censosbo:::.apply_geo(ds, geo, filter_dep = TRUE))

  expect_equal(nrow(out), 2L)
  expect_true(all(out$idep == "01"))
})

test_that("las variables de ficha están documentadas en el codebook", {
  cb <- codebook(tabla = "ficha")

  expect_s3_class(cb, "data.frame")
  # 194 indicadores (160 de campos.csv + 34 de campos_vivienda.csv)
  # más codigo, area, idep, iprov, imun
  expect_equal(nrow(cb), 199L)
  expect_true(all(c("pob_total_h", "serv_agua_caneria", "tic_internet",
                    "mat_pared_ladrillo", "hac_sin", "hogar_unipersonal") %in% cb$variable))
  expect_false(any(is.na(cb$etiqueta)))
  expect_false(any(cb$etiqueta == ""))

  # Los indicadores son conteos: numéricos, sin códigos de valor.
  ind <- cb[!cb$variable %in% c("codigo", "area", "idep", "iprov", "imun"), ]
  expect_true(all(ind$tipo == "numerica"))
  expect_true(all(vapply(ind$valores_codigos, is.null, logical(1))))
})

test_that("la tabla unidad está documentada y area trae sus categorías", {
  cb <- codebook(tabla = "unidad")
  expect_equal(nrow(cb), 9L)
  expect_true(all(c("personas", "viviendas", "ficha", "nombre") %in% cb$variable))

  # `area` usa el mismo dominio que en los microdatos, así que las tres tablas
  # que la declaran (persona, unidad, ficha) deben coincidir exactamente.
  todas <- codebook(variable = "area")
  expect_equal(nrow(todas), 3L)
  dominios <- unique(lapply(todas$valores_codigos, function(x) x[order(x$codigo), ]))
  expect_length(dominios, 1L)
  expect_setequal(dominios[[1]]$codigo, c("1", "2"))
  expect_setequal(dominios[[1]]$etiqueta, c("Urbana", "Rural"))
})

test_that("los bloques de la ficha de vivienda están completos", {
  cb <- codebook(tabla = "ficha")
  bloques <- list(
    mat_pared_   = 7, mat_revoque_ = 2, mat_techo_ = 5, mat_piso_ = 9,
    hac_         = 3, hogar_       = 8
  )
  for (pref in names(bloques)) {
    n <- sum(startsWith(cb$variable, pref))
    expect_equal(n, bloques[[pref]],
                 info = paste("bloque", pref, "debería tener", bloques[[pref]], "variables"))
  }
  # 34 en total: son los que vienen de la ficha ampliada de vivienda.
  expect_equal(sum(vapply(names(bloques), function(p) sum(startsWith(cb$variable, p)),
                          integer(1))), 34L)
})

test_that("los nombres de variable de ficha son ASCII (R CMD check)", {
  cb <- codebook(tabla = "ficha")
  expect_false(any(grepl("[^ -~]", cb$variable)))
})

test_that("mapa_man valida sus argumentos antes de tocar la red", {
  datos <- data.frame(codigo = "00000000001-A", valor = 1)

  expect_error(mapa_man(datos, "valor"), "municipio")
  expect_error(mapa_man(datos, c("a", "b"), municipio = "Sucre"), "variable")
  expect_error(mapa_man(datos, "inexistente", municipio = "Sucre"), "no existe")
  expect_error(
    mapa_man(data.frame(x = 1), "x", municipio = "Sucre"),
    "codigo"
  )
})

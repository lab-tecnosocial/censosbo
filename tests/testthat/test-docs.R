## codebook_docs_meta y codebook_docs(): la documentación conceptual del INE.

test_that("codebook_docs_meta cubre los cinco censos", {
  expect_equal(nrow(codebook_docs_meta), 445)
  expect_setequal(unique(codebook_docs_meta$anio), c(2024, 2012, 2001, 1992, 1976))
  # 2024 aporta las 184 variables de su DDI; los anteriores solo las que tienen par
  # en el codebook del paquete (el resto son texto abierto y claves de REDATAM).
  expect_equal(sum(codebook_docs_meta$anio == 2024), 184)
  expect_equal(sum(codebook_docs_meta$anio == 1992), 76)
  expect_equal(sum(codebook_docs_meta$anio == 1976), 53)
})

test_that("toda variable documentada tiene definición", {
  expect_false(anyNA(codebook_docs_meta$definicion))
  expect_true(all(nchar(codebook_docs_meta$definicion) > 10))
})

test_that("cada fila de docs existe en el codebook del mismo año", {
  for (anio in c(2024, 2012, 2001, 1992, 1976)) {
    docs <- codebook_docs_meta[codebook_docs_meta$anio == anio, ]
    cb <- if (anio == 2024) codebook_meta else codebook_historico_meta[[as.character(anio)]]
    expect_identical(
      setdiff(paste(docs$tabla, docs$variable), paste(cb$tabla, cb$variable)),
      character(0), info = paste("censo", anio)
    )
  }
})

test_that("notas y regla_derivacion solo existen donde el DDI las trae", {
  # El DDI de 2012 y 2001 no tiene <notes> ni (salvo un caso) <codInstr>.
  d12 <- codebook_docs_meta[codebook_docs_meta$anio == 2012, ]
  expect_true(all(is.na(d12$notas)))
  expect_true(all(is.na(d12$regla_derivacion)))
  # En 2024 hay 45 reglas de derivación, y `notes` solo existe en ese año.
  d24 <- codebook_docs_meta[codebook_docs_meta$anio == 2024, ]
  expect_gt(sum(!is.na(d24$notas)), 100)
  expect_equal(sum(!is.na(d24$regla_derivacion)), 45)
  expect_equal(sum(!is.na(codebook_docs_meta$notas)), sum(!is.na(d24$notas)))
})

test_that("las variables con regla de derivación son las marcadas como derivadas", {
  d24 <- codebook_docs_meta[codebook_docs_meta$anio == 2024 &
                              !is.na(codebook_docs_meta$regla_derivacion), ]
  origen <- codebook_meta$origen[match(paste(d24$tabla, d24$variable),
                                       paste(codebook_meta$tabla, codebook_meta$variable))]
  expect_true(all(origen == "derivada"))
})

test_that("informante está normalizado", {
  vocab <- c("jefe_hogar", "persona_misma", "empadronador", "observacion")
  expect_identical(setdiff(stats::na.omit(codebook_docs_meta$informante), vocab), character(0))
})

test_that("el atributo de procedencia registra los cinco DDI usados", {
  ddi <- attr(codebook_docs_meta, "ddi")
  expect_false(is.null(ddi))
  expect_setequal(ddi$anio, c(2024, 2012, 2001, 1992, 1976))
  expect_setequal(ddi$estudio, c(132, 8, 10, 47, 46))
  expect_true(all(nchar(ddi$sha256) == 64))
  expect_true(all(grepl("^https://anda\\.ine\\.gob\\.bo/", ddi$url)))
})

test_that("codebook_docs() devuelve una fila por variable y año", {
  d <- codebook_docs("p40_lee")
  expect_equal(nrow(d), 1)
  expect_true(grepl("leer", d$definicion, ignore.case = TRUE))
  # El universo literal reproduce el filtro impreso en el cuestionario.
  expect_true(grepl("5 años", d$universo_literal))
})

test_that("codebook_docs() selecciona campos y valida su nombre", {
  d <- codebook_docs("nivel_edu", campos = "regla_derivacion")
  expect_named(d, c("anio", "variable", "tabla", "regla_derivacion"))
  expect_true(grepl("P41A_NIVEL_ACT", d$regla_derivacion))
  expect_error(codebook_docs("p40_lee", campos = "no_existe"), "no reconocido")
})

test_that("codebook_docs() desambigua por tabla y avisa cuando no se indica", {
  expect_message(codebook_docs("idep"), "varias tablas")
  expect_equal(nrow(codebook_docs("idep", tabla = "persona")), 1)
})

test_that("codebook_docs() funciona en los cinco censos", {
  expect_equal(nrow(codebook_docs("P24", anio = 2012)), 1)
  expect_equal(nrow(codebook_docs("P03", anio = 1992)), 1)
  expect_equal(nrow(codebook_docs("p03", tabla = "poblacion", anio = 1976)), 1)
  expect_error(codebook_docs("p40_lee", anio = 1900), "documentaci")
})

test_that("codebook_docs() informa en vez de fallar si no hay documentación", {
  expect_message(codebook_docs("variable_que_no_existe"), "Sin documentaci")
})

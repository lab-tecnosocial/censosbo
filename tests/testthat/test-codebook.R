test_that("codebook() devuelve un data.frame", {
  result <- codebook()
  expect_s3_class(result, "data.frame")
})

test_that("codebook() filtra por tabla", {
  # Con datos placeholder vacíos, solo verificamos que no da error
  result <- codebook(tabla = "persona")
  expect_s3_class(result, "data.frame")
})

test_that("codebook() filtra por búsqueda de texto", {
  result <- codebook(buscar = "inexistente_xyz_12345")
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0L)
})

test_that("tipo solo toma valores válidos y es consistente", {
  validos <- c("categorica", "numerica", "texto")
  metas <- c(list(`2024` = codebook_meta), codebook_historico_meta)
  for (nm in names(metas)) {
    meta <- metas[[nm]]
    expect_true(all(meta$tipo %in% validos),
                info = paste("tipos inválidos en censo", nm))
    # Solo las categóricas conservan categorías.
    tiene_vals <- !vapply(meta$valores_codigos, is.null, logical(1))
    expect_true(all(meta$tipo[tiene_vals] == "categorica"),
                info = paste("variable no categórica con valores en censo", nm))
  }
})

test_that("`area` (persona) está en el codebook 2024 con sus valores (bug #4)", {
  ca <- codebook("area")
  expect_true("persona" %in% ca$tabla)
  expect_equal(codebook("area")$tipo[1], "categorica")
  va <- codebook_valores("area")
  expect_s3_class(va, "data.frame")
  expect_equal(nrow(va), 2L)
  expect_equal(va$etiqueta, c("Urbana", "Rural"))
})

test_that("códigos numéricos categóricos se clasifican como categorica", {
  # Variables cuyos valores son números pero representan categorías.
  expect_equal(codebook("p25_sexo")$tipo, "categorica")
  # Código de clasificación con nombre tipo `cod` (antes marcado numerica).
  expect_equal(codebook("p35h_muncod")$tipo, "categorica")
  # Código de ocupación del censo 2001 sin etiquetas enumeradas.
  expect_equal(codebook("P33COD", anio = 2001)$tipo, "categorica")
})

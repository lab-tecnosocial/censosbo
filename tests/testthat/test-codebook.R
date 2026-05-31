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

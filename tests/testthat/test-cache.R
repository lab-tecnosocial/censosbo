test_that("censosbo_cache_dir() devuelve una cadena de caracteres", {
  d <- censosbo_cache_dir()
  expect_type(d, "character")
  expect_true(nchar(d) > 0)
})

test_that("censosbo_cache_info() retorna NULL o data.frame", {
  result <- censosbo_cache_info()
  expect_true(is.null(result) || is.data.frame(result))
})

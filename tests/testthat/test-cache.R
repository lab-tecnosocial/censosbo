test_that("censosbo_cache_dir() devuelve una cadena de caracteres", {
  d <- censosbo_cache_dir()
  expect_type(d, "character")
  expect_true(nchar(d) > 0)
})

test_that("censosbo_cache_info() retorna NULL o data.frame", {
  result <- censosbo_cache_info()
  expect_true(is.null(result) || is.data.frame(result))
})

test_that("censosbo_cache_clear() borra solo los .parquet y preserva otros archivos (bug R1)", {
  tmp <- file.path(tempdir(), paste0("censosbo-test-", as.integer(Sys.time())))
  dir.create(tmp)
  old <- options(censosbo.cache_dir = tmp)
  on.exit({ options(old); unlink(tmp, recursive = TRUE) }, add = TRUE)

  # Un parquet de censosbo, un subdir histórico y un archivo AJENO del usuario.
  writeLines("x", file.path(tmp, "vivienda.parquet"))
  dir.create(file.path(tmp, "historico", "1976"), recursive = TRUE)
  writeLines("x", file.path(tmp, "historico", "1976", "poblacion.parquet"))
  user_file <- file.path(tmp, "mis_datos.csv")
  writeLines(c("a,b", "1,2"), user_file)

  censosbo_cache_clear(ask = FALSE)

  expect_false(file.exists(file.path(tmp, "vivienda.parquet")))
  expect_false(file.exists(file.path(tmp, "historico", "1976", "poblacion.parquet")))
  expect_true(file.exists(user_file))  # archivo del usuario intacto
})

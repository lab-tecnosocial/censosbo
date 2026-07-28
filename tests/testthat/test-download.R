test_that(".curl_download_retry() reintenta ante un fallo transitorio", {
  # GitHub Releases devuelve 500/503 esporádicamente y antes eso abortaba toda
  # la operación (rompió una build de pkgdown al bajar geo_comunidad.parquet).
  dest <- withr::local_tempfile()
  intentos <- 0L
  falla_una_vez <- function(url, destfile, quiet = TRUE) {
    intentos <<- intentos + 1L
    if (intentos == 1L) stop("HTTP response code said error: 500")
    writeLines("contenido", destfile)
  }
  local_mocked_bindings(curl_download = falla_una_vez, .package = "curl")
  # espera = 0 para no dormir en los tests
  censosbo:::.curl_download_retry("http://x/y.parquet", dest, espera = 0)

  expect_equal(intentos, 2L)
  expect_true(file.exists(dest))
  expect_false(file.exists(paste0(dest, ".part")))
})

test_that(".curl_download_retry() aborta tras agotar los intentos y no deja .part", {
  dest <- withr::local_tempfile()
  siempre_falla <- function(url, destfile, quiet = TRUE) {
    writeLines("parcial", destfile)   # deja un archivo a medias, como una descarga cortada
    stop("HTTP response code said error: 500")
  }
  local_mocked_bindings(curl_download = siempre_falla, .package = "curl")
  expect_error(
    censosbo:::.curl_download_retry("http://x/y.parquet", dest, intentos = 2L, espera = 0),
    "500"
  )
  # Ni el destino (caché envenenado con un Parquet truncado) ni el temporal.
  expect_false(file.exists(dest))
  expect_false(file.exists(paste0(dest, ".part")))
})

test_that(".curl_download_retry() renombra solo al completar", {
  dest <- withr::local_tempfile()
  local_mocked_bindings(
    curl_download = function(url, destfile, quiet = TRUE) {
      # El contenido debe estar en el .part mientras se descarga, no en dest.
      expect_equal(destfile, paste0(dest, ".part"))
      expect_false(file.exists(dest))
      writeLines("ok", destfile)
    },
    .package = "curl"
  )
  censosbo:::.curl_download_retry("http://x/y.parquet", dest, espera = 0)
  expect_equal(readLines(dest), "ok")
})

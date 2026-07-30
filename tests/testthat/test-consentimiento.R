# El caché persistente se crea sin preguntar nada: descargar implica cachear. La 2.0.0
# enviada a CRAN pedía confirmación en sesión interactiva; se retiró en la 2.0.0.9000
# (el porqué está en R/cache.R, junto al bloque comentado que la reactiva).
#
# Estos tests no se borraron con el prompt, por dos razones:
#
#   1. Fijan el comportamiento actual —nunca pregunta, en ningún escenario— para que
#      nadie lo reintroduzca sin darse cuenta.
#   2. Guardan el contrato que hay que respetar SI se reactiva: en sesión no interactiva
#      se procede sin preguntar y sin imprimir nada. La app censos-explorer descarga
#      geometrías en un contenedor sin tty, y un prompt que abortara ahí la rompería en
#      silencio.
#
# TODOS redirigen el caché del sistema con R_USER_CACHE_DIR —la variable que consulta
# tools::R_user_dir()— a un tempdir. No es higiene opcional: la lógica de consentimiento
# daba por autorizado un directorio raíz que ya existiera, así que en la máquina de
# quien tiene censosbo en uso los tests pasaban sin ejercitar nada y solo fallaban en
# CI. Pasó de verdad. Fijar la opción censosbo.cache_dir NO sirve para esto: marca la
# ruta como elegida por el usuario, que es otro camino distinto.
.cache_aislado <- function(env = parent.frame()) {
  tmp <- withr::local_tempdir(.local_envir = env)
  withr::local_envvar(R_USER_CACHE_DIR = file.path(tmp, "xdg-cache"), .local_envir = env)
  tmp
}

test_that("el cache se crea sin preguntar, tambien en sesion interactiva", {
  tmp <- .cache_aislado()
  destino <- file.path(tmp, "cache-nueva", "sub")

  withr::local_options(
    rlang_interactive  = TRUE,
    censosbo.cache_dir = NULL,
    censosbo.consent   = NULL
  )
  # Si alguien reintroduce un prompt sin actualizar estos tests, este mock lo delata.
  local_mocked_bindings(
    .preguntar_si_no = function(...) stop("el cache no debe pedir confirmacion")
  )

  expect_silent(.asegurar_cache_dir(destino))
  expect_true(dir.exists(destino))
})

test_that("en sesion NO interactiva crea el cache sin preguntar ni imprimir", {
  # El contrato del que dependen los consumidores headless (censos-explorer en Docker).
  # Si se reactiva el consentimiento, este test tiene que seguir pasando.
  tmp <- .cache_aislado()
  destino <- file.path(tmp, "cache-nueva")

  withr::local_options(
    rlang_interactive  = FALSE,
    censosbo.cache_dir = NULL,
    censosbo.consent   = NULL
  )
  local_mocked_bindings(
    .preguntar_si_no = function(...) stop("no debe preguntar en sesion no interactiva")
  )

  expect_silent(.asegurar_cache_dir(destino))
  expect_true(dir.exists(destino))
})

test_that("crea los subdirectorios que hagan falta", {
  # Las fichas por manzano y los censos historicos cachean en subdirectorios propios.
  tmp <- .cache_aislado()
  destino <- file.path(tmp, "raiz", "fichas", "geo")
  withr::local_options(rlang_interactive = FALSE)
  expect_silent(.asegurar_cache_dir(destino))
  expect_true(dir.exists(destino))
})

test_that("si el directorio ya existe no hace nada", {
  tmp <- .cache_aislado()
  expect_silent(.asegurar_cache_dir(tmp))
  expect_true(dir.exists(tmp))
})

test_that("las opciones de cache_dir y consent siguen reconocidas", {
  # Se mantienen vivas para que reactivar el consentimiento no exija tocar nada mas.
  tmp <- .cache_aislado()
  withr::local_options(censosbo.cache_dir = file.path(tmp, "mi-proyecto"))
  expect_identical(censosbo_cache_dir(), file.path(tmp, "mi-proyecto"))

  withr::local_options(censosbo.cache_dir = NULL)
  expect_match(censosbo_cache_dir(), "censosbo")
})

test_that("censosbo_cache_clear si pide confirmacion, y lo dice cuando no puede", {
  # Borrar es lo unico irreversible, y ahi la confirmacion se queda. En una sesion sin
  # tty no cancela en silencio —el bug que tenia— sino que aborta explicando la salida.
  tmp <- .cache_aislado()
  raiz <- censosbo_cache_dir()
  dir.create(raiz, recursive = TRUE, showWarnings = FALSE)
  file.create(file.path(raiz, "persona_dep09.parquet"))

  withr::local_options(rlang_interactive = FALSE)
  err <- expect_error(censosbo_cache_clear(ask = TRUE))
  expect_match(conditionMessage(err), "ask = FALSE", fixed = TRUE)
  expect_true(file.exists(file.path(raiz, "persona_dep09.parquet")))

  # Con ask = FALSE si borra.
  expect_no_error(censosbo_cache_clear(ask = FALSE))
  expect_false(file.exists(file.path(raiz, "persona_dep09.parquet")))
})

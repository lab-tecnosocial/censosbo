# El caché persistente necesita permiso del usuario (política de CRAN), pero pedirlo
# mal rompe a los consumidores headless: la app censos-explorer corre en un
# contenedor sin tty y descarga ahí las geometrías de manzanos y comunidades. Estos
# tests fijan el contrato de .asegurar_cache_dir() en las cuatro situaciones, y el
# primero es el que no debe cambiar nunca sin avisar a esos consumidores.

test_that("en sesion NO interactiva crea el cache sin preguntar", {
  tmp <- withr::local_tempdir()
  destino <- file.path(tmp, "cache-nueva", "sub")

  withr::local_options(
    rlang_interactive   = FALSE,
    censosbo.cache_dir  = NULL,
    censosbo.consent    = NULL
  )
  # Si el codigo llegara a preguntar, este mock lo delata en vez de dejar pasar un
  # falso verde.
  local_mocked_bindings(
    .preguntar_si_no = function(...) stop("no debe preguntar en sesion no interactiva")
  )

  expect_no_error(.asegurar_cache_dir(destino))
  expect_true(dir.exists(destino))
})

test_that("con censosbo.consent = TRUE no pregunta ni siendo interactiva", {
  tmp <- withr::local_tempdir()
  destino <- file.path(tmp, "cache-nueva")

  withr::local_options(
    rlang_interactive  = TRUE,
    censosbo.cache_dir = NULL,
    censosbo.consent   = TRUE
  )
  local_mocked_bindings(
    .preguntar_si_no = function(...) stop("no debe preguntar con consentimiento previo")
  )

  expect_no_error(.asegurar_cache_dir(destino))
  expect_true(dir.exists(destino))
})

test_that("con una ruta elegida por el usuario no pregunta", {
  # Si alguien fija options(censosbo.cache_dir = "data/censosbo"), ya eligio donde
  # escribir: volver a preguntarlo seria ruido.
  tmp <- withr::local_tempdir()
  destino <- file.path(tmp, "mi-proyecto", "datos")

  withr::local_options(
    rlang_interactive  = TRUE,
    censosbo.cache_dir = file.path(tmp, "mi-proyecto"),
    censosbo.consent   = NULL
  )
  local_mocked_bindings(
    .preguntar_si_no = function(...) stop("no debe preguntar por una ruta que eligio el usuario")
  )

  expect_no_error(.asegurar_cache_dir(destino))
  expect_true(dir.exists(destino))
})

test_that("en sesion interactiva pregunta, y un no aborta con la salida escrita", {
  tmp <- withr::local_tempdir()
  destino <- file.path(tmp, "cache-nueva")

  # Redirigir el cache del SISTEMA a un tempdir, no la opcion del paquete: fijar
  # censosbo.cache_dir marcaria la ruta como "elegida por el usuario" y el codigo
  # dejaria de preguntar, que es justo el camino que este test ejercita. La
  # variable de entorno es la que consulta tools::R_user_dir().
  withr::local_envvar(R_USER_CACHE_DIR = file.path(tmp, "xdg-cache"))
  withr::local_options(
    rlang_interactive  = TRUE,
    censosbo.cache_dir = NULL,
    censosbo.consent   = NULL
  )
  # Sanidad: si esto falla, el resto del test estaria probando otra cosa.
  expect_false(dir.exists(censosbo_cache_dir()))

  # Responder "n": debe abortar sin crear nada, y el mensaje tiene que decir COMO
  # autorizarlo (un error que no ofrece salida deja al usuario atascado).
  local_mocked_bindings(.preguntar_si_no = function(...) FALSE)
  err <- expect_error(.asegurar_cache_dir(destino))
  expect_match(conditionMessage(err), "censosbo.consent", fixed = TRUE)
  expect_false(dir.exists(destino))

  # Responder "s": procede.
  local_mocked_bindings(.preguntar_si_no = function(...) TRUE)
  expect_no_error(.asegurar_cache_dir(destino))
  expect_true(dir.exists(destino))
})

test_that("si el directorio ya existe no pregunta nada", {
  tmp <- withr::local_tempdir()
  withr::local_options(rlang_interactive = TRUE, censosbo.consent = NULL)
  local_mocked_bindings(
    .preguntar_si_no = function(...) stop("no debe preguntar por un directorio que ya existe")
  )
  expect_no_error(.asegurar_cache_dir(tmp))
})

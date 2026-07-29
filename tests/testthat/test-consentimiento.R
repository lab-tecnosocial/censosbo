# El caché persistente necesita permiso del usuario (política de CRAN), pero pedirlo
# mal rompe a los consumidores headless: la app censos-explorer corre en un
# contenedor sin tty y descarga ahí las geometrías de manzanos y comunidades. Estos
# tests fijan el contrato de .asegurar_cache_dir() en las cinco situaciones, y el
# primero es el que no debe cambiar nunca sin avisar a esos consumidores.
#
# TODOS redirigen el caché del sistema con R_USER_CACHE_DIR —la variable que consulta
# tools::R_user_dir()— a un tempdir. No es higiene opcional: la rama "ya autorizado"
# se activa si el directorio raíz YA existe, así que en la máquina de quien tiene
# censosbo en uso los tests pasaban sin ejercitar nada, y solo fallaban en CI, donde
# no hay caché previo. Fijar la opción censosbo.cache_dir NO sirve para esto: marca
# la ruta como elegida por el usuario, que es otro camino distinto.
.cache_aislado <- function(env = parent.frame()) {
  tmp <- withr::local_tempdir(.local_envir = env)
  withr::local_envvar(R_USER_CACHE_DIR = file.path(tmp, "xdg-cache"), .local_envir = env)
  tmp
}

test_that("en sesion NO interactiva crea el cache sin preguntar", {
  tmp <- .cache_aislado()
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
  tmp <- .cache_aislado()
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
  tmp <- .cache_aislado()
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
  tmp <- .cache_aislado()
  destino <- file.path(tmp, "cache-nueva")

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
  tmp <- .cache_aislado()
  withr::local_options(rlang_interactive = TRUE, censosbo.consent = NULL)
  local_mocked_bindings(
    .preguntar_si_no = function(...) stop("no debe preguntar por un directorio que ya existe")
  )
  expect_no_error(.asegurar_cache_dir(tmp))
})

test_that("en sesion NO interactiva no imprime nada sobre el cache", {
  # Regresion: la version anterior informaba "voy a guardar los datos en..." y
  # preguntaba SIEMPRE que faltara autorizacion, delegando en .preguntar_si_no() la
  # decision de no leer nada. Efecto: en un contenedor aparecia un prompt en el log
  # seguido de la creacion del directorio igual. El CI lo destapo; en local no,
  # porque la maquina ya tenia cache y no entraba en esa rama.
  tmp <- .cache_aislado()
  destino <- file.path(tmp, "cache-nueva")

  withr::local_options(
    rlang_interactive  = FALSE,
    censosbo.cache_dir = NULL,
    censosbo.consent   = NULL
  )
  expect_silent(.asegurar_cache_dir(destino))
  expect_true(dir.exists(destino))
})

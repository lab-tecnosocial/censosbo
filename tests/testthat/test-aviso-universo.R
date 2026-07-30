# El aviso de universo en las funciones de un solo censo.
#
# Contexto: el paquete publicaba el universo en `codebook()` desde hace versiones,
# pero solo lo AVISABA en `get_temporal()`, y ahí únicamente cuando difería entre
# censos. El caso de riesgo quedaba descubierto: pedir una variable de universo
# estrecho de un solo censo y dividir por el total de filas. Le pasó a
# censos-explorer con `nivel_edu` (21,59% donde correspondía 33,38%).
#
# Estos tests fijan las dos mitades del contrato: que avise cuando toca, y que se
# calle cuando no, que es lo que evita que el aviso se vuelva ruido ignorable.

test_that("avisa cuando una variable pedida tiene universo estrecho", {
  expect_message(
    .avisar_universo_pedido("nivel_edu", 2024L),
    "No toda la población respondió"
  )
  # El mensaje nombra la variable y su universo en palabras, no el slug.
  expect_message(.avisar_universo_pedido("nivel_edu", 2024L), "nivel_edu")
  expect_message(.avisar_universo_pedido("nivel_edu", 2024L), "19 años o más")
})

test_that("no avisa de variables que se preguntaron a toda la poblacion", {
  expect_no_message(.avisar_universo_pedido(c("p25_sexo", "p26_edad"), 2024L))
})

test_that("no avisa con verbose = FALSE", {
  # El contrato de los consumidores headless: censos-explorer llama con
  # verbose = FALSE y no debe recibir mensajes de progreso por stderr.
  expect_no_message(.avisar_universo_pedido("nivel_edu", 2024L, verbose = FALSE))
})

test_that("no avisa cuando no se pidieron variables explicitamente", {
  # Con variables = NULL se devuelven las 119 columnas y el usuario aun no sabe
  # que va a analizar: listar todas las de universo estrecho seria un muro.
  expect_no_message(.avisar_universo_pedido(NULL, 2024L))
  expect_no_message(.avisar_universo_pedido(character(0), 2024L))
})

test_that("una variable inexistente no rompe el aviso", {
  # El aviso corre antes de que .apply_variable_selection avise de columnas que no
  # existen; no debe fallar por adelantado ni tapar ese otro mensaje.
  expect_no_message(.avisar_universo_pedido("no_existe_esta_variable", 2024L))
  expect_no_error(.avisar_universo_pedido(c("nivel_edu", "no_existe"), 2024L, verbose = FALSE))
})

test_that("un anio sin diccionario no rompe el aviso", {
  expect_no_error(.avisar_universo_pedido("nivel_edu", 1999L, verbose = FALSE))
})

test_that("agrupa varias variables en un solo mensaje", {
  # Un mensaje por llamada, no uno por variable: N avisos seguidos se ignoran.
  msgs <- testthat::capture_messages(
    .avisar_universo_pedido(c("nivel_edu", "p40_lee", "p25_sexo"), 2024L)
  )
  expect_length(msgs, 1L)
  expect_match(msgs[[1]], "nivel_edu")
  expect_match(msgs[[1]], "p40_lee")
  # p25_sexo se preguntó a todos, así que no aparece.
  expect_false(grepl("p25_sexo", msgs[[1]]))
})

test_that("el aviso llega desde las funciones get_*", {
  # Se comprueba en el punto de integracion, con un dataset falso, para no
  # depender de la red: .apply_variable_selection es el punto unico por el que
  # pasan las ocho funciones get_*.
  ds <- data.frame(idep = "09", iprov = "01", imun = "01",
                   nivel_edu = 1L, p25_sexo = 1L)
  expect_message(
    .apply_variable_selection(ds, "nivel_edu", anio = 2024L, verbose = TRUE),
    "No toda la población"
  )
  # Sin `anio` no hay aviso: es lo que mantiene calladas a las funciones de fichas,
  # cuyos indicadores agregados llevan su propio denominador en `denominador`.
  expect_no_message(.apply_variable_selection(ds, "nivel_edu"))
  expect_no_message(.apply_variable_selection(ds, "nivel_edu", anio = 2024L, verbose = FALSE))
})

# ---------------------------------------------------------------------------
# Limitación conocida: el diccionario de 2012 no tiene universos restrictivos
# ---------------------------------------------------------------------------
# El aviso solo puede ser tan bueno como el metadato. En 2012 la columna `universo`
# solo toma los valores `todas_personas`, `todas_viviendas` y NA, mientras 1976,
# 1992, 2001 y 2024 sí distinguen los universos por edad. Consecuencia: pedir
# `P37A_NIVELNUE` de 2012 no avisa, aunque el nivel de instrucción no se preguntó a
# los menores de 4 años (en 2001 la variable equivalente sí figura como
# `personas_4_mas`).
#
# No se rellenó a mano: los universos vienen del DDI del ANDA y adivinarlos sería
# inventar metadatos, que es peor que no tenerlos. Este test documenta el estado y
# avisa el día en que se corrija, para actualizar la documentación a la vez.

test_that("los censos con universos poblados avisan, y 2012 esta pendiente", {
  con_universos <- vapply(c(1976, 1992, 2001, 2024), function(a) {
    u <- unique(stats::na.omit(codebook(anio = a)$universo))
    any(u %in% names(.UNIVERSO_EDAD_MIN))
  }, logical(1))
  expect_true(all(con_universos))

  u12 <- unique(stats::na.omit(codebook(anio = 2012)$universo))
  # Si esto empieza a fallar es una BUENA noticia: significa que 2012 ya tiene
  # universos. Al corregirlo, actualiza `?codebook` y dev-docs/problemas-conocidos.md.
  expect_false(any(u12 %in% names(.UNIVERSO_EDAD_MIN)),
               label = "2012 sigue sin universos por edad (ver dev-docs)")
})

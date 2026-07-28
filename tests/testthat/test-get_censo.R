test_that("get_censo() falla con mensaje claro ante año no válido", {
  err <- expect_error(get_censo(2050, "persona"))
  expect_match(conditionMessage(err), "no válido")
  # No debe filtrar el error interno de cli por variables con punto
  expect_no_match(conditionMessage(err), "Invalid cli literal")
})

test_that("get_censo() acepta el año 2024 y valida sus tablas", {
  # 2024 es un año válido: se delega en las funciones get_*_2024() (no se
  # comprueba la descarga aquí, solo que el año no se rechaza).
  err <- expect_error(get_censo(2024, "discapacidad"))
  expect_match(conditionMessage(err), "no disponible")
  expect_match(conditionMessage(err), "mortalidad")
})

test_that("get_censo() reporta 2024 entre los años disponibles", {
  err <- expect_error(get_censo(2050, "persona"))
  expect_match(conditionMessage(err), "2024")
})

test_that("get_censo() falla con tabla no disponible para el año", {
  err <- expect_error(get_censo(2001, "mortalidad"))
  expect_match(conditionMessage(err), "no disponible")
})

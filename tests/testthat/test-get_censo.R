test_that("get_censo() falla con mensaje claro ante año no válido", {
  err <- expect_error(get_censo(2050, "persona"))
  expect_match(conditionMessage(err), "no válido")
  # No debe filtrar el error interno de cli por variables con punto
  expect_no_match(conditionMessage(err), "Invalid cli literal")
})

test_that("get_censo() redirige al CPV-2024 cuando se pide el año 2024", {
  err <- expect_error(get_censo(2024, "persona"))
  expect_match(conditionMessage(err), "get_personas_2024")
})

test_that("get_censo() falla con tabla no disponible para el año", {
  err <- expect_error(get_censo(2001, "mortalidad"))
  expect_match(conditionMessage(err), "no disponible")
})

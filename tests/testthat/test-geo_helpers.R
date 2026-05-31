test_that("departamentos() devuelve un data.frame con las columnas correctas", {
  d <- departamentos()
  expect_s3_class(d, "data.frame")
  expect_true(all(c("idep", "nombre_dep") %in% names(d)))
})

test_that(".resolve_dep_codes() acepta códigos numéricos", {
  expect_equal(censosbo:::.resolve_dep_codes("7"),  "07")
  expect_equal(censosbo:::.resolve_dep_codes("02"), "02")
})

test_that(".resolve_dep_codes() acepta nombres de departamento", {
  expect_equal(censosbo:::.resolve_dep_codes("Santa Cruz"), "07")
  expect_equal(censosbo:::.resolve_dep_codes("La Paz"),     "02")
})

test_that(".resolve_dep_codes() falla con código inválido", {
  expect_error(censosbo:::.resolve_dep_codes("99"))
  expect_error(censosbo:::.resolve_dep_codes("XYZ"))
})

test_that(".resolve_dep_codes() devuelve NULL para NULL", {
  expect_null(censosbo:::.resolve_dep_codes(NULL))
})

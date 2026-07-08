test_that("departamentos() devuelve un data.frame con las columnas correctas", {
  d <- departamentos()
  expect_s3_class(d, "data.frame")
  expect_true(all(c("idep", "nombre_dep") %in% names(d)))
})

test_that("los helpers geográficos devuelven tibble (imprimibles con n =)", {
  expect_s3_class(departamentos(), "tbl_df")
  expect_s3_class(provincias("Cochabamba"), "tbl_df")
  expect_s3_class(municipios(departamento = "Cochabamba"), "tbl_df")
})

test_that("municipios() acepta nombre de provincia", {
  m <- municipios(departamento = "Cochabamba", provincia = "Cercado")
  expect_true(nrow(m) == 1)
  expect_equal(m$nombre_mun, "Cochabamba")
})

test_that(".resolve_geo() resuelve nombres a la tupla completa", {
  g <- censosbo:::.resolve_geo(departamento = "Cochabamba", municipio = "Cochabamba")
  expect_equal(g$dep_codes, "03")
  expect_equal(nrow(g$rows), 1L)
  expect_equal(g$rows$iprov, "01")
  expect_equal(g$rows$imun, "01")
})

test_that(".resolve_geo() infiere el departamento cuando solo se da municipio", {
  g <- censosbo:::.resolve_geo(municipio = "Cochabamba")
  expect_equal(g$dep_codes, "03")
})

test_that(".resolve_geo() falla con nombre inexistente o ambiguo", {
  expect_error(censosbo:::.resolve_geo(departamento = "Cochabamba", municipio = "Zzz"),
               "no encontrado")
  # "Totora" existe en Cochabamba y Oruro
  expect_error(censosbo:::.resolve_geo(municipio = "Totora"),
               "varios departamentos")
})

test_that("etiquetar_geografia() agrega nombres por la tupla presente", {
  df <- data.frame(idep = "03", iprov = "01", imun = "01", n = 10L,
                   stringsAsFactors = FALSE)
  out <- etiquetar_geografia(df)
  expect_true(all(c("nombre_dep", "nombre_prov", "nombre_mun") %in% names(out)))
  expect_equal(out$nombre_mun, "Cochabamba")

  # Solo idep -> solo nombre_dep
  out2 <- etiquetar_geografia(data.frame(idep = "07", stringsAsFactors = FALSE))
  expect_true("nombre_dep" %in% names(out2))
  expect_false("nombre_mun" %in% names(out2))
  expect_equal(out2$nombre_dep, "Santa Cruz")
})

test_that("etiquetar_geografia() falla sin columna idep", {
  expect_error(etiquetar_geografia(data.frame(x = 1)), "idep")
})

test_that(".apply_geo() alinea tipos de clave con el esquema (large_utf8 vs utf8)", {
  skip_if_not_installed("arrow")
  # Reproduce el caso de vivienda.parquet: columnas geográficas large_utf8.
  # Sin la alineación de tipos, el semi_join de arrow falla.
  tbl <- arrow::arrow_table(
    idep  = c("03", "03", "07"),
    iprov = c("01", "02", "01"),
    imun  = c("01", "01", "01"),
    x     = 1:3,
    schema = arrow::schema(
      idep = arrow::large_utf8(), iprov = arrow::large_utf8(),
      imun = arrow::large_utf8(), x = arrow::int32()
    )
  )
  geo <- censosbo:::.resolve_geo(departamento = "Cochabamba", municipio = "Cochabamba")
  res <- censosbo:::.apply_geo(tbl, geo) |> dplyr::collect()
  expect_equal(nrow(res), 1L)
  expect_equal(res$idep, "03")
  expect_equal(res$iprov, "01")
})

test_that("los helpers geográficos reinician los row.names (1:n)", {
  expect_equal(rownames(departamentos()), as.character(seq_len(9)))
  p <- provincias("Pando")
  expect_equal(rownames(p), as.character(seq_len(nrow(p))))
  m <- municipios(departamento = "Pando")
  expect_equal(rownames(m), as.character(seq_len(nrow(m))))
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

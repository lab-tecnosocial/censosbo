test_that("codebook() devuelve un data.frame", {
  result <- codebook()
  expect_s3_class(result, "data.frame")
})

test_that("codebook() filtra por tabla", {
  # Con datos placeholder vacíos, solo verificamos que no da error
  result <- codebook(tabla = "persona")
  expect_s3_class(result, "data.frame")
})

test_that("codebook() filtra por búsqueda de texto", {
  result <- codebook(buscar = "inexistente_xyz_12345")
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0L)
})

test_that("tipo solo toma valores válidos y es consistente", {
  validos <- c("categorica", "numerica", "texto")
  metas <- c(list(`2024` = codebook_meta), codebook_historico_meta)
  for (nm in names(metas)) {
    meta <- metas[[nm]]
    expect_true(all(meta$tipo %in% validos),
                info = paste("tipos inválidos en censo", nm))
    # Solo las categóricas conservan categorías.
    tiene_vals <- !vapply(meta$valores_codigos, is.null, logical(1))
    expect_true(all(meta$tipo[tiene_vals] == "categorica"),
                info = paste("variable no categórica con valores en censo", nm))
  }
})

test_that("`area` (persona) está en el codebook 2024 con sus valores (bug #4)", {
  ca <- codebook("area")
  expect_true("persona" %in% ca$tabla)
  expect_equal(codebook("area")$tipo[1], "categorica")
  va <- codebook_valores("area")
  expect_s3_class(va, "data.frame")
  expect_equal(nrow(va), 2L)
  expect_equal(va$etiqueta, c("Urbana", "Rural"))
})

test_that("códigos numéricos categóricos se clasifican como categorica", {
  # Variables cuyos valores son números pero representan categorías.
  expect_equal(codebook("p25_sexo")$tipo, "categorica")
  # Código de clasificación con nombre tipo `cod` (antes marcado numerica).
  expect_equal(codebook("p35h_muncod")$tipo, "categorica")
  # Código de ocupación del censo 2001 sin etiquetas enumeradas.
  expect_equal(codebook("P33COD", anio = 2001)$tipo, "categorica")
})

# ─── Retrocompatibilidad tras añadir la taxonomía ────────────────────────────
# La app censos-explorer llama a censosbo::codebook() en vivo, así que el nombre
# y el orden de las cinco columnas originales son contrato. Las columnas nuevas
# van siempre después.

test_that("las cinco columnas originales conservan nombre y orden", {
  expect_identical(
    names(codebook())[1:5],
    c("variable", "etiqueta", "tabla", "valores_codigos", "tipo")
  )
})

test_that("codebook() devuelve la misma forma en los cinco censos", {
  # Permite hacer rbind() entre años, como hace la viñeta del diccionario. En
  # 1976 y 1992 las columnas de taxonomía existen pero están vacías.
  formas <- lapply(c(1976, 1992, 2001, 2012, 2024), function(a) names(codebook(anio = a)))
  expect_length(unique(formas), 1)
  combinado <- do.call(rbind, lapply(c(1976, 2024), function(a) codebook(anio = a)))
  expect_gt(nrow(combinado), nrow(codebook(anio = 1976)))
})

test_that("las llamadas posicionales siguen funcionando", {
  # Los argumentos nuevos se añadieron DESPUÉS de `anio`, precisamente para esto.
  expect_equal(nrow(codebook("p25_sexo", "persona", NULL, 2024)), 1)
  expect_equal(codebook("p25_sexo", "persona", NULL, 2024)$variable, "p25_sexo")
})

test_that("los filtros de taxonomía no distinguen mayúsculas", {
  expect_equal(nrow(codebook(tema = "EDUCACION")), nrow(codebook(tema = "educacion")))
  expect_equal(nrow(codebook(capitulo = "c")), nrow(codebook(capitulo = "C")))
  expect_equal(nrow(codebook(origen = "DERIVADA")), nrow(codebook(origen = "derivada")))
})

test_that("`buscar` alcanza también al tema", {
  # codebook(buscar = "salud") debe encontrar el tema completo, no solo las
  # variables cuya etiqueta contiene la palabra.
  por_tema <- codebook(tema = "salud_seguridad_social")
  por_texto <- codebook(buscar = "salud")
  expect_true(all(por_tema$variable %in% por_texto$variable))
})

test_that("`tema` y `origen` funcionan en los cinco censos", {
  for (anio in c(1976, 1992, 2001, 2012, 2024)) {
    expect_gt(nrow(codebook(tema = "educacion", anio = anio)), 0, label = anio)
    expect_gt(nrow(codebook(origen = "cuestionario", anio = anio)), 0, label = anio)
  }
})

test_that("`capitulo` solo aplica al cuestionario del CPV-2024", {
  for (anio in c(1976, 1992, 2001, 2012)) {
    expect_error(codebook(capitulo = "C", anio = anio), "CPV-2024")
  }
  expect_gt(nrow(codebook(capitulo = "C", anio = 2024)), 0)
})

test_that("los alias por año exponen los filtros que corresponden a su censo", {
  expect_equal(nrow(codebook_2024(tema = "educacion")),
               nrow(codebook(tema = "educacion", anio = 2024)))
  expect_equal(nrow(codebook_2012(tema = "educacion")),
               nrow(codebook(tema = "educacion", anio = 2012)))
  expect_equal(nrow(codebook_1992(tema = "religion")),
               nrow(codebook(tema = "religion", anio = 1992)))
  # Los cinco aceptan `tema`; solo el de 2024 acepta `capitulo`.
  expect_true("tema" %in% names(formals(codebook_1976)))
  expect_false("capitulo" %in% names(formals(codebook_2012)))
  expect_true("capitulo" %in% names(formals(codebook_2024)))
})

# ─── Impresión ───────────────────────────────────────────────────────────────
# Con quince columnas, imprimir el codebook en consola era ilegible: cuatro de
# ellas están enteramente vacías al consultar `persona`, y `valores_codigos`
# volcaba todas las categorías de todas las filas.

test_that("print() oculta las columnas vacías y avisa de cuáles", {
  salida <- capture.output(print(codebook("p25_sexo")))
  texto <- paste(salida, collapse = " ")
  # Las cuatro que no aplican a una variable de persona.
  expect_match(texto, "grupo_ine")
  expect_match(texto, "sin datos aquí")
  expect_false(grepl("valores_fuente +NA", texto))
  # Y las que sí aplican siguen ahí.
  expect_match(texto, "poblacion")
  expect_match(texto, "todas_personas")
})

test_that("print() resume valores_codigos en vez de volcarlo", {
  salida <- paste(capture.output(print(codebook("p24_parentes"))), collapse = " ")
  expect_match(salida, "16 categorías")
  # El detalle sigue disponible por su vía propia.
  expect_false(grepl("Jefa o jefe de hogar", salida))
  expect_equal(nrow(codebook_valores("p24_parentes")), 16)
})

test_that("print() muestra bloque y denominador donde sí aportan", {
  salida <- paste(capture.output(print(codebook("serv_agua_caneria", tabla = "ficha"))),
                  collapse = " ")
  expect_match(salida, "servicios")
  expect_match(salida, "serv_agua_total")
})

test_that("el objeto sigue siendo un data.frame con las 15 columnas", {
  cb <- codebook("p25_sexo")
  expect_true(is.data.frame(cb))
  expect_equal(ncol(cb), 15)
  expect_true("grupo_ine" %in% names(cb))
  # Subconjuntos y dplyr siguen funcionando igual.
  expect_equal(nrow(cb[cb$tabla == "persona", ]), 1)
  expect_equal(nrow(dplyr::filter(codebook(tabla = "persona"), tipo == "numerica")),
               sum(codebook(tabla = "persona")$tipo == "numerica"))
})

test_that("print() no falla con cero filas", {
  vacio <- suppressMessages(codebook(variable = "no_existe_esta_variable"))
  expect_output(print(vacio), "Ninguna variable")
})

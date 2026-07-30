# Los nombres y las búsquedas no deben depender de que el usuario teclee las tildes.
#
# Salió de una prueba de instalación limpia: `municipios("Potosi")` abortaba y
# `codebook_2012(buscar = "instruccion")` devolvía cero filas, las dos veces sin
# ninguna pista de que solo faltaba un acento. 55 de los 343 municipios llevan tilde
# o eñe, y las etiquetas del diccionario están escritas con la ortografía correcta
# ("Nivel más alto de instrucción"), así que el caso no es marginal: es el normal.
#
# Los acentos van literales, como en el resto de tests/: la regla de ASCII puro es
# para R/, que es lo que revisa `checking R files for non-ASCII characters`, y aquí
# ver el carácter acentuado a la vista es justamente lo que hace legible el test.

test_that(".plegar_acentos cubre las vocales, la dieresis y la enie", {
  expect_identical(
    .plegar_acentos("áéíóúüñ"),
    "aeiouun"
  )
  expect_identical(
    .plegar_acentos("ÁÉÍÓÚÜÑ"),
    "AEIOUUN"
  )
  # No toca nada mas: ni la ortografia correcta sin acentos ni otros caracteres.
  expect_identical(.plegar_acentos("Santa Cruz"), "Santa Cruz")
  expect_identical(.plegar_acentos("p40_lee"), "p40_lee")
  # Vectorizado y respetuoso con NA.
  expect_identical(
    .plegar_acentos(c("Potosí", NA, "Beni")),
    c("Potosi", NA, "Beni")
  )
})

test_that(".norm_nombre iguala mayusculas, acentos y espacios sobrantes", {
  expect_identical(.norm_nombre("  Potosí "), "potosi")
  expect_identical(.norm_nombre("ZUDÁÑEZ"), "zudanez")
})

test_that("el departamento se resuelve con y sin tilde", {
  # Potosi es el unico departamento con tilde, y por eso el unico que fallaba.
  expect_identical(.resolve_dep_codes("Potosí"), "05")
  expect_identical(.resolve_dep_codes("Potosi"), "05")
  expect_identical(.resolve_dep_codes("potosi"), "05")
  expect_identical(.resolve_dep_codes("POTOSI"), "05")
  # Los codigos y los demas nombres siguen igual.
  expect_identical(.resolve_dep_codes("05"), "05")
  expect_identical(.resolve_dep_codes("Santa Cruz"), "07")
  # Y un nombre que de verdad no existe sigue abortando.
  expect_error(.resolve_dep_codes("Atlantida"), "no reconocido")
})

test_that("provincias() y municipios() aceptan el departamento sin tilde", {
  expect_identical(provincias("Potosi"), provincias("Potosí"))
  expect_identical(municipios("Potosi"), municipios("Potosí"))
})

test_that("los municipios con tilde o enie se resuelven sin ella", {
  mu <- municipios()
  con_acento <- mu$nombre_mun[mu$nombre_mun != .plegar_acentos(mu$nombre_mun)]
  # Si esto falla, o el catalogo cambio o se perdieron los acentos de los nombres:
  # en ambos casos hay que mirar, no relajar el test.
  expect_gt(length(con_acento), 40)

  # Se comprueban todos, no una muestra: cada uno es un nombre que un usuario
  # puede teclear sin acento, y el coste es una busqueda en un data.frame de 343.
  # Se fija el departamento porque nueve nombres de municipio estan repetidos entre
  # departamentos ("Entre Rios" esta en Cochabamba y en Tarija) y sin el son ambiguos
  # se escriban con acento o sin el; ese caso se comprueba en el test siguiente.
  for (nom in con_acento) {
    sin <- .plegar_acentos(nom)
    dep <- mu$nombre_dep[mu$nombre_mun == nom][1]
    expect_identical(
      .resolve_geo(departamento = dep, municipio = sin),
      .resolve_geo(departamento = dep, municipio = nom),
      info = paste0("municipio sin acento: ", sin, " (real: ", nom, ", ", dep, ")")
    )
  }
})

test_that("plegar acentos no crea ambiguedades nuevas", {
  # La duda razonable al quitar los acentos es si dos municipios que se distinguian
  # por una tilde pasan a colisionar. No ocurre: los nueve nombres que colisionan al
  # plegar son los nueve que YA estaban repetidos de forma exacta entre
  # departamentos, asi que la lista de nombres ambiguos no cambia.
  mu <- municipios()
  colisiones_plegadas <- unique(.norm_nombre(mu$nombre_mun)[duplicated(.norm_nombre(mu$nombre_mun))])
  colisiones_exactas <- unique(.norm_nombre(mu$nombre_mun[duplicated(mu$nombre_mun)]))
  expect_setequal(colisiones_plegadas, colisiones_exactas)

  # Y siguen abortando con la indicacion de desambiguar, no eligiendo uno al azar.
  err <- expect_error(.resolve_geo(municipio = "Entre Rios"))
  expect_match(conditionMessage(err), "varios departamentos")
  # Con departamento, resuelven.
  expect_no_error(.resolve_geo(departamento = "Tarija", municipio = "Entre Rios"))
})

test_that("buscar encuentra la etiqueta acentuada sin escribir el acento", {
  # El caso exacto que estaba roto en el README.
  sin <- codebook_2012(buscar = "instruccion")
  con <- codebook_2012(buscar = "instrucción")
  expect_identical(sin, con)
  expect_gt(nrow(sin), 0)
  expect_true(any(grepl("instrucción", sin$etiqueta, fixed = TRUE)))
})

test_that("buscar da el mismo resultado con y sin acentos en 2024", {
  pares <- list(
    c("anos", "años"),
    c("numero", "número"),
    c("telefono", "teléfono"),
    c("educacion", "educación")
  )
  for (p in pares) {
    sin <- codebook(buscar = p[1])
    con <- codebook(buscar = p[2])
    expect_identical(sin, con, info = paste("buscar:", p[1], "vs", p[2]))
    expect_gt(nrow(sin), 0)
  }
})

test_that("buscar sigue sirviendo como expresion regular", {
  # Plegar acentos no debe romper el uso documentado como regex.
  expect_identical(codebook(buscar = "^p40"), codebook(variable = "p40_lee"))
  expect_gt(nrow(codebook(buscar = "sexo|edad")), nrow(codebook(buscar = "sexo")))
})

test_that("buscar sin coincidencias sigue informando, no fallando", {
  expect_message(
    res <- codebook(buscar = "zzz_no_existe_esto"),
    "No se encontraron variables"
  )
  expect_identical(nrow(res), 0L)
})

# ---------------------------------------------------------------------------
# Un tema válido en la taxonomía pero ausente del censo pedido
# ---------------------------------------------------------------------------
# `censo_temas_meta` tiene 21 temas, pero ninguno de los cinco censos tiene los 21:
# `religion` solo se preguntó en 1992 y `movilidad_trabajo` solo en 2024. Validar
# contra la lista completa dejaba pasar temas que devolvían cero filas sin decir por
# qué, y hacía que el mensaje de error prometiera "21 temas disponibles" cuando
# `censo_temas()` mostraba 20.

test_that(".temas_del_anio devuelve solo los temas de ese censo", {
  expect_true("religion" %in% .temas_del_anio(1992))
  expect_false("religion" %in% .temas_del_anio(2024))
  expect_true("movilidad_trabajo" %in% .temas_del_anio(2024))
  expect_false("movilidad_trabajo" %in% .temas_del_anio(2012))
  # Y coincide con lo que el usuario ve al listar.
  expect_setequal(.temas_del_anio(2024), censo_temas(anio = 2024)$tema)
  expect_setequal(.temas_del_anio(1992), censo_temas(anio = 1992)$tema)
})

test_that("un tema de otro censo aborta diciendo en cuales si esta", {
  err <- expect_error(codebook(tema = "religion", anio = 2024))
  expect_match(conditionMessage(err), "no se preguntó en el censo 2024")
  expect_match(conditionMessage(err), "1992")
  # Y en el censo donde si existe, funciona.
  expect_gt(nrow(codebook(tema = "religion", anio = 1992)), 0)
})

test_that("censo_temas() aplica el mismo criterio que codebook()", {
  expect_error(censo_temas(tema = "religion", anio = 2024), "no se preguntó")
  expect_gt(nrow(censo_temas(tema = "religion", anio = 1992)), 0)
})

test_that("el numero de temas del mensaje coincide con lo que se puede listar", {
  # El desajuste original: el mensaje contaba 21 y censo_temas() mostraba 20.
  err <- expect_error(codebook(tema = "no_existe_este_tema", anio = 2024))
  n_listados <- nrow(censo_temas(anio = 2024))
  expect_match(conditionMessage(err), paste0("los ", n_listados, " temas disponibles"))
})

test_that("un tema inexistente sigue sugiriendo el parecido", {
  err <- expect_error(codebook(tema = "educacon"))
  expect_match(conditionMessage(err), "educacion")
})

test_that("los temas tambien se aceptan sin acentos ni mayusculas", {
  expect_identical(codebook(tema = "EDUCACION"), codebook(tema = "educacion"))
})
